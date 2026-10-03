import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/app_database.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';

class VendorLite {
  final int id;
  final String companyName;
  VendorLite({required this.id, required this.companyName});
}

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});
  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  final _formKey = GlobalKey<FormState>();
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _allSubCats = [];
  List<ItemModel> _allItems = [];
  List<BrandModel> _brands = [];
  List<VendorLite> _vendors = [];

  int? _selCat, _selSubCat, _selItem, _selBrand, _selVendor;
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  double _totalValue = 0;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadMasters(); }

  Future<void> _loadMasters() async {
    final cats = await MastersDb.getAllCategories();
    final subCats = await MastersDb.getAllSubCategories();
    final items = await MastersDb.getAllItems();
    final brands = await MastersDb.getAllBrands();

    // Load vendors
    final db = await AppDatabase.instance;
    final vendorRows = await db.query('vendors', where: 'is_active = 1');
    final vendors = vendorRows.map((v) => VendorLite(
      id: v['id'] as int,
      companyName: v['company_name']?.toString() ?? '',
    )).toList();

    setState(() {
      _categories = cats;
      _allSubCats = subCats;
      _allItems = items;
      _brands = brands;
      _vendors = vendors;
      _isLoading = false;
    });
  }

  void _calcTotal() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    setState(() => _totalValue = qty * rate);
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    final db = await AppDatabase.instance;
    await db.insert('purchases', {
      'vendor_id': _selVendor,
      'category_id': _selCat,
      'sub_category_id': _selSubCat,
      'item_id': _selItem,
      'brand_id': _selBrand,
      'size': _sizeCtrl.text,
      'description': _descCtrl.text,
      'qty': double.tryParse(_qtyCtrl.text) ?? 0,
      'rate': double.tryParse(_rateCtrl.text) ?? 0,
      'total': _totalValue,
      'purchase_date': DateTime.now().toIso8601String(),
    });
    // Also record stock movement
    await db.insert('stock_movements', {
      'item_id': _selItem,
      'qty_change': double.tryParse(_qtyCtrl.text) ?? 0,
      'reason': 'Purchase / Stock In',
      'movement_date': DateTime.now().toIso8601String(),
    });
    Get.snackbar("Success".tr, "Purchase saved!".tr, backgroundColor: Colors.green, colorText: Colors.white);
    // Reset form
    setState(() { _selCat = null; _selSubCat = null; _selItem = null; _selBrand = null; _selVendor = null; _totalValue = 0; });
    _qtyCtrl.clear(); _rateCtrl.clear(); _sizeCtrl.clear(); _descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text("Purchases".tr)), body: const Center(child: CircularProgressIndicator()));
    final filteredSubCats = _allSubCats.where((e) {
      final ee = e as SubCategoryModel;
      return ee.categoryId == _selCat;
    }).toList();
    final filteredItems = _allItems.where((e) {
      final ee = e as ItemModel;
      return ee.subCategoryId == _selSubCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Purchase / Stock In".tr)),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // Vendor
          DropdownButtonFormField<int>(
            value: _selVendor,
            decoration: InputDecoration(labelText: "Vendor".tr, prefixIcon: const Icon(Icons.business_rounded, size: 20)),
            items: _vendors.map((v) => DropdownMenuItem(value: v.id, child: Text(v.companyName))).toList(),
            onChanged: (v) => setState(() => _selVendor = v),
          ),
          const SizedBox(height: 12),
          // Category
          DropdownButtonFormField<int>(
            value: _selCat,
            decoration: InputDecoration(labelText: "${"Category".tr} *", prefixIcon: const Icon(Icons.category_rounded, size: 20)),
            items: _categories.map<DropdownMenuItem<int>>((c) {
                final dd = c as CategoryModel;
                return DropdownMenuItem<int>(value: dd.id, child: Text(dd.name));
            }).toList(),
            onChanged: (v) => setState(() { _selCat = v; _selSubCat = null; _selItem = null; }),
            validator: (v) => v == null ? "Required".tr : null,
          ),
          const SizedBox(height: 12),
          // Sub Category
          DropdownButtonFormField<int>(
            value: _selSubCat,
            decoration: InputDecoration(labelText: "${"Sub Category".tr} *", prefixIcon: const Icon(Icons.layers_rounded, size: 20)),
            items: filteredSubCats.map<DropdownMenuItem<int>>((s) {
                final dd = s as SubCategoryModel;
                return DropdownMenuItem<int>(value: dd.id, child: Text(dd.name));
            }).toList(),
            onChanged: (v) => setState(() { _selSubCat = v; _selItem = null; }),
            validator: (v) => v == null ? "Required".tr : null,
          ),
          const SizedBox(height: 12),
          // Item Name
          DropdownButtonFormField<int>(
            value: _selItem,
            decoration: InputDecoration(labelText: "${"Item Name".tr} *", prefixIcon: const Icon(Icons.inventory_2_rounded, size: 20)),
            items: filteredItems.map<DropdownMenuItem<int>>((it) {
                final dd = it as ItemModel;
                return DropdownMenuItem<int>(value: dd.id, child: Text(dd.name));
            }).toList(),
            onChanged: (v) => setState(() => _selItem = v),
            validator: (v) => v == null ? "Required".tr : null,
          ),
          const SizedBox(height: 12),
          // Brand
          DropdownButtonFormField<int>(
            value: _selBrand,
            decoration: InputDecoration(labelText: "${"Brand".tr} *", prefixIcon: const Icon(Icons.branding_watermark_rounded, size: 20)),
            items: _brands.map<DropdownMenuItem<int>>((b) {
                final bb = b as BrandModel;
                return DropdownMenuItem<int>(value: bb.id, child: Text(bb.name));
            }).toList(),
            onChanged: (v) => setState(() => _selBrand = v),
            validator: (v) => v == null ? "Required".tr : null,
          ),
          const SizedBox(height: 16),
          // Qty & Rate
          Row(children: [
            Expanded(child: TextFormField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "${"Stock In QTY".tr} *", prefixIcon: const Icon(Icons.add_shopping_cart_rounded, size: 20)),
              validator: (v) => (v == null || v.isEmpty) ? "Required".tr : null,
              onChanged: (_) => _calcTotal(),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(
              controller: _rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: "${"Rate per QTY".tr} *", prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20)),
              validator: (v) => (v == null || v.isEmpty) ? "Required".tr : null,
              onChanged: (_) => _calcTotal(),
            )),
          ]),
          const SizedBox(height: 12),
          // Total Value (read-only)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [Icon(Icons.calculate_rounded, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text("${"Total Value".tr}:")]),
              Text("₹${_totalValue.toStringAsFixed(2)}", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ]),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _sizeCtrl, decoration: InputDecoration(labelText: "Size".tr, prefixIcon: const Icon(Icons.straighten_rounded, size: 20))),
          const SizedBox(height: 12),
          TextFormField(controller: _descCtrl, maxLines: 3, decoration: InputDecoration(labelText: "Description".tr, prefixIcon: const Icon(Icons.description_rounded, size: 20), alignLabelWithHint: true)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: _savePurchase,
            icon: const Icon(Icons.save_rounded),
            label: Text("Save Purchase".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
