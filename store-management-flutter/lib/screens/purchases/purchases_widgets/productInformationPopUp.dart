// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/purchase_controller.dart';

import '../../../widgets/confirmAndcancel.dart';

class ProductInformationPopUp extends GetWidget<PurchaseController> {
  ProductInformationPopUp({
    Key? key,
    required this.index,
  }) : super(key: key);
  final TextStyle _textStyle = GoogleFonts.inter(
      textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ));

  final int index;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Product Information".tr,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("New Quantity".tr, style: _textStyle),
                    Container(
                        height: 36,
                        width: MediaQuery.of(context).size.width - 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: TextFormField(
                            style: _textStyle,
                            controller: controller.newQuantityController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Old cost".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(
                          child: Text(
                              controller.listOfPurchaseModel[index].cost,
                              style: _textStyle.copyWith(fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("New cost".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                          style: _textStyle,
                          controller: controller.newCostController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                GetBuilder<PurchaseController>(
                  builder: (controller) {
                    return GestureDetector(
                      onTap: () {
                        controller.totalAfterdeletItem(index);
                        controller.removeFromList(index);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Delete Product From List".tr,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GetBuilder<PurchaseController>(builder: (controller) {
                      return GestureDetector(
                          onTap: () {
                            Get.back();
                            controller.newvalu(index);
                            controller.newtotal(index);
                            controller.newtotalreselt(index);
                            controller.newCostController.clear();
                            controller.newQuantityController.clear();
                          },
                          child: ConfirmAndCancel(Opname: "Save".tr));
                    }),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.newCostController.clear();
                        controller.newQuantityController.clear();
                      },
                      child: ConfirmAndCancel(Opname: "Cancel".tr),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
