import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_models.dart';

class BundlesDb {
  static Future<List<BundleModel>> getAllBundles() async {
    final db = await AppDatabase.instance;
    final res = await db.query('bundles', orderBy: 'bundle_name ASC');
    return res.map((m) => BundleModel.fromMap(m)).toList();
  }

  static Future<List<Map<String, dynamic>>> getBundleItems(int bundleId) async {
    final db = await AppDatabase.instance;
    return await db.rawQuery('''
      SELECT 
        bi.*, 
        i.name as item_name, 
        c.name as category_name, 
        sc.name as sub_category_name,
        b.name as brand_name
      FROM bundle_items bi
      JOIN items i ON bi.item_id = i.id
      LEFT JOIN categories c ON bi.category_id = c.id
      LEFT JOIN sub_categories sc ON bi.sub_category_id = sc.id
      LEFT JOIN brands b ON bi.brand_id = b.id
      WHERE bi.bundle_id = ?
    ''', [bundleId]);
  }
}

