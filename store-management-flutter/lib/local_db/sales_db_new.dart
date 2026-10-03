import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_models.dart';

// DATABASE LOGIC
class SalesDbNew {
  // --- BUNDLES ---
  static Future<int> insertBundle(BundleModel bundle, List<BundleItemModel> items) async {
    final db = await AppDatabase.instance;
    int bundleId = 0;
    
    await db.transaction((txn) async {
      bundleId = await txn.insert('bundles', bundle.toMap());
      for (var item in items) {
        item.bundleId = bundleId;
        await txn.insert('bundle_items', item.toMap());
      }
    });
    
    return bundleId;
  }

  static Future<List<BundleModel>> getAllBundles() async {
    final db = await AppDatabase.instance;
    final res = await db.query('bundles', orderBy: 'bundle_name ASC');
    return res.map((m) => BundleModel.fromMap(m)).toList();
  }

  static Future<List<BundleItemModel>> getBundleItems(int bundleId) async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT bi.*, i.name as item_name
      FROM bundle_items bi
      LEFT JOIN items i ON bi.item_id = i.id
      WHERE bi.bundle_id = ?
    ''', [bundleId]);
    return res.map((m) => BundleItemModel.fromMap(m)).toList();
  }

  // --- SALES ---
  static Future<int> processSale(SaleModel sale, List<SaleItemModel> saleItems) async {
    final db = await AppDatabase.instance;
    int saleId = 0;
    
    await db.transaction((txn) async {
      // 1. Insert the Sale record
      saleId = await txn.insert('sales', sale.toMap());
      
      // 2. Insert items and handle stock deduction
      for (var item in saleItems) {
        item.saleId = saleId;
        await txn.insert('sale_items', item.toMap());
        
        if (item.itemId != null) {
          // It's a single item -> Register direct stock movement
          await txn.insert('stock_movements', {
            'item_id': item.itemId,
            'qty_change': -(item.qty),
            'reason': 'SALE', // Consistent with app_database schema
            'reference_id': saleId,
            'movement_date': sale.saleDate,
          });
        } 
        else if (item.bundleId != null) {
          // It's a bundle -> Deduct all sub-items based on BOM calculation
          final bItems = await txn.query('bundle_items', where: 'bundle_id = ?', whereArgs: [item.bundleId]);
          for (var bi in bItems) {
            double reqQty = (bi['qty'] as num).toDouble();
            double totalDeduct = reqQty * item.qty; // Bundle req * number of bundles sold
            
            await txn.insert('stock_movements', {
              'item_id': bi['item_id'],
              'qty_change': -totalDeduct,
              'reason': 'BOM_SALE',
              'reference_id': saleId,
              'movement_date': sale.saleDate,
            });
          }
        }
      }
    });
    
    return saleId;
  }
}
