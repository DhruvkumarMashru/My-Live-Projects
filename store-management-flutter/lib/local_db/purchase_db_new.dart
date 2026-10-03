import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_models.dart';

class PurchaseDbNew {
  static Future<int> insertPurchase(PurchaseEntryModel model) async {
    final db = await AppDatabase.instance;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('purchases', model.toMap());
      
      // Also record in stock movements
      await txn.insert('stock_movements', {
        'item_id': model.itemId,
        'qty_change': model.qty,
        'reason': 'PURCHASE',
        'reference_id': id,
        'movement_date': model.purchaseDate,
      });
    });
    return id;
  }

  static Future<List<PurchaseEntryModel>> getAllPurchases() async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT p.*, 
             c.name as category_name, 
             sc.name as sub_category_name, 
             i.name as item_name, 
             b.name as brand_name,
             v.company_name as vendor_name
      FROM purchases p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN sub_categories sc ON p.sub_category_id = sc.id
      LEFT JOIN items i ON p.item_id = i.id
      LEFT JOIN brands b ON p.brand_id = b.id
      LEFT JOIN vendors v ON p.vendor_id = v.id
      ORDER BY p.purchase_date DESC
    ''');
    return res.map((m) => PurchaseEntryModel.fromMap(m)).toList();
  }

  static Future<double> getAvailableStockForItem(int itemId) async {
    final db = await AppDatabase.instance;
    
    // Total change from stock movements (Purchases are positive, Sales/BOM negative)
    final res = await db.rawQuery('SELECT SUM(qty_change) as total_change FROM stock_movements WHERE item_id = ?', [itemId]);
    
    if (res.isNotEmpty && res.first['total_change'] != null) {
      return (res.first['total_change'] as num).toDouble();
    }
    return 0.0;
  }
}
