import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_models.dart';

class VendorDb {
  static Future<int> insertVendor(VendorModel model) async {
    final db = await AppDatabase.instance;
    return await db.insert('vendors', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<VendorModel>> getAllVendors() async {
    final db = await AppDatabase.instance;
    final res = await db.query('vendors', orderBy: 'company_name ASC');
    return res.map((m) => VendorModel.fromMap(m)).toList();
  }

  static Future<int> updateVendor(VendorModel model) async {
    final db = await AppDatabase.instance;
    return await db.update('vendors', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  static Future<int> deleteVendor(int id) async {
    final db = await AppDatabase.instance;
    return await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
  }
}
