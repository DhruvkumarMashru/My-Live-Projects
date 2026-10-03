import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'store_app_modern.db';
  static const _dbVersion = 6;

  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDb,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE purchases ADD COLUMN vendor_id INTEGER REFERENCES vendors(id)');
          } catch (_) {} 
        }
        if (oldVersion < 6) {
          // Add indexes for performance
          await db.execute('CREATE INDEX IF NOT EXISTS idx_stock_item ON stock_movements(item_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_purchase_item ON purchases(item_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sale_item ON sale_items(item_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_items_cat ON items(category_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_items_subcat ON items(sub_category_id)');
        }
      },
    );
  }

  static Future<void> truncateAll() async {
    final db = await instance;
    await db.transaction((txn) async {
      await txn.delete('stock_movements');
      await txn.delete('sale_items');
      await txn.delete('sales');
      await txn.delete('bundle_items');
      await txn.delete('bundles');
      await txn.delete('purchases');
      await txn.delete('vendors');
      await txn.delete('items');
      await txn.delete('brands');
      await txn.delete('sub_categories');
      await txn.delete('categories');
      await txn.delete('company_profile');
    });
  }

  static Future<void> await_dropDb(Database db) async {
      await db.execute('DROP TABLE IF EXISTS stock_movements');
      await db.execute('DROP TABLE IF EXISTS sale_items');
      await db.execute('DROP TABLE IF EXISTS sales');
      await db.execute('DROP TABLE IF EXISTS bundle_items');
      await db.execute('DROP TABLE IF EXISTS bundles');
      await db.execute('DROP TABLE IF EXISTS purchases');
      await db.execute('DROP TABLE IF EXISTS vendors');
      await db.execute('DROP TABLE IF EXISTS items');
      await db.execute('DROP TABLE IF EXISTS brands');
      await db.execute('DROP TABLE IF EXISTS sub_categories');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS company_profile');
  }

  static Future<void> _createDb(Database db, int version) async {
    // 1. Company Profile
    await db.execute('''
      CREATE TABLE company_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        logo_path TEXT,
        photo_path TEXT,
        company_name TEXT,
        address TEXT,
        city TEXT,
        pin_code TEXT,
        state TEXT,
        country TEXT,
        contact_person TEXT,
        contact_number TEXT,
        email TEXT,
        business_number TEXT,
        pan TEXT,
        gst TEXT,
        registration_number TEXT,
        licence_number TEXT,
        business_description TEXT,
        website TEXT,
        linkedin TEXT,
        instagram TEXT,
        facebook TEXT,
        x_platform TEXT,
        miscellaneous TEXT
      )
    ''');


    // 2. Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        remarks TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // 3. Sub Categories
    await db.execute('''
      CREATE TABLE sub_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        remarks TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // 4. Brands
    await db.execute('''
      CREATE TABLE brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        remarks TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // 5. Items
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        sub_category_id INTEGER,
        brand_id INTEGER,
        name TEXT NOT NULL,
        rate_per_qty REAL DEFAULT 0,
        remarks TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id),
        FOREIGN KEY (brand_id) REFERENCES brands (id)
      )
    ''');

    // 6. Vendors
    await db.execute('''
      CREATE TABLE vendors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT NOT NULL,
        address TEXT,
        city TEXT,
        pin_code TEXT,
        state TEXT,
        country TEXT,
        pan TEXT,
        gst TEXT,
        contact_person TEXT,
        contact_number TEXT,
        email TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // 7. Purchases (Stock In)
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        sub_category_id INTEGER,
        item_id INTEGER,
        brand_id INTEGER,
        size TEXT,
        description TEXT,
        vendor_id INTEGER,
        qty REAL NOT NULL,
        rate REAL NOT NULL,
        total REAL NOT NULL,
        purchase_date TEXT,
        FOREIGN KEY (vendor_id) REFERENCES vendors (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id),
        FOREIGN KEY (item_id) REFERENCES items (id),
        FOREIGN KEY (brand_id) REFERENCES brands (id)
      )
    ''');

    // 8. Bundles (Combo)
    await db.execute('''
      CREATE TABLE bundles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bundle_name TEXT NOT NULL,
        description TEXT,
        price REAL DEFAULT 0,
        remarks TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // 9. Bundle Items (Components)
    await db.execute('''
      CREATE TABLE bundle_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bundle_id INTEGER,
        category_id INTEGER,
        sub_category_id INTEGER,
        item_id INTEGER,
        brand_id INTEGER,
        qty REAL NOT NULL,
        FOREIGN KEY (bundle_id) REFERENCES bundles (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id),
        FOREIGN KEY (item_id) REFERENCES items (id),
        FOREIGN KEY (brand_id) REFERENCES brands (id)
      )
    ''');

    // 10. Sales
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        mobile_number TEXT,
        total_amount REAL,
        discount REAL,
        net_payable REAL,
        sale_date TEXT
      )
    ''');

    // 11. Sale Items
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        bundle_id INTEGER,
        category_id INTEGER,
        sub_category_id INTEGER,
        item_id INTEGER,
        qty REAL NOT NULL,
        rate REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (bundle_id) REFERENCES bundles (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // 12. Stock Movements
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER,
        qty_change REAL NOT NULL,
        reason TEXT,
        reference_id INTEGER,
        movement_date TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Create Indexes
    await db.execute('CREATE INDEX idx_stock_item ON stock_movements(item_id)');
    await db.execute('CREATE INDEX idx_purchase_item ON purchases(item_id)');
    await db.execute('CREATE INDEX idx_sale_item ON sale_items(item_id)');
    await db.execute('CREATE INDEX idx_items_cat ON items(category_id)');
    await db.execute('CREATE INDEX idx_items_subcat ON items(sub_category_id)');
  }
}
