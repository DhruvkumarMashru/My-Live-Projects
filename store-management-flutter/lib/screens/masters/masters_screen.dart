import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'category_screen.dart';
import 'sub_category_screen.dart';
import 'brand_screen.dart';
import 'item_screen.dart';
import 'bundle_screen.dart';

class MastersScreen extends StatelessWidget {
  const MastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Get.back()),
          title: Text("Masters Setup".tr),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: const Icon(Icons.grid_view_rounded, size: 18), text: "Category".tr),
              Tab(icon: const Icon(Icons.layers_rounded, size: 18), text: "Sub Category Master".tr),
              Tab(icon: const Icon(Icons.branding_watermark_rounded, size: 18), text: "Brand Master".tr),
              Tab(icon: const Icon(Icons.inventory_2_rounded, size: 18), text: "Item Master".tr),
              Tab(icon: const Icon(Icons.dashboard_customize_rounded, size: 18), text: "Bundles / BOM".tr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryScreen(),
            SubCategoryScreen(),
            BrandScreen(),
            ItemScreen(),
            BundleScreen(),
          ],
        ),
      ),
    );
  }
}
