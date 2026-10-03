import 'package:store_management_modern/local_db/app_database.dart';
import 'package:sqflite/sqflite.dart';

class SaleModel {
  int? id;
  String customerName;
  String? mobileNumber;
  double totalAmount;
  double discount;
  double netPayable;
  String saleDate;

  SaleModel({
    this.id,
    required this.customerName,
    this.mobileNumber,
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.netPayable = 0.0,
    required this.saleDate,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      customerName: map['customer_name'],
      mobileNumber: map['mobile_number'],
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      netPayable: map['net_payable']?.toDouble() ?? 0.0,
      saleDate: map['sale_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'mobile_number': mobileNumber,
      'total_amount': totalAmount,
      'discount': discount,
      'net_payable': netPayable,
      'sale_date': saleDate,
    };
  }
}

class SaleItemModel {
  int? id;
  int? saleId;
  int? bundleId;
  int? categoryId;
  int? subCategoryId;
  int? itemId;
  double qty;
  double rate;
  double total;
  
  // For UI/Invoices
  String? categoryName;
  String? subCategoryName;
  String? itemName;
  String? bundleName;
  String? brandName;

  SaleItemModel({
    this.id,
    this.saleId,
    this.bundleId,
    this.categoryId,
    this.subCategoryId,
    this.itemId,
    required this.qty,
    required this.rate,
    required this.total,
    this.categoryName,
    this.subCategoryName,
    this.itemName,
    this.bundleName,
    this.brandName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'bundle_id': bundleId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'item_id': itemId,
      'qty': qty,
      'rate': rate,
      'total': total,
    };
  }
}

class SalesDb {
  static Future<int> insertSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await AppDatabase.instance;
    int saleId = 0;
    
    await db.transaction((txn) async {
      saleId = await txn.insert('sales', sale.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      for (var item in items) {
        item.saleId = saleId;
        await txn.insert('sale_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return saleId;
  }

  static Future<Map<String, dynamic>?> getSaleFullDetails(int saleId) async {
    final db = await AppDatabase.instance;
    final sale = await db.query('sales', where: 'id = ?', whereArgs: [saleId]);
    if (sale.isEmpty) return null;

    final items = await db.rawQuery('''
      SELECT 
        si.*, 
        c.name as category_name, 
        sc.name as sub_category_name, 
        i.name as item_name,
        b.bundle_name as bundle_name,
        br.name as brand_name
      FROM sale_items si
      LEFT JOIN categories c ON si.category_id = c.id
      LEFT JOIN sub_categories sc ON si.sub_category_id = sc.id
      LEFT JOIN items i ON si.item_id = i.id
      LEFT JOIN bundles b ON si.bundle_id = b.id
      LEFT JOIN brands br ON i.brand_id = br.id
      WHERE si.sale_id = ?
    ''', [saleId]);

    return {
      'sale': SaleModel.fromMap(sale.first),
      'items': items.map((it) => SaleItemModel(
        id: it['id'] as int?,
        saleId: it['sale_id'] as int?,
        bundleId: it['bundle_id'] as int?,
        categoryId: it['category_id'] as int?,
        subCategoryId: it['sub_category_id'] as int?,
        itemId: it['item_id'] as int?,
        qty: (it['qty'] as num).toDouble(),
        rate: (it['rate'] as num).toDouble(),
        total: (it['total'] as num).toDouble(),
        categoryName: it['category_name']?.toString(),
        subCategoryName: it['sub_category_name']?.toString(),
        itemName: it['item_name']?.toString(),
        bundleName: it['bundle_name']?.toString(),
        brandName: it['brand_name']?.toString(),
      )).toList(),
    };
  }

  static Future<List<SaleModel>> getAllSales() async {
    final db = await AppDatabase.instance;
    final res = await db.query('sales', orderBy: 'sale_date DESC');
    return res.map((m) => SaleModel.fromMap(m)).toList();
  }
}

