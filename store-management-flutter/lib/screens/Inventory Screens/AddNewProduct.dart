import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/widgets/barCode.dart';
import '../../controller/inventory_controller.dart';

class AddNewProductPage extends GetWidget<InventoryController> {
  AddNewProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Add New Product".tr,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1C2E), Color(0xFF243B55)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barcode Section
              Text(
                "Product Barcode/SN".tr,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.to(() => UnifiedBarcodeScanner(
                    title: "Scan Product Barcode",
                    onDetect: (code) async {
                      controller.result = code;
                      controller.update();
                      Get.back();
                      Get.snackbar(
                        "Code Scanned".tr, 
                        "Barcode captured successfully!",
                        backgroundColor: const Color(0xFF4FC3F7),
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162534),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3)),
                  ),
                  child: GetBuilder<InventoryController>(
                    builder: (controller) {
                      final hasBarcode = controller.result != null && controller.result!.isNotEmpty;
                      return Column(
                        children: [
                          Icon(
                            hasBarcode ? Icons.qr_code_rounded : Icons.qr_code_scanner_rounded,
                            size: 48,
                            color: hasBarcode ? const Color(0xFF4FC3F7) : Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasBarcode ? controller.result! : "Tap to Scan Barcode".tr,
                            style: GoogleFonts.inter(
                              color: hasBarcode ? Colors.white : Colors.white54,
                              fontSize: 16,
                              fontWeight: hasBarcode ? FontWeight.w700 : FontWeight.w500,
                              letterSpacing: hasBarcode ? 1.5 : 0,
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Form fields
              _buildField(
                controller: controller.productNameController,
                label: "Product Name".tr,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 20),

              _buildField(
                controller: controller.categoryController,
                label: "Category".tr,
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 20),

              // Date Picker
              GetBuilder<InventoryController>(
                builder: (controller) {
                  return GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2005),
                        lastDate: DateTime(2050),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF4FC3F7),
                                surface: Color(0xFF162534),
                              ),
                              dialogBackgroundColor: const Color(0xFF0F1C2E),
                            ),
                            child: child!,
                          );
                        },
                      ).then((value) {
                        if (value != null) controller.setDataTime(date: value);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: Color(0xFF4FC3F7), size: 22),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Expiration Date".tr, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                controller.dateTime != null 
                                  ? "${controller.dateTime!.day}/${controller.dateTime!.month}/${controller.dateTime!.year}"
                                  : "Select Date",
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Pricing & Stock
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: controller.costController,
                      label: "Cost".tr,
                      icon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: controller.priceController,
                      label: "Price".tr,
                      icon: Icons.sell_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: controller.quantityController,
                label: "Quantity".tr,
                icon: Icons.layers_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addNewProduct(
                      barcode: controller.result?.toString() ?? '',
                      itemName: controller.productNameController.text.toString(),
                      stockQuantity: controller.quantityController.text.toString(),
                      expirationDate: controller.dateTime.toString(),
                      cost: controller.costController.text.toString(),
                      category: controller.categoryController.text.toString(),
                      price: controller.priceController.text.toString()
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF81C784).withValues(alpha: 0.3),
                  ),
                  child: Text(
                    "SAVE PRODUCT".tr,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4FC3F7), size: 22),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
        ),
      ),
    );
  }
}
