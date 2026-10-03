import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/inventory_controller.dart';
import '../../shared/constants.dart';
import '../../widgets/confirmAndcancel.dart';
import '../../widgets/qr_generator_view.dart';
import '../make_a_sale/Mak-Sall-widget/make_sale_search.dart';

class ProductsListPage extends GetWidget<InventoryController> {
  ProductsListPage({super.key});

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
          "Products List".tr,
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
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF162534),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: MakeSaleSearch(
                              apiPath: apiInventory, nameAtapi: "item_name"),
                        );
                      },
                      child: Text(
                        "Search By Product Name...".tr,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.search_rounded, color: Colors.white54),
                ],
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: _headerText("Item")),
                  Expanded(flex: 1, child: _headerText("Cost", align: TextAlign.center)),
                  Expanded(flex: 1, child: _headerText("Price", align: TextAlign.center)),
                  Expanded(flex: 1, child: _headerText("Qty", align: TextAlign.center)),
                  Expanded(flex: 1, child: _headerText("QR", align: TextAlign.right)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Item List
            Expanded(
              child: GetBuilder<InventoryController>(
                builder: (controller) {
                  if (controller.productsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            "No products in inventory".tr,
                            style: GoogleFonts.inter(
                                color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.productsList.length,
                    itemBuilder: (context, index) {
                      final item = controller.productsList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162534),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: ((context) {
                                  _showDeleteConfirm(context, controller, index);
                                }),
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline_rounded,
                                label: "Delete".tr,
                              ),
                              SlidableAction(
                                onPressed: ((context) {}),
                                backgroundColor: const Color(0xFF4FC3F7),
                                foregroundColor: Colors.white,
                                icon: Icons.edit_rounded,
                                label: "Edit".tr,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item.productName,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "₹${item.cost}",
                                    style: GoogleFonts.inter(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "₹${item.price}",
                                    style: GoogleFonts.inter(
                                        color: const Color(0xFF81C784),
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4FC3F7)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.quantity,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF4FC3F7),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => QRGeneratorView(product: item),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
        letterSpacing: 1.0,
      ),
      textAlign: align,
    );
  }

  void _showDeleteConfirm(BuildContext context, InventoryController controller, int index) {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF0F1C2E),
      titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
      title: "Confirm Delete",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFE4A49), size: 48),
            const SizedBox(height: 16),
            Text(
              "Are you sure you want to delete this product from the inventory?",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Cancel".tr, style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.deleteProduct(controller.productsList[index].id);
                      controller.removeFromList(index);
                      Get.back();
                      Get.snackbar(
                        "Deleted".tr,
                        "The product has been removed.".tr,
                        backgroundColor: const Color(0xFFFE4A49),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE4A49),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Delete".tr, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
