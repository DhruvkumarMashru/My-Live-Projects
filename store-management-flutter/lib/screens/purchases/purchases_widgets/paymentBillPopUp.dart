// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/screens/purchases/purchases_widgets/purchase_search_supplier.dart';

import '../../../controller/purchase_controller.dart';
import '../../../shared/constants.dart';
import '../../../widgets/confirmAndcancel.dart';

class PaymentBillPopUp extends GetWidget<PurchaseController> {
  PaymentBillPopUp({
    Key? key,
  }) : super(key: key);

  final TextStyle _textStyle = GoogleFonts.inter(
      textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ));

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
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text("Payment Bill".tr,
                        style: GoogleFonts.inter(
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary))),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Total".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(
                          child: Text(controller.totalresute.toString(),
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Payed".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(
                          child: TextFormField(
                              onEditingComplete: () {
                                controller.change = (double.parse(
                                        controller.payedController.text) -
                                    controller.totalresute);
                                FocusScope.of(context).unfocus();
                              },
                              controller: controller.payedController,
                              autofocus: false,
                              style: _textStyle,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Change".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(
                          child: Text(controller.change.toString(),
                              style: _textStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Save This Bill To A Supplier Account".tr,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: PurchaseSearchSupplier(
                                  apiPath: apiSuppliers, nameAtapi: "name"));
                        },
                        icon: const Icon(Icons.search))
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Supplier Name".tr, style: _textStyle),
                    Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width - 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Center(
                        child: GetBuilder<PurchaseController>(
                          builder: (controller) {
                            return controller.purchaseMap.isNotEmpty
                                ? Text(
                                    controller.purchaseMap['name'].toString(),
                                    style: _textStyle.copyWith(fontWeight: FontWeight.bold))
                                : Text("Search Result".tr, style: _textStyle.copyWith(color: Theme.of(context).hintColor));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          controller.payment(
                              paymentData: controller.listOfPurchaseModel,
                              supplier_id: controller.purchaseMap['id']);
                          Get.back();
                          controller.totalOnsave();
                          Get.snackbar("Done".tr, "Success process".tr,
                              backgroundColor: Theme.of(context).cardColor,
                              colorText: Theme.of(context).textTheme.bodyLarge?.color,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2));
                        },
                        child: ConfirmAndCancel(Opname: "Save".tr)),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.payedController.clear();
                        controller.change = 0;
                        controller.purchaseMap.clear();
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
