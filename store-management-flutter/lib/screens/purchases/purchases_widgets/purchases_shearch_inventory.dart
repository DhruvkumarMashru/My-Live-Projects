// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/repo/purchases_repo.dart';
import '../../../controller/purchase_controller.dart';
import '../../../model/inventroy_model.dart';

class PurchasesSearchInventory extends SearchDelegate {
  PurchasesSearchInventory({required this.apiPath, required this.nameAtapi});
  final String apiPath;
  final String nameAtapi;
  
  // Theme styling for the search interface
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1C2E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A1628), // Dark background matching app
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear, color: Colors.white70),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<InventoryModel>>(
      future: PurchasesRepo.getProductList(
          apiPath: apiPath, nameAtapi: nameAtapi, itemName: query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return GetBuilder<PurchaseController>(
                builder: (controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF162534),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        product.productName.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "Code: ${product.barcode}",
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Add",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4FC3F7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        controller.setData(product);
                        Get.back();
                      },
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(
            child: Text(
              "No products found",
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Type to search for products",
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    
    // As they type, perform a live search query 
    return buildResults(context);
  }
}
