import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../../Data/core/database_helper.dart';
import '../../customer/model/outbox_model.dart';
import '../model/sale_item.dart';
import '../model/sale_model.dart';


class SalesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();

  Future<List<Sale>> getAllSales() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'sale_date DESC',
    );

    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<Sale?> getSaleById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
    );

    if (maps.isNotEmpty) {
      return Sale.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );

    return List.generate(maps.length, (i) => SaleItem.fromMap(maps[i]));
  }

Future<double> getTodaysSalesTotal() async {
  final db = await _dbHelper.database;
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(Duration(days: 1));

  final result = await db.rawQuery(
    'SELECT SUM(total_amount) as total FROM sales WHERE is_deleted = 0 AND sale_date >= ? AND sale_date < ?',
    [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
  );

  final total = result.first['total'];
  if (total == null) {
    return 0.0;
  }
  
  // Handle both int and double types that SQLite might return
  if (total is num) {
    return total.toDouble();
  }
  
  return 0.0;
}

Future<int> getTodaysSalesCount() async {
  final db = await _dbHelper.database;
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(Duration(days: 1));

  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM sales WHERE is_deleted = 0 AND sale_date >= ? AND sale_date < ?',
    [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
  );

  final count = result.first['count'];
  if (count == null) {
    return 0;
  }
  
  // SQLite COUNT always returns int, but cast to be safe
  if (count is int) {
    return count;
  }
  
  return 0;
}
  Future<String> createSale(Sale sale, List<SaleItem> items) async {
    final db = await _dbHelper.database;
    
    // Start transaction
    await db.transaction((txn) async {
      // Insert sale
      await txn.insert('sales', sale.toMap());
      
      // Insert sale items
      for (final item in items) {
        await txn.insert('sale_items', item.toMap());
      }
    });

    // Add to outbox
    await _addSaleToOutbox(sale.id, 'CREATE', sale, items);
    
    return sale.id;
  }

  Future<void> _addSaleToOutbox(String saleId, String action, Sale sale, List<SaleItem> items) async {
    final db = await _dbHelper.database;
    
    // Create combined data for outbox
    final saleData = {
      'sale': sale.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };

    final outboxItem = OutboxItem(
      id: _uuid.v4(),
      tableName: 'sales',
      recordId: saleId,
      action: action,
      data: jsonEncode(saleData),
    );

    await db.insert('outbox', outboxItem.toMap());
  }

  Future<void> markAsSynced(String saleId) async {
    final db = await _dbHelper.database;
    await db.update(
      'sales',
      {'synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }
}