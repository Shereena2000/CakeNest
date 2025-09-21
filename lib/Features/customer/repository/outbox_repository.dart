

import '../../../Data/core/database_helper.dart';
import '../model/outbox_model.dart';

class OutboxRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all unsynced outbox items
  Future<List<OutboxItem>> getUnsyncedItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'outbox',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => OutboxItem.fromMap(maps[i]));
  }

  // Get unsynced items for specific table
  Future<List<OutboxItem>> getUnsyncedItemsForTable(String tableName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'outbox',
      where: 'synced = ? AND table_name = ?',
      whereArgs: [0, tableName],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) => OutboxItem.fromMap(maps[i]));
  }

  // Mark outbox item as synced
  Future<void> markAsSynced(String outboxId) async {
    final db = await _dbHelper.database;
    await db.update(
      'outbox',
      {'synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [outboxId],
    );
  }

  // Increment retry count
  Future<void> incrementRetryCount(String outboxId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE outbox SET retry_count = retry_count + 1 WHERE id = ?',
      [outboxId],
    );
  }

  // Delete outbox item
  Future<void> deleteOutboxItem(String outboxId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'outbox',
      where: 'id = ?',
      whereArgs: [outboxId],
    );
  }

  // Clear all synced items (cleanup)
  Future<void> clearSyncedItems() async {
    final db = await _dbHelper.database;
    await db.delete(
      'outbox',
      where: 'synced = ?',
      whereArgs: [1],
    );
  }
}