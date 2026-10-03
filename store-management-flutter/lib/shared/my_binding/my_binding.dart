import 'package:get/get.dart';
import 'package:store_management_modern/controller/demo_controller.dart';
import 'package:store_management_modern/controller/account_controller.dart';
import 'package:store_management_modern/controller/inventory_controller.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/controller/performance_controller.dart';
import 'package:store_management_modern/controller/sales_controller.dart';
import 'package:store_management_modern/controller/supplier_controller.dart';
import '../../controller/purchase_controller.dart';
import '../../localization/Local_controller.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DemoController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => InventoryController(), fenix: true);
    Get.lazyPut(() => SupplierController(), fenix: true);
    Get.lazyPut(() => AccountController(), fenix: true);
    Get.lazyPut(() => PerformanceController(), fenix: true);
    Get.lazyPut(() => PurchaseController(), fenix: true);
    Get.lazyPut(() => SalesController(), fenix: true);
    Get.lazyPut(() => MyLocaleController(), fenix: true);
  }
}
