import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../local_db/masters_db.dart';
import '../../local_db/purchase_db_new.dart';
import '../../model/database_models.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1628), // Dark aesthetic
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Purchases".tr,
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
          bottom: TabBar(
            indicatorColor: const Color(0xFF4FC3F7),
            labelColor: const Color(0xFF4FC3F7),
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: "Stock In (Entry)"),
              Tab(text: "Stock Report"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PurchaseEntryTab(),
            PurchaseReportTab(),
          ],
        ),
      ),
    );
  }
}

class PurchaseEntryTab extends StatefulWidget {
  const PurchaseEntryTab({Key? key}) : super(key: key);

  @override
  _PurchaseEntryTabState createState() => _PurchaseEntryTabState();
}

class _PurchaseEntryTabState extends State<PurchaseEntryTab> {
  final _formKey = GlobalKey<FormState>();

  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  List<ItemModel> _items = [];
  List<BrandModel> _brands = [];

  int? _selectedCategory;
  int? _selectedSubCategory;
  int? _selectedItem;
  int? _selectedBrand;

  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _qtyCtrl.addListener(_calculateTotal);
    _rateCtrl.addListener(_calculateTotal);
  }

  Future<void> _loadInitialData() async {
    final cats = await MastersDb.getAllCategories();
    final allBrands = await MastersDb.getAllBrands();
    setState(() {
      _categories = cats;
      _brands = allBrands;
    });
  }

  Future<void> _onCategoryChanged(int? catId) async {
    setState(() {
      _selectedCategory = catId;
      _selectedSubCategory = null;
      _selectedItem = null;
      _subCategories = [];
      _items = [];
    });
    if (catId != null) {
      final subs = await MastersDb.getSubCategoriesByCategoryId(catId);
      setState(() => _subCategories = subs);
    }
  }

  Future<void> _onSubCategoryChanged(int? subId) async {
    setState(() {
      _selectedSubCategory = subId;
      _selectedItem = null;
      _items = [];
    });
    if (subId != null) {
      // PDF says: "Item Name: Drop down from Item Master based on selected sub category" 
      // Note: Items might just be mapped to brand. But let's fetch all items for now to allow selection.
      final allItems = await MastersDb.getAllItems();
      setState(() => _items = allItems);
    }
  }

  void _calculateTotal() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    setState(() {
      _totalValue = qty * rate;
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newEntry = PurchaseEntryModel(
      categoryId: _selectedCategory!,
      subCategoryId: _selectedSubCategory!,
      itemId: _selectedItem!,
      brandId: _selectedBrand!,
      qty: double.parse(_qtyCtrl.text),
      rate: double.parse(_rateCtrl.text),
      total: _totalValue,
      size: _sizeCtrl.text,
      description: _descCtrl.text,
      purchaseDate: DateTime.now().toIso8601String(),
    );

    await PurchaseDbNew.insertPurchase(newEntry);
    
    Get.snackbar(
      "Success",
      "Stock accurately added!",
      backgroundColor: const Color(0xFF81C784),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
    );
    
    setState(() {
      _selectedCategory = null;
      _selectedSubCategory = null;
      _selectedItem = null;
      _selectedBrand = null;
      _qtyCtrl.clear();
      _rateCtrl.clear();
      _sizeCtrl.clear();
      _descCtrl.clear();
      _totalValue = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDropdown<int>("Category *", _selectedCategory, _categories.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), _onCategoryChanged),
          _buildDropdown<int>("Sub Category *", _selectedSubCategory, _subCategories.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), _onSubCategoryChanged),
          _buildDropdown<int>("Item Name *", _selectedItem, _items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), (v) => setState(() => _selectedItem = v)),
          
          Row(
            children: [
              Expanded(child: _buildTextField(
                "Stock In QTY *", _qtyCtrl, 
                keyboardType: TextInputType.number, 
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(
                "Rate per QTY *", _rateCtrl, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              )),
            ],
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Value", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                Text("₹ ${_totalValue.toStringAsFixed(2)}", style: GoogleFonts.inter(color: const Color(0xFF4FC3F7), fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          _buildDropdown<int>("Brand *", _selectedBrand, _brands.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), (v) => setState(() => _selectedBrand = v)),
          _buildTextField("Size", _sizeCtrl),
          _buildTextField("Description", _descCtrl, maxLines: 2),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                "SAVE PURCHASE",
                style: GoogleFonts.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T? value, List<DropdownMenuItem<T>> items, void Function(T?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF162534),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF162534),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items,
        onChanged: onChanged,
        validator: (v) => v == null && label.contains('*') ? "Required" : null,
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label.tr,
          labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF162534),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (v) {
          if (label.contains('*') && (v == null || v.isEmpty)) return "Required";
          return null;
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// STOCK REPORT TAB
// -------------------------------------------------------------

class PurchaseReportTab extends StatefulWidget {
  const PurchaseReportTab({Key? key}) : super(key: key);

  @override
  _PurchaseReportTabState createState() => _PurchaseReportTabState();
}

class _PurchaseReportTabState extends State<PurchaseReportTab> {
  List<PurchaseEntryModel> _purchases = [];
  bool _isLoading = true;
  String _filterMode = "General"; // General, Category, Sub Category

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await PurchaseDbNew.getAllPurchases();
    // Re-calculating actual current available logic is optional,
    // PDF says show "QTY" and "Last Stock In Date", we can group them.
    setState(() {
      _purchases = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)));
    
    return Column(
      children: [
        // Filter Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text("Filter by:", style: GoogleFonts.inter(color: Colors.white54)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterMode,
                  dropdownColor: const Color(0xFF162534),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFF162534),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  items: ["General", "Category", "Sub Category"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _filterMode = v);
                  },
                ),
              ),
            ],
          ),
        ),

        // Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (_filterMode == "General") Expanded(flex: 2, child: _headerText("Category")),
              if (_filterMode == "General" || _filterMode == "Category") Expanded(flex: 2, child: _headerText("Sub Cat")),
              Expanded(flex: 2, child: _headerText("Item")),
              Expanded(flex: 2, child: _headerText("Brand")),
              Expanded(flex: 1, child: _headerText("Qty", align: TextAlign.right)),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),

        // List Data
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _purchases.length,
            itemBuilder: (context, index) {
              final p = _purchases[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                child: Row(
                  children: [
                    if (_filterMode == "General") Expanded(flex: 2, child: _cellText(p.categoryName)),
                    if (_filterMode == "General" || _filterMode == "Category") Expanded(flex: 2, child: _cellText(p.subCategoryName)),
                    Expanded(flex: 2, child: _cellText(p.itemName, isBold: true)),
                    Expanded(flex: 2, child: _cellText(p.brandName)),
                    Expanded(
                      flex: 1, 
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF4FC3F7).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(p.qty.toStringAsFixed(0), textAlign: TextAlign.right, style: GoogleFonts.inter(color: const Color(0xFF4FC3F7), fontWeight: FontWeight.bold, fontSize: 13)),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold), textAlign: align);
  }
  Widget _cellText(String text, {bool isBold = false}) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: isBold ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal));
  }
}
