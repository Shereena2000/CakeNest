import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqlite_api.dart';

import '../Data/core/database_helper.dart';
import '../Features/customer/model/customer_model.dart';
import '../Features/customer/repository/customer_repository.dart';
import '../Features/customer/repository/outbox_repository.dart';
import '../Features/product/repository/product_repository.dart';
import '../Features/product/model/product_model.dart';
import '../Features/sales/model/sale_item.dart';
import '../Features/sales/repository/sales_repository.dart';
import '../Features/sales/model/sale_model.dart';
import 'supabase_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  SyncService._internal();
  factory SyncService() => _instance;

  final CustomerRepository _customerRepo = CustomerRepository();
  final ProductRepository _productRepo = ProductRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final OutboxRepository _outboxRepo = OutboxRepository();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isSyncing = false;

  // Check connectivity
 Future<bool> hasInternetConnection() async {
  try {
    print('=== INTERNET CHECK DEBUG ===');
    
    // Check device connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    print('Connectivity result: $connectivityResult');
    
    if (connectivityResult == ConnectivityResult.none) {
      print('Device reports no connectivity');
      return false;
    }
    
    print('Device has connectivity, testing Supabase...');
    
    // Test Supabase connection
    final isSupabaseConnected = await _supabaseService.isConnected();
    print('Supabase connection test: $isSupabaseConnected');
    
    return isSupabaseConnected;
  } catch (e) {
    print('Internet connection check failed: $e');
    return false;
  }
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
    
    // Push customers
    await _pushCustomerChanges();
    
    // Push products
    await _pushProductChanges();
    
    // Push sales
    await _pushSalesChanges();
  }

  Future<void> _pushCustomerChanges() async {
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

        await _outboxRepo.markAsSynced(item.id);
        await _customerRepo.markAsSynced(customer.id);
        
        log('Synced ${item.action} for customer ${customer.id}');
        
      } catch (e) {
        log('Failed to sync customer ${item.id}: $e');
        await _outboxRepo.incrementRetryCount(item.id);
        
        if (item.retryCount >= 3) {
          await _outboxRepo.deleteOutboxItem(item.id);
          log('Removed outbox item ${item.id} after 3 failed attempts');
        }
      }
    }
  }

  Future<void> _pushProductChanges() async {
    final outboxItems = await _outboxRepo.getUnsyncedItemsForTable('products');
    
    for (final item in outboxItems) {
      try {
        final productData = jsonDecode(item.data);
        final product = Product.fromJson(productData);

        switch (item.action) {
          case 'CREATE':
            await _supabaseService.insertProduct(product);
            break;
          case 'UPDATE':
            await _supabaseService.updateProduct(product);
            break;
          case 'DELETE':
            await _supabaseService.deleteProduct(product.id);
            break;
        }

        await _outboxRepo.markAsSynced(item.id);
        await _productRepo.markAsSynced(product.id);
        
        log('Synced ${item.action} for product ${product.id}');
        
      } catch (e) {
        log('Failed to sync product ${item.id}: $e');
        await _outboxRepo.incrementRetryCount(item.id);
        
        if (item.retryCount >= 3) {
          await _outboxRepo.deleteOutboxItem(item.id);
          log('Removed outbox item ${item.id} after 3 failed attempts');
        }
      }
    }
  }

  Future<void> _pushSalesChanges() async {
    final outboxItems = await _outboxRepo.getUnsyncedItemsForTable('sales');
    
    for (final item in outboxItems) {
      try {
        final saleData = jsonDecode(item.data);
        final sale = Sale.fromJson(saleData['sale']);
        final items = (saleData['items'] as List)
            .map((itemJson) => SaleItem.fromJson(itemJson))
            .toList();

        switch (item.action) {
          case 'CREATE':
            await _supabaseService.insertSale(sale, items);
            break;
          case 'UPDATE':
            await _supabaseService.updateSale(sale, items);
            break;
          case 'DELETE':
            await _supabaseService.deleteSale(sale.id);
            break;
        }

        await _outboxRepo.markAsSynced(item.id);
        await _salesRepo.markAsSynced(sale.id);
        
        log('Synced ${item.action} for sale ${sale.id}');
        
      } catch (e) {
        log('Failed to sync sale ${item.id}: $e');
        await _outboxRepo.incrementRetryCount(item.id);
        
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
      // Pull customers
      await _pullCustomerChanges();
      
      // Pull products  
      await _pullProductChanges();
      
      // Pull sales
      await _pullSalesChanges();
      
    } catch (e) {
      log('Failed to pull changes: $e');
    }
  }

  Future<void> _pullCustomerChanges() async {
    final lastSyncTime = await _getLastSyncTime('last_customer_sync');
    final serverCustomers = await _supabaseService.getCustomerChanges(since: lastSyncTime);

    for (final serverCustomer in serverCustomers) {
      await _handleCustomerConflictResolution(serverCustomer);
    }

    await _setLastSyncTime('last_customer_sync', DateTime.now());
    log('Pulled ${serverCustomers.length} customer changes');
  }

  Future<void> _pullProductChanges() async {
    final lastSyncTime = await _getLastSyncTime('last_product_sync');
    final serverProducts = await _supabaseService.getProductChanges(since: lastSyncTime);

    for (final serverProduct in serverProducts) {
      await _handleProductConflictResolution(serverProduct);
    }

    await _setLastSyncTime('last_product_sync', DateTime.now());
    log('Pulled ${serverProducts.length} product changes');
  }

  Future<void> _pullSalesChanges() async {
    final lastSyncTime = await _getLastSyncTime('last_sales_sync');
    final salesData = await _supabaseService.getSalesChanges(since: lastSyncTime);

    for (final saleData in salesData) {
      await _handleSaleConflictResolution(saleData['sale'], saleData['items']);
    }

    await _setLastSyncTime('last_sales_sync', DateTime.now());
    log('Pulled ${salesData.length} sales changes');
  }

  // Conflict resolution methods
  Future<void> _handleCustomerConflictResolution(Customer serverCustomer) async {
    final localCustomer = await _customerRepo.getCustomerById(serverCustomer.id);
    
    if (localCustomer == null) {
      await _customerRepo.insertCustomersFromServer([serverCustomer]);
    } else {
      if (serverCustomer.updatedAt.isAfter(localCustomer.updatedAt)) {
        await _customerRepo.insertCustomersFromServer([serverCustomer]);
        log('Updated local customer ${serverCustomer.id} with server version');
      } else {
        log('Kept local version of customer ${localCustomer.id}');
      }
    }
  }

  Future<void> _handleProductConflictResolution(Product serverProduct) async {
    final localProduct = await _productRepo.getProductById(serverProduct.id);
    
    if (localProduct == null) {
      await _productRepo.insertProductsFromServer([serverProduct]);
    } else {
      if (serverProduct.updatedAt.isAfter(localProduct.updatedAt)) {
        await _productRepo.insertProductsFromServer([serverProduct]);
        log('Updated local product ${serverProduct.id} with server version');
      } else {
        log('Kept local version of product ${localProduct.id}');
      }
    }
  }

  Future<void> _handleSaleConflictResolution(Sale serverSale, List<SaleItem> serverItems) async {
    final localSale = await _salesRepo.getSaleById(serverSale.id);
    
    if (localSale == null) {
      // New sale from server - would need implementation in SalesRepository
      log('New sale from server: ${serverSale.id}');
    } else {
      if (serverSale.updatedAt.isAfter(localSale.updatedAt)) {
        log('Updated local sale ${serverSale.id} with server version');
      } else {
        log('Kept local version of sale ${localSale.id}');
      }
    }
  }

  // Sync metadata helpers
  Future<DateTime?> _getLastSyncTime(String key) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (result.isNotEmpty) {
      return DateTime.parse(result.first['value'] as String);
    }
    return null;
  }

  Future<void> _setLastSyncTime(String key, DateTime time) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'sync_metadata',
      {
        'key': key,
        'value': time.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}