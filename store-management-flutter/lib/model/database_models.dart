import 'package:get/get.dart';

// --- MASTERS ---

class CategoryModel {
  int? id;
  String name;
  String? remarks;
  int isActive;
  int subCatCount; // UI-only field

  CategoryModel({this.id, required this.name, this.remarks, this.isActive = 1, this.subCatCount = 0});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      remarks: map['remarks'],
      isActive: map['is_active'] ?? 1,
      subCatCount: map['sub_cat_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'remarks': remarks,
      'is_active': isActive,
    };
  }
}

class SubCategoryModel {
  int? id;
  int? categoryId;
  String categoryName; 
  String name;
  String? remarks;
  int isActive;
  int itemCount; // UI-only field

  SubCategoryModel({
    this.id,
    this.categoryId,
    this.categoryName = '',
    required this.name,
    this.remarks,
    this.isActive = 1,
    this.itemCount = 0,
  });

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      id: map['id'],
      categoryId: map['category_id'],
      categoryName: map['category_name'] ?? '',
      name: map['name'],
      remarks: map['remarks'],
      isActive: map['is_active'] ?? 1,
      itemCount: map['item_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'remarks': remarks,
      'is_active': isActive,
    };
  }
}

class BrandModel {
  int? id;
  String name;
  String? remarks;
  int isActive;

  BrandModel({this.id, required this.name, this.remarks, this.isActive = 1});

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'],
      name: map['name'],
      remarks: map['remarks'],
      isActive: map['is_active'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'remarks': remarks,
      'is_active': isActive,
    };
  }
}

class ItemModel {
  int? id;
  int? categoryId;
  int? subCategoryId;
  int? brandId;
  String categoryName;
  String subCategoryName;
  String brandName;
  String name;
  double ratePerQty;
  String? remarks;
  int isActive;

  ItemModel({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.categoryName = '',
    this.subCategoryName = '',
    this.brandName = '',
    required this.name,
    this.ratePerQty = 0,
    this.remarks,
    this.isActive = 1,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      categoryId: map['category_id'],
      subCategoryId: map['sub_category_id'],
      brandId: map['brand_id'],
      categoryName: map['category_name'] ?? '',
      subCategoryName: map['sub_category_name'] ?? '',
      brandName: map['brand_name'] ?? '',
      name: map['name'],
      ratePerQty: (map['rate_per_qty'] ?? 0).toDouble(),
      remarks: map['remarks'],
      isActive: map['is_active'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'brand_id': brandId,
      'name': name,
      'rate_per_qty': ratePerQty,
      'remarks': remarks,
      'is_active': isActive,
    };
  }
}

// --- VENDORS ---

class VendorModel {
  int? id;
  String companyName;
  String? address;
  String? city;
  String? pinCode;
  String? state;
  String? country;
  String? pan;
  String? gst;
  String? contactPerson;
  String? contactNumber;
  String? email;
  int isActive;

  VendorModel({
    this.id,
    required this.companyName,
    this.address,
    this.city,
    this.pinCode,
    this.state,
    this.country,
    this.pan,
    this.gst,
    this.contactPerson,
    this.contactNumber,
    this.email,
    this.isActive = 1,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'],
      companyName: map['company_name'],
      address: map['address'],
      city: map['city'],
      pinCode: map['pin_code'],
      state: map['state'],
      country: map['country'],
      pan: map['pan'],
      gst: map['gst'],
      contactPerson: map['contact_person'],
      contactNumber: map['contact_number'],
      email: map['email'],
      isActive: map['is_active'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'address': address,
      'city': city,
      'pin_code': pinCode,
      'state': state,
      'country': country,
      'pan': pan,
      'gst': gst,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'email': email,
      'is_active': isActive,
    };
  }
}

// --- PURCHASES ---

class PurchaseEntryModel {
  int? id;
  int categoryId;
  int subCategoryId;
  int itemId;
  int brandId;
  int? vendorId;
  String? size;
  String? description;
  double qty;
  double rate;
  double total;
  String purchaseDate;

  // Joined fields for UI
  String categoryName;
  String subCategoryName;
  String itemName;
  String brandName;
  String vendorName;

  PurchaseEntryModel({
    this.id,
    required this.categoryId,
    required this.subCategoryId,
    required this.itemId,
    required this.brandId,
    this.vendorId,
    this.size,
    this.description,
    required this.qty,
    required this.rate,
    required this.total,
    required this.purchaseDate,
    this.categoryName = '',
    this.subCategoryName = '',
    this.itemName = '',
    this.brandName = '',
    this.vendorName = '',
  });

  factory PurchaseEntryModel.fromMap(Map<String, dynamic> map) {
    return PurchaseEntryModel(
      id: map['id'],
      categoryId: map['category_id'],
      subCategoryId: map['sub_category_id'],
      itemId: map['item_id'],
      brandId: map['brand_id'],
      vendorId: map['vendor_id'],
      size: map['size'],
      description: map['description'],
      qty: (map['qty'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      purchaseDate: map['purchase_date'],
      categoryName: map['category_name'] ?? '',
      subCategoryName: map['sub_category_name'] ?? '',
      itemName: map['item_name'] ?? '',
      brandName: map['brand_name'] ?? '',
      vendorName: map['vendor_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'item_id': itemId,
      'brand_id': brandId,
      'vendor_id': vendorId,
      'size': size,
      'description': description,
      'qty': qty,
      'rate': rate,
      'total': total,
      'purchase_date': purchaseDate,
    };
  }
}

// --- SALES ---

class SaleModel {
  int? id;
  String customerName;
  String mobileNumber;
  double totalAmount;
  double discount;
  double netPayable;
  String saleDate;

  SaleModel({
    this.id,
    this.customerName = '',
    this.mobileNumber = '',
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.netPayable = 0.0,
    required this.saleDate,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      customerName: map['customer_name'] ?? '',
      mobileNumber: map['mobile_number'] ?? '',
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      netPayable: (map['net_payable'] ?? 0.0).toDouble(),
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
  int saleId;
  int? bundleId;
  int? itemId;
  double qty;
  double rate;
  double total;

  SaleItemModel({
    this.id,
    required this.saleId,
    this.bundleId,
    this.itemId,
    required this.qty,
    required this.rate,
    required this.total,
  });

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'],
      saleId: map['sale_id'],
      bundleId: map['bundle_id'],
      itemId: map['item_id'],
      qty: (map['qty'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'bundle_id': bundleId,
      'item_id': itemId,
      'qty': qty,
      'rate': rate,
      'total': total,
    };
  }
}

// --- BUNDLES ---

class BundleModel {
  int? id;
  String bundleName;
  String? description;
  double price;
  int isActive;

  BundleModel({
    this.id,
    required this.bundleName,
    this.description,
    this.price = 0.0,
    this.isActive = 1,
  });

  factory BundleModel.fromMap(Map<String, dynamic> map) {
    return BundleModel(
      id: map['id'],
      bundleName: map['bundle_name'] ?? '',
      description: map['description'],
      price: (map['price'] ?? 0.0).toDouble(),
      isActive: map['is_active'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bundle_name': bundleName,
      'description': description,
      'price': price,
      'is_active': isActive,
    };
  }
}

class BundleItemModel {
  int? id;
  int bundleId;
  int itemId;
  double qty;
  
  // Joined fields for UI
  String itemName;

  BundleItemModel({
    this.id,
    required this.bundleId,
    required this.itemId,
    required this.qty,
    this.itemName = '',
  });

  factory BundleItemModel.fromMap(Map<String, dynamic> map) {
    return BundleItemModel(
      id: map['id'],
      bundleId: map['bundle_id'],
      itemId: map['item_id'],
      qty: (map['qty'] as num).toDouble(),
      itemName: map['item_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bundle_id': bundleId,
      'item_id': itemId,
      'qty': qty,
    };
  }
}

// --- STOCK ---

class StockMovementModel {
  int? id;
  int itemId;
  double qtyChange;
  String reason; // Direct mapping to 'reason' column (prev 'movement_type')
  int? referenceId;
  String movementDate;

  StockMovementModel({
    this.id,
    required this.itemId,
    required this.qtyChange,
    required this.reason,
    this.referenceId,
    required this.movementDate,
  });

  factory StockMovementModel.fromMap(Map<String, dynamic> map) {
    return StockMovementModel(
      id: map['id'],
      itemId: map['item_id'],
      qtyChange: (map['qty_change'] as num).toDouble(),
      reason: map['reason'] ?? '',
      referenceId: map['reference_id'],
      movementDate: map['movement_date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'qty_change': qtyChange,
      'reason': reason,
      'reference_id': referenceId,
      'movement_date': movementDate,
    };
  }
}
