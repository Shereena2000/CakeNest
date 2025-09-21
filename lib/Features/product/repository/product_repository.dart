import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../Data/core/database_helper.dart';
import '../../customer/model/outbox_model.dart';
import '../model/product_model.dart';


class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();

  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_deleted = ? AND stock <= ?',
      whereArgs: [0, threshold],
      orderBy: 'stock ASC',
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

 Future<double> getTotalInventoryValue() async {
  final db = await _dbHelper.database;
  final result = await db.rawQuery(
    'SELECT SUM(price * stock) as total FROM products WHERE is_deleted = 0'
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
  Future<void> insertProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.insert('products', product.toMap());
    await _addToOutbox(product.id, 'CREATE', product);
  }

  Future<void> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    final updatedProduct = product.copyWith();
    await db.update(
      'products',
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    await _addToOutbox(product.id, 'UPDATE', updatedProduct);
  }

  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    final product = await getProductById(id);
    if (product != null) {
      final deletedProduct = product.copyWith(isDeleted: true);
      await db.update(
        'products',
        deletedProduct.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      await _addToOutbox(id, 'DELETE', deletedProduct);
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {
        'stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> _addToOutbox(String recordId, String action, Product product) async {
    final db = await _dbHelper.database;
    final outboxItem = OutboxItem(
      id: _uuid.v4(),
      tableName: 'products',
      recordId: recordId,
      action: action,
      data: jsonEncode(product.toJson()),
    );
    await db.insert('outbox', outboxItem.toMap());
  }

  Future<void> markAsSynced(String productId) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      {'synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> insertProductsFromServer(List<Product> products) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final product in products) {
      batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }
}