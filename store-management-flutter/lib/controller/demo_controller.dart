import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_db/app_database.dart';
import '../local_db/masters_db.dart';
import '../local_db/sales_db_new.dart';
import '../model/database_models.dart';
import '../main.dart';

class DemoController extends GetxController {
  var isDemoMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDemoMode.value = shaedpref.getBool('isDemoMode') ?? false;
  }

  Future<void> toggleDemoMode(bool value) async {
    if (value) {
      await _enableDemoMode();
    } else {
      await _disableDemoMode();
    }
  }

  Future<void> _enableDemoMode() async {
    await AppDatabase.truncateAll();

    // 1. Company Profile
    final db = await AppDatabase.instance;
    await db.insert('company_profile', {
      'id': 1,
      'company_name': 'Global Tech Solutions',
      'address': '101, Business Park, Silicon Valley',
      'city': 'New York',
      'pin_code': '100001',
      'state': 'NY',
      'country': 'USA',
      'contact_person': 'John Doe',
      'contact_number': '1234567890',
      'email': 'demo@globaltech.com',
      'business_number': '9876543210',
      'pan': 'ABCDE1234F',
      'gst': '22AAAAA0000A1Z5',
      'business_description': 'Leading Electronics & Software Provider',
    });

    // 2. Categories & SubCategories
    int catId = await MastersDb.insertCategory(CategoryModel(name: 'Electronics', remarks: 'Gadgets and devices'));
    await MastersDb.insertSubCategory(SubCategoryModel(categoryId: catId, name: 'Smartphones', remarks: 'Mobile devices'));
    await MastersDb.insertSubCategory(SubCategoryModel(categoryId: catId, name: 'Laptops', remarks: 'Computing devices'));

    int catId2 = await MastersDb.insertCategory(CategoryModel(name: 'Appliances', remarks: 'Home appliances'));
    await MastersDb.insertSubCategory(SubCategoryModel(categoryId: catId2, name: 'Refrigerators', remarks: 'Cooling units'));
    await MastersDb.insertSubCategory(SubCategoryModel(categoryId: catId2, name: 'Ovens', remarks: 'Kitchen gadgets'));

    // 3. Brands
    int brandId1 = await MastersDb.insertBrand(BrandModel(name: 'TechPro', remarks: 'Flagship brand'));
    int brandId2 = await MastersDb.insertBrand(BrandModel(name: 'LuxeHome', remarks: 'Premium appliances'));

    // 4. Items
    for (int i = 1; i <= 5; i++) {
        await MastersDb.insertItem(ItemModel(
            categoryId: catId,
            subCategoryId: 1,
            brandId: brandId1,
            name: 'Smartphone Model X$i',
            ratePerQty: 25000.0 + (i * 1000),
            remarks: 'Demo Item $i',
            isActive: 1,
        ));
    }

    for (int i = 1; i <= 5; i++) {
        await MastersDb.insertItem(ItemModel(
            categoryId: catId2,
            subCategoryId: 3,
            brandId: brandId2,
            name: 'Deluxe Fridge v$i',
            ratePerQty: 45000.0 + (i * 2000),
            remarks: 'Demo Appliance $i',
            isActive: 1,
        ));
    }

    // 5. Vendor
    await db.insert('vendors', {
        'company_name': 'Prime Supplies Inc.',
        'contact_person': 'Alice Smith',
        'contact_number': '5557788990',
        'email': 'sales@primesupplies.com',
        'address': 'Industrial Zone A',
        'city': 'Chicago',
        'is_active': 1,
    });

    // 6. Dummy Sales
    for (int i = 1; i <= 3; i++) {
        final sale = SaleModel(
            customerName: 'Customer $i',
            mobileNumber: '998877665$i',
            totalAmount: 50000.0 * i,
            netPayable: 50000.0 * i,
            saleDate: DateTime.now().toIso8601String(),
        );
        
        List<SaleItemModel> items = [
            SaleItemModel(saleId: 0, itemId: 1, qty: 1, rate: 30000, total: 30000),
        ];

        await SalesDbNew.processSale(sale, items);
    }

    isDemoMode.value = true;
    await shaedpref.setBool('isDemoMode', true);
  }

  Future<void> _disableDemoMode() async {
    await AppDatabase.truncateAll();
    isDemoMode.value = false;
    await shaedpref.setBool('isDemoMode', false);
  }
}
