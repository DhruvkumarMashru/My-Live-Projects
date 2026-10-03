import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';
import '../../shared/master_validation.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({Key? key}) : super(key: key);

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<SubCategoryModel> _subCategories = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MastersDb.getAllSubCategories();
    final cats = await MastersDb.getAllCategories();
    setState(() {
      _subCategories = data;
      _categories = cats;
      _isLoading = false;
    });
  }

  void _showAddEditForm([SubCategoryModel? model]) {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController(text: model?.name ?? '');
    final _remarksCtrl = TextEditingController(text: model?.remarks ?? '');
    int? selectedCategory = model?.categoryId;

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
                  model == null ? "Add Sub Category".tr : "Edit Sub Category".tr,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Category *".tr,
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => selectedCategory = v,
                  validator: (v) => v == null ? "The field is empty".tr : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Sub Category Name *".tr,
                    prefixIcon: const Icon(Icons.layers_rounded),
                  ),
                  validator: MasterValidation.validateCategoryName, // Shares same rules as Cat Name
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
                        final newModel = SubCategoryModel(
                          id: model?.id,
                          categoryId: selectedCategory,
                          name: _nameCtrl.text,
                          remarks: _remarksCtrl.text,
                          isActive: model?.isActive ?? 1,
                        );
                        if (model == null) {
                          await MastersDb.insertSubCategory(newModel);
                        } else {
                          await MastersDb.updateSubCategory(newModel);
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

  void _showViewDetails(SubCategoryModel model) {
    Get.defaultDialog(
      title: "Sub Category Details".tr,
      content: Column(
        children: [
          _detailTile("Category".tr, model.categoryName),
          _detailTile("Sub Category Name".tr, model.name),
          _detailTile("Item Count".tr, model.itemCount.toString()),
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
        itemCount: _subCategories.length,
        itemBuilder: (ctx, i) {
          final sub = _subCategories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(sub.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text("${"Category".tr}: ${sub.categoryName}\n${"Item Master".tr}: ${sub.itemCount}"),
              isThreeLine: true,
              trailing: Switch(
                value: sub.isActive == 1,
                onChanged: (v) async {
                  sub.isActive = v ? 1 : 0;
                  await MastersDb.updateSubCategory(sub);
                  _loadData();
                },
              ),
              onTap: () => _showViewDetails(sub),
            ),
          );
        },
      ),
    );
  }
}
