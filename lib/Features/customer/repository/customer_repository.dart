import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../Data/core/database_helper.dart';
import '../model/customer_model.dart';
import '../model/outbox_model.dart';


class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();

  // Get all customers (excluding deleted)
  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Get customer by ID
  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  // Insert customer
  Future<void> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    
    // Insert customer
    await db.insert('customers', customer.toMap());
    
    // Add to outbox for sync
    await _addToOutbox(customer.id, 'CREATE', customer);
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    
    // Update customer with new timestamp
    final updatedCustomer = customer.copyWith();
    await db.update(
      'customers',
      updatedCustomer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    
    // Add to outbox for sync
    await _addToOutbox(customer.id, 'UPDATE', updatedCustomer);
  }

  // Soft delete customer
  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    
    final customer = await getCustomerById(id);
    if (customer != null) {
      final deletedCustomer = customer.copyWith(isDeleted: true);
      await db.update(
        'customers',
        deletedCustomer.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Add to outbox for sync
      await _addToOutbox(id, 'DELETE', deletedCustomer);
    }
  }

  // Search customers by name or phone
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'is_deleted = ? AND (name LIKE ? OR phone LIKE ?)',
      whereArgs: [0, '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Add operation to outbox
  Future<void> _addToOutbox(String recordId, String action, Customer customer) async {
    final db = await _dbHelper.database;
    
    final outboxItem = OutboxItem(
      id: _uuid.v4(),
      tableName: 'customers',
      recordId: recordId,
      action: action,
      data: jsonEncode(customer.toJson()),
    );

    await db.insert('outbox', outboxItem.toMap());
  }

  // Sync methods
  Future<void> markAsSynced(String customerId) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      {'synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Customer>> getUnsyncedCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Batch insert from server (for pull sync)
  Future<void> insertCustomersFromServer(List<Customer> customers) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final customer in customers) {
      batch.insert(
        'customers',
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }
}