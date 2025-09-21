import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mini_erp.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0
      )
    ''');


 // Products table
  await db.execute('''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      stock INTEGER NOT NULL,
      category TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      synced INTEGER DEFAULT 0
    )
  ''');

  // Sales table
  await db.execute('''
    CREATE TABLE sales (
      id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      customer_name TEXT NOT NULL,
      total_amount REAL NOT NULL,
      sale_date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      synced INTEGER DEFAULT 0
    )
  ''');

  // Sale items table
  await db.execute('''
    CREATE TABLE sale_items (
      id TEXT PRIMARY KEY,
      sale_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      total_price REAL NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales (id)
    )
  ''');
    // Outbox table
    await db.execute('''
      CREATE TABLE outbox (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Sync metadata table
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }


  // Add this method to your DatabaseHelper class
Future<void> deleteDatabase() async {
  String path = join(await getDatabasesPath(), 'mini_erp.db');
  await databaseFactory.deleteDatabase(path);
  _database = null; // Reset the cached database
}
}