// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors
// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:store_management_modern/widgets/smallButton.dart';
import '../../../controller/inventory_controller.dart';

class AddBarCode extends GetWidget<InventoryController> {
  const AddBarCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<InventoryController>(builder: (controller) {
          return Column(
            children: [
              GetBuilder<InventoryController>(
                builder: (controller) {
                  return Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MobileScanner(
                        controller: controller.scannerController,
                        onDetect: controller.onBarcodeDetect,
                      ),
                    ),
                  );
                },
              ),
              GetBuilder<InventoryController>(
                builder: (controller) {
                  return Expanded(
                    flex: 1,
                    child: Center(
                      child: (controller.result != null)
                          ? Text(
                              '${controller.result!.toString()} Now click on search')
                          : const Text(
                              'Touch the screen and point the camera to Scan a code'),
                    ),
                  );
                },
              ),
              GestureDetector(
                  onTap: () {
                    Get.back();
                    // showSearch(
                    //     context: context,
                    //     // delegate to customize the search bar
                    //     delegate: CustomSearchDelegate());
                  }, //search
                  child: SmallButton(buttonName: "Done")),
              Spacer()
            ],
          );
        }),
      ),
    );
  }
}
