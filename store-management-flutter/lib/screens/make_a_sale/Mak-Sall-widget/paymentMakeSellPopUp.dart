import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/sales_controller.dart';
import 'package:store_management_modern/screens/make_a_sale/cashierScreens.dart';

class PaymentMakeSellPopUp extends StatefulWidget {
  const PaymentMakeSellPopUp({Key? key}) : super(key: key);

  @override
  State<PaymentMakeSellPopUp> createState() => _PaymentMakeSellPopUpState();
}

class _PaymentMakeSellPopUpState extends State<PaymentMakeSellPopUp> {
  final _salesController = Get.find<SalesController>();
  String? _selectedBuyer;

  // Dummy testing data for Buyers
  final List<String> _dummyBuyers = [
    "Walk-in Customer",
    "John Doe",
    "Acme Corp",
    "Global Tech",
    "Jane Smith",
    "Apex Solutions",
    "Retail Partner A",
    "Retail Partner B",
    "Local Shop 1",
    "Local Shop 2"
  ];

  @override
  void initState() {
    super.initState();
    _selectedBuyer = _dummyBuyers.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F1C2E),
      child: GetBuilder<SalesController>(
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buyer Selection
              Text(
                "Select Buyer".tr,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBuyer,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: const Color(0xFF162534),
                style: GoogleFonts.inter(color: Colors.white),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                items: _dummyBuyers.map((String buyer) {
                  return DropdownMenuItem<String>(
                    value: buyer,
                    child: Text(buyer, style: GoogleFonts.inter(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBuyer = val;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 20),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total".tr, style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
                  Text("₹${controller.totalResultselse.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
              
              // Paid
              Text("Amount Paid".tr, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 8),
              Theme(
                data: ThemeData.dark(),
                child: TextFormField(
                  controller: controller.PayedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF4FC3F7)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      controller.change = double.tryParse(val) ?? 0 - controller.totalResultselse;
                      controller.update();
                    } else {
                      controller.change = 0 - controller.totalResultselse;
                      controller.update();
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Change
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: controller.change >= 0 
                      ? const Color(0xFF81C784).withValues(alpha: 0.1)
                      : const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: controller.change >= 0 
                          ? const Color(0xFF81C784).withValues(alpha: 0.3)
                          : const Color(0xFFE53935).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Change".tr, style: GoogleFonts.inter(color: Colors.white70, fontSize: 15)),
                    Text(
                      "₹${controller.change.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        color: controller.change >= 0 ? const Color(0xFF81C784) : const Color(0xFFE53935), 
                        fontSize: 18, 
                        fontWeight: FontWeight.w800
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        controller.change = 0;
                        controller.PayedController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Cancel".tr, style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.payment(paymentData: controller.listOfSalesModel);
                        Get.back();
                        controller.totalOnsave();
                        Get.snackbar("Success".tr, "Sale completed for $_selectedBuyer".tr,
                            backgroundColor: const Color(0xFF81C784),
                            colorText: Colors.black,
                            snackPosition: SnackPosition.BOTTOM);
                        Get.off(() => const CashierScreensPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Confirm".tr, style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}
