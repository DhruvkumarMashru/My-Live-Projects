import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/inventroy_model.dart';

class InventoryDb {
  static const _dbName = 'inventory.db';
  static const _dbVersion = 1;
  static const _tableInventory = 'inventory';

  static Database? _db;

  static Future<Database> _openDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableInventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode TEXT NOT NULL,
            item_name TEXT NOT NULL,
            stock_quantity TEXT NOT NULL,
            expiration_date TEXT,
            cost TEXT NOT NULL,
            category TEXT,
            price TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<List<InventoryModel>> getAllProducts() async {
    final db = await _openDb();
    final rows = await db.query(_tableInventory, orderBy: 'item_name ASC');
    return rows
        .map((e) => InventoryModel.fromJson(e..['dateTime'] = e['expiration_date']))
        .toList();
  }

  static Future<List<InventoryModel>> searchByField({
    required String field,
    required String value,
  }) async {
    final db = await _openDb();
    final rows = await db.query(
      _tableInventory,
      where: '$field LIKE ?',
      whereArgs: ['%$value%'],
      orderBy: 'item_name ASC',
    );
    return rows
        .map((e) => InventoryModel.fromJson(e..['dateTime'] = e['expiration_date']))
        .toList();
  }

  static Future<int> insertProduct({
    required String barcode,
    required String itemName,
    required String stockQuantity,
    required String expirationDate,
    required String cost,
    required String category,
    required String price,
  }) async {
    final db = await _openDb();
    return db.insert(_tableInventory, {
      'barcode': barcode,
      'item_name': itemName,
      'stock_quantity': stockQuantity,
      'expiration_date': expirationDate,
      'cost': cost,
      'category': category,
      'price': price,
    });
  }

  static Future<int> deleteProduct(int id) async {
    final db = await _openDb();
    return db.delete(
      _tableInventory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

