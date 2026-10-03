// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_management_modern/model/inventroy_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../local_db/inventory_db.dart';
import '../shared/app_feedback.dart';
import '../shared/constants.dart';
import '../shared/dummy_data.dart';

class InventoryController extends GetxController {
  // ********* Variables ***********
  List<InventoryModel> productsList = [];
  RxBool isThereData = false.obs;
  DateTime? dateTime = DateTime.now();
  String? result;
  final MobileScannerController scannerController = MobileScannerController();

  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  // ******************** Methods ***********************************

  @override
  onInit() {
    super.onInit();
    getProductList();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
  //============ Delete Product ============

  deleteProduct(int id) async {
    isThereData.value = false;
    try {
      await InventoryDb.deleteProduct(id);
      productsList.removeWhere((element) => element.id == id);
      update();
    } catch (e) {
      AppFeedback.error("Something went wrong. Please try again.");
      return;
    }
  }

  // ========= Get The List Of Product =========
  getProductList() async {
    try {
      await DummyData.injectLocalInventoryIfEmpty();
      productsList = await InventoryDb.getAllProducts();
      update();
    } catch (e) {
      AppFeedback.error("Couldn’t load products. Please try again.");
      return;
    }
  }

  // ========= Add New Product =========
  addNewProduct({
    required String barcode,
    required String itemName,
    required String stockQuantity,
    required String expirationDate,
    required String cost,
    required String category,
    required String price,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) => Center(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    color: kprimaryColor,
                    backgroundColor: kprimaryColor,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Save".tr,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      await InventoryDb.insertProduct(
        barcode: barcode,
        itemName: itemName,
        stockQuantity: stockQuantity,
        expirationDate: expirationDate,
        cost: cost,
        category: category,
        price: price,
      );

      productsList = await InventoryDb.getAllProducts();

      Get.back();
      clearText();

      return Get.snackbar("Done".tr, "Success process".tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.back();
      AppFeedback.error("Couldn’t save. Please try again.");
      return;
    }
  }

  //==================Delete From List ===============
  removeFromList(int index) {
    productsList.removeAt(index);
    update();
  }

  // =========== To Clear All TextEditingController ==============
  clearText() {
    categoryController.clear();
    productNameController.clear();
    costController.clear();
    priceController.clear();
    quantityController.clear();
  }

  // ========= QR / Bar Code Method =========
  void onBarcodeDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    final code = barcodes.isNotEmpty ? barcodes.first.rawValue : null;

    if (code != null && code.isNotEmpty) {
      result = code;
      update();
    }
  }

  // ========= Set Date Time =========
  setDataTime({required DateTime date}) {
    dateTime = date;
    update();
  }

  // getResult() {
  //   barcoderesult = result.toString();
  //   update();
  // }
}
