import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';
import '../../shared/master_validation.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});
  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  List<ItemModel> _items = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _allSubCategories = [];
  List<BrandModel> _brands = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final items = await MastersDb.getAllItems();
    final cats = await MastersDb.getAllCategories();
    final subCats = await MastersDb.getAllSubCategories();
    final brands = await MastersDb.getAllBrands();
    setState(() { _items = items; _categories = cats; _allSubCategories = subCats; _brands = brands; _isLoading = false; });
  }

  void _showAddEditForm([ItemModel? model]) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: model?.name ?? '');
    final remarksCtrl = TextEditingController(text: model?.remarks ?? '');
    final rateCtrl = TextEditingController(text: model != null ? model.ratePerQty.toString() : '');
    int? selCat = model?.categoryId;
    int? selSubCat = model?.subCategoryId;
    int? selBrand = model?.brandId;

    Get.bottomSheet(
      StatefulBuilder(builder: (ctx, setModalState) {
        final filteredSubCats = _allSubCategories.where((e) => e.categoryId == selCat).toList();
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(model == null ? "Add Item".tr : "Edit Item".tr, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selCat,
                decoration: InputDecoration(labelText: "Category *".tr, prefixIcon: const Icon(Icons.category_rounded, size: 20)),
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setModalState(() { selCat = v; selSubCat = null; }),
                validator: (v) => v == null ? "Required".tr : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selSubCat,
                decoration: InputDecoration(labelText: "Sub Category *".tr, prefixIcon: const Icon(Icons.layers_rounded, size: 20)),
                items: filteredSubCats.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setModalState(() => selSubCat = v),
                validator: (v) => v == null ? "Required".tr : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl, 
                decoration: InputDecoration(labelText: "Item Name *".tr, prefixIcon: const Icon(Icons.inventory_2_rounded, size: 20)), 
                validator: MasterValidation.validateItemName
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selBrand,
                decoration: InputDecoration(labelText: "Brand *".tr, prefixIcon: const Icon(Icons.branding_watermark_rounded, size: 20)),
                items: _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => setModalState(() => selBrand = v),
                validator: (v) => v == null ? "Required".tr : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rateCtrl, 
                keyboardType: TextInputType.number, 
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                decoration: InputDecoration(labelText: "Rate per QTY".tr, prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20)),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required".tr;
                  final n = double.tryParse(v);
                  if (n == null || n < 0 || n > 99999) return "Rate must be between 0 and 99999".tr;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: remarksCtrl, 
                decoration: InputDecoration(labelText: "Remarks".tr, prefixIcon: const Icon(Icons.notes_rounded, size: 20)),
                validator: MasterValidation.validateRemarks,
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: Text("Save".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final m = ItemModel(id: model?.id, categoryId: selCat, subCategoryId: selSubCat, brandId: selBrand, name: nameCtrl.text, ratePerQty: double.tryParse(rateCtrl.text) ?? 0, remarks: remarksCtrl.text, isActive: model?.isActive ?? 1);
                    model == null ? await MastersDb.insertItem(m) : await MastersDb.updateItem(m);
                    Get.back(); _loadData();
                  }
                },
              )),
            ])),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  void _showViewDetails(ItemModel m) {
    Get.defaultDialog(
      title: "Item Details".tr,
      content: Column(children: [
        _detailRow(Icons.category_rounded, "Category".tr, m.categoryName),
        _detailRow(Icons.layers_rounded, "Sub Category".tr, m.subCategoryName),
        _detailRow(Icons.inventory_2_rounded, "Item Name".tr, m.name),
        _detailRow(Icons.branding_watermark_rounded, "Brand".tr, m.brandName),
        _detailRow(Icons.currency_rupee_rounded, "Rate per QTY".tr, m.ratePerQty.toStringAsFixed(2)),
        _detailRow(Icons.notes_rounded, "Remarks".tr, m.remarks ?? ''),
      ]),
      confirm: ElevatedButton(onPressed: () { Get.back(); _showAddEditForm(m); }, child: Text("Edit".tr)),
      cancel: TextButton(onPressed: () => Get.back(), child: Text("Back".tr)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text("${label.tr}: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddEditForm(), child: const Icon(Icons.add_rounded)),
      body: _items.isEmpty
          ? Center(child: Text("No items yet. Tap + to add.".tr, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
          : ListView.builder(
              padding: const EdgeInsets.all(16), itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.inventory_2_rounded, color: Theme.of(context).colorScheme.primary),
                    title: Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text("${item.categoryName} > ${item.subCategoryName} | ${item.brandName}\n${"Rate".tr}: ₹${item.ratePerQty.toStringAsFixed(2)}"),
                    isThreeLine: true,
                    trailing: Switch(value: item.isActive == 1, onChanged: (v) async { item.isActive = v ? 1 : 0; await MastersDb.updateItem(item); _loadData(); }),
                    onTap: () => _showViewDetails(item),
                  ),
                );
              }),
    );
  }
}
