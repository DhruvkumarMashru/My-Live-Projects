import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';
import '../../shared/master_validation.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MastersDb.getAllCategories();
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  void _showAddEditForm([CategoryModel? model]) {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController(text: model?.name ?? '');
    final _remarksCtrl = TextEditingController(text: model?.remarks ?? '');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model == null ? "Add Category".tr : "Edit Category".tr,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Category Name *".tr,
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  validator: MasterValidation.validateCategoryName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksCtrl,
                  decoration: InputDecoration(
                    labelText: "Remarks".tr,
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                  validator: MasterValidation.validateRemarks,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newModel = CategoryModel(
                          id: model?.id,
                          name: _nameCtrl.text,
                          remarks: _remarksCtrl.text,
                          isActive: model?.isActive ?? 1,
                        );
                        if (model == null) {
                          await MastersDb.insertCategory(newModel);
                        } else {
                          await MastersDb.updateCategory(newModel);
                        }
                        Get.back();
                        _loadData();
                      }
                    },
                    child: Text("Save".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showViewDetails(CategoryModel model) {
    Get.defaultDialog(
      title: "Category Details".tr,
      content: Column(
        children: [
          _detailTile("Category Name".tr, model.name),
          _detailTile("Sub Category Count".tr, model.subCatCount.toString()),
          _detailTile("Remarks".tr, model.remarks ?? '-'),
          _detailTile("Status".tr, model.isActive == 1 ? 'Active'.tr : 'Inactive'.tr),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          _showAddEditForm(model);
        },
        child: Text("Edit".tr),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Back".tr),
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${label.tr}:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showAddEditForm(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(cat.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text("${"Sub Categories".tr}: ${cat.subCatCount}"),
              trailing: Switch(
                value: cat.isActive == 1,
                onChanged: (v) async {
                  cat.isActive = v ? 1 : 0;
                  await MastersDb.updateCategory(cat);
                  _loadData();
                },
              ),
              onTap: () => _showViewDetails(cat),
            ),
          );
        },
      ),
    );
  }
}
