import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../model/database_models.dart';

// DAO
class MastersDb {
  // Category
  static Future<int> insertCategory(CategoryModel model) async {
    final db = await AppDatabase.instance;
    return await db.insert('categories', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CategoryModel>> getAllCategories() async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT c.*, (SELECT COUNT(*) FROM sub_categories WHERE category_id = c.id) as sub_cat_count
      FROM categories c
      ORDER BY c.name ASC
    ''');
    return res.map((m) => CategoryModel.fromMap(m)).toList();
  }

  static Future<int> updateCategory(CategoryModel model) async {
    final db = await AppDatabase.instance;
    return await db.update('categories', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  // Sub Category
  static Future<int> insertSubCategory(SubCategoryModel model) async {
    final db = await AppDatabase.instance;
    return await db.insert('sub_categories', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<SubCategoryModel>> getAllSubCategories() async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT sc.*, c.name as category_name, (SELECT COUNT(*) FROM items WHERE sub_category_id = sc.id) as item_count
      FROM sub_categories sc
      LEFT JOIN categories c ON sc.category_id = c.id
      ORDER BY sc.name ASC
    ''');
    return res.map((m) => SubCategoryModel.fromMap(m)).toList();
  }

  static Future<List<SubCategoryModel>> getSubCategoriesByCategoryId(int catId) async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT sc.*, c.name as category_name, (SELECT COUNT(*) FROM items WHERE sub_category_id = sc.id) as item_count
      FROM sub_categories sc
      LEFT JOIN categories c ON sc.category_id = c.id
      WHERE sc.category_id = ?
      ORDER BY sc.name ASC
    ''', [catId]);
    return res.map((m) => SubCategoryModel.fromMap(m)).toList();
  }

  static Future<int> updateSubCategory(SubCategoryModel model) async {
    final db = await AppDatabase.instance;
    return await db.update('sub_categories', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  // Brand
  static Future<int> insertBrand(BrandModel model) async {
    final db = await AppDatabase.instance;
    return await db.insert('brands', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<BrandModel>> getAllBrands() async {
    final db = await AppDatabase.instance;
    final res = await db.query('brands', orderBy: 'name ASC');
    return res.map((m) => BrandModel.fromMap(m)).toList();
  }

  static Future<int> updateBrand(BrandModel model) async {
    final db = await AppDatabase.instance;
    return await db.update('brands', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  // Item
  static Future<int> insertItem(ItemModel model) async {
    final db = await AppDatabase.instance;
    return await db.insert('items', model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ItemModel>> getAllItems() async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT i.*, b.name as brand_name, c.name as category_name, sc.name as sub_category_name
      FROM items i
      LEFT JOIN brands b ON i.brand_id = b.id
      LEFT JOIN categories c ON i.category_id = c.id
      LEFT JOIN sub_categories sc ON i.sub_category_id = sc.id
      ORDER BY i.name ASC
    ''');
    return res.map((m) => ItemModel.fromMap(m)).toList();
  }

  static Future<List<ItemModel>> getItemsBySubCategory(int subCatId) async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT i.*, b.name as brand_name, c.name as category_name, sc.name as sub_category_name
      FROM items i
      LEFT JOIN brands b ON i.brand_id = b.id
      LEFT JOIN categories c ON i.category_id = c.id
      LEFT JOIN sub_categories sc ON i.sub_category_id = sc.id
      WHERE i.sub_category_id = ?
      ORDER BY i.name ASC
    ''', [subCatId]);
    return res.map((m) => ItemModel.fromMap(m)).toList();
  }

  static Future<int> updateItem(ItemModel model) async {
    final db = await AppDatabase.instance;
    return await db.update('items', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }
}
