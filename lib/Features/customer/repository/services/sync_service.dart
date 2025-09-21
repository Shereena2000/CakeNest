import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../../Data/core/database_helper.dart';
import '../../model/customer_model.dart';
import '../customer_repository.dart';
import '../outbox_repository.dart';
import 'supabase_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  SyncService._internal();
  factory SyncService() => _instance;

  final CustomerRepository _customerRepo = CustomerRepository();
  final OutboxRepository _outboxRepo = OutboxRepository();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isSyncing = false;

  // Check connectivity
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await _supabaseService.isConnected();
  }

  // Main sync method
  Future<void> sync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    log('Starting sync...');

    try {
      if (await hasInternetConnection()) {
        await pushChanges();
        await pullChanges();
        log('Sync completed successfully');
      } else {
        log('No internet connection, skipping sync');
      }
    } catch (e) {
      log('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Push local changes to server
  Future<void> pushChanges() async {
    log('Pushing changes to server...');
    
    final outboxItems = await _outboxRepo.getUnsyncedItemsForTable('customers');
    
    for (final item in outboxItems) {
      try {
        final customerData = jsonDecode(item.data);
        final customer = Customer.fromJson(customerData);

        switch (item.action) {
          case 'CREATE':
            await _supabaseService.insertCustomer(customer);
            break;
          case 'UPDATE':
            await _supabaseService.updateCustomer(customer);
            break;
          case 'DELETE':
            await _supabaseService.deleteCustomer(customer.id);
            break;
        }

        // Mark as synced
        await _outboxRepo.markAsSynced(item.id);
        await _customerRepo.markAsSynced(customer.id);
        
        log('Synced ${item.action} for customer ${customer.id}');
        
      } catch (e) {
        log('Failed to sync outbox item ${item.id}: $e');
        await _outboxRepo.incrementRetryCount(item.id);
        
        // Remove item if retry count exceeds limit
        if (item.retryCount >= 3) {
          await _outboxRepo.deleteOutboxItem(item.id);
          log('Removed outbox item ${item.id} after 3 failed attempts');
        }
      }
    }
  }

  // Pull changes from server
  Future<void> pullChanges() async {
    log('Pulling changes from server...');
    
    try {
      final lastSyncTime = await _getLastSyncTime();
      final serverCustomers = await _supabaseService.getCustomerChanges(
        since: lastSyncTime,
      );

      for (final serverCustomer in serverCustomers) {
        await _handleConflictResolution(serverCustomer);
      }

      await _setLastSyncTime(DateTime.now());
      log('Pulled ${serverCustomers.length} customer changes');
      
    } catch (e) {
      log('Failed to pull changes: $e');
    }
  }

  // Handle conflict resolution (last-write-wins)
  Future<void> _handleConflictResolution(Customer serverCustomer) async {
    final localCustomer = await _customerRepo.getCustomerById(serverCustomer.id);
    
    if (localCustomer == null) {
      // New customer from server
      await _customerRepo.insertCustomersFromServer([serverCustomer]);
    } else {
      // Check timestamps for conflict resolution
      if (serverCustomer.updatedAt.isAfter(localCustomer.updatedAt)) {
        // Server version is newer, update local
        await _customerRepo.insertCustomersFromServer([serverCustomer]);
        log('Updated local customer ${serverCustomer.id} with server version');
      } else {
        // Local version is newer or same, keep local
        log('Kept local version of customer ${localCustomer.id}');
      }
    }
  }

  // Sync metadata helpers
  Future<DateTime?> _getLastSyncTime() async {
    // Implementation to get last sync time from sync_metadata table
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: ['last_customer_sync'],
    );
    
    if (result.isNotEmpty) {
      return DateTime.parse(result.first['value'] as String);
    }
    return null;
  }

  Future<void> _setLastSyncTime(DateTime time) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'sync_metadata',
      {
        'key': 'last_customer_sync',
        'value': time.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}