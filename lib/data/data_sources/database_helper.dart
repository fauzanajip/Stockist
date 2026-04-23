import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Products table (master data)
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // SPG table (master data)
    await db.execute('''
      CREATE TABLE spgs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // SPB table
    await db.execute('''
      CREATE TABLE spbs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Event-SPG mapping
    await db.execute('''
      CREATE TABLE event_spgs (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        spg_id TEXT NOT NULL,
        spb_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (spg_id) REFERENCES spgs(id),
        FOREIGN KEY (spb_id) REFERENCES spbs(id)
      )
    ''');

    // Event-Product mapping
    await db.execute('''
      CREATE TABLE event_products (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Stock mutations
    await db.execute('''
      CREATE TABLE stock_mutations (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        spg_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        qty INTEGER NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (spg_id) REFERENCES spgs(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Sales
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        spg_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        qty_sold INTEGER NOT NULL DEFAULT 0,
        previous_qty INTEGER,
        updated_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (spg_id) REFERENCES spgs(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Cash records
    await db.execute('''
      CREATE TABLE cash_records (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        spg_id TEXT NOT NULL,
        cash_received REAL NOT NULL DEFAULT 0,
        qris_received REAL NOT NULL DEFAULT 0,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (spg_id) REFERENCES spgs(id)
      )
    ''');

    // Backup logs
    await db.execute('''
      CREATE TABLE backup_logs (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE events ADD COLUMN is_active INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('backup_logs');
      await txn.delete('cash_records');
      await txn.delete('sales');
      await txn.delete('stock_mutations');
      await txn.delete('event_products');
      await txn.delete('event_spgs');
      await txn.delete('spbs');
      await txn.delete('spgs');
      await txn.delete('products');
      await txn.delete('events');
    });
  }

  // Helper methods
  static String dateTimeToString(DateTime dateTime) =>
      dateTime.toIso8601String();
  static DateTime stringToDateTime(String string) => DateTime.parse(string);
}
