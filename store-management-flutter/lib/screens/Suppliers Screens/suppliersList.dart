import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/screens/purchases/purchases_widgets/purchase_search_supplier.dart';
import 'package:store_management_modern/shared/constants.dart';
import '../../controller/supplier_controller.dart';
import 'Supplier Widget/suppliersBillsPopUp.dart';

class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Dark aesthetic
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Suppliers List".tr,
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
        child: Column(
          children: [
            // Internal Search Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF162534),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Colors.white38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: PurchaseSearchSupplier(
                            apiPath: apiSuppliers, 
                            nameAtapi: "name"
                          )
                        );
                      },
                      child: Text(
                        "Search Suppliers By Name...".tr,
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // List Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 32), // Space for icon
                  Expanded(flex: 3, child: _headerText("Supplier Name")),
                  Expanded(flex: 3, child: _headerText("Phone Number", align: TextAlign.right)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Supplier List
            Expanded(
              child: GetBuilder<SupplierController>(
                builder: (controller) {
                  if (controller.supplierList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt_outlined, size: 60, color: Colors.white.withValues(alpha:0.1)),
                          const SizedBox(height: 16),
                          Text("No suppliers found".tr, style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.supplierList.length,
                    itemBuilder: (context, index) {
                      final item = controller.supplierList[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        ),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                padding: EdgeInsets.zero,
                                onPressed: (_) => _confirmDelete(context, controller, index),
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline_rounded,
                                label: "Delete".tr,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Get.dialog(
                                SuppliersBillsPopUp(index: index),
                                barrierDismissible: true,
                              );
                            },
                            child: Container(
                              color: const Color(0xFF162534),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.domain_rounded, color: Color(0xFF4FC3F7), size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item['name'] ?? "",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item['phone'] ?? "",
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text.tr,
      style: GoogleFonts.inter(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      textAlign: align,
    );
  }

  void _confirmDelete(BuildContext context, SupplierController controller, int index) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A2F4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                "Delete Supplier?".tr,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to completely remove this supplier? This action cannot be undone.".tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        controller.deleteSupplier(controller.supplierList[index]['id']);
                        controller.removeFromList(index);
                        Get.back();
                        Get.snackbar(
                          "Deleted".tr, 
                          "The supplier has been removed.".tr,
                          backgroundColor: const Color(0xFFE53935),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Delete".tr, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
