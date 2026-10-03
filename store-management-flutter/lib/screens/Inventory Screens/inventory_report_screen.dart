import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/app_database.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> _stockData = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  
  int? _selectedCat;
  int? _selectedSubCat;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cats = await MastersDb.getAllCategories();
    final subCats = await MastersDb.getAllSubCategories();
    setState(() {
      _categories = cats;
      _subCategories = subCats;
    });
    _refreshStock();
  }

  Future<void> _refreshStock() async {
    setState(() => _isLoading = true);
    final db = await AppDatabase.instance;
    
    // We calculate current stock by summing movements
    String query = '''
      SELECT 
        i.name as item_name,
        c.name as category_name,
        sc.name as sub_category_name,
        b.name as brand_name,
        COALESCE(SUM(sm.qty_change), 0) as current_qty,
        MAX(sm.movement_date) as last_date,
        i.category_id,
        i.sub_category_id
      FROM items i
      LEFT JOIN categories c ON i.category_id = c.id
      LEFT JOIN sub_categories sc ON i.sub_category_id = sc.id
      LEFT JOIN brands b ON i.brand_id = b.id
      LEFT JOIN stock_movements sm ON i.id = sm.item_id
      WHERE 1=1
    ''';
    
    List<dynamic> args = [];
    if (_selectedCat != null) {
      query += " AND i.category_id = ?";
      args.add(_selectedCat);
    }
    if (_selectedSubCat != null) {
      query += " AND i.sub_category_id = ?";
      args.add(_selectedSubCat);
    }
    
    query += " GROUP BY i.id ORDER BY c.name, sc.name, i.name";
    
    final data = await db.rawQuery(query, args);
    setState(() {
      _stockData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Stock Report".tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedCat,
                        decoration: InputDecoration(labelText: "Category Filter".tr, prefixIcon: const Icon(Icons.category, size: 18)),
                        dropdownColor: Theme.of(context).cardColor,
                        items: [
                          DropdownMenuItem(value: null, child: Text("General (All)".tr)),
                          ..._categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedCat = v;
                            _selectedSubCat = null;
                          });
                          _refreshStock();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _selectedSubCat,
                        decoration: InputDecoration(labelText: "Sub-Category".tr, prefixIcon: const Icon(Icons.layers, size: 18)),
                        dropdownColor: Theme.of(context).cardColor,
                        items: [
                          DropdownMenuItem(value: null, child: Text("All".tr)),
                          ..._subCategories.where((s) => _selectedCat == null || s.categoryId == _selectedCat)
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedSubCat = v);
                          _refreshStock();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_selectedCat != null)
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
               color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
               child: Text(
                 "${"Category".tr}: ${_categories.firstWhere((c) => c.id == _selectedCat).name}",
                 style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
               ),
             ),

          // Titles Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                if (_selectedCat == null) Expanded(flex: 2, child: _headerText("Cat/Sub")),
                Expanded(flex: 3, child: _headerText("Item")),
                Expanded(flex: 1, child: _headerText("Qty", align: TextAlign.right)),
                Expanded(flex: 2, child: _headerText("Brand", align: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _stockData.isEmpty
                ? Center(child: Text("No Stock Found".tr, style: TextStyle(color: Theme.of(context).hintColor)))
                : ListView.builder(
                    itemCount: _stockData.length,
                    itemBuilder: (ctx, i) {
                      final item = _stockData[i];
                      final lastDate = item['last_date'] != null 
                          ? DateTime.parse(item['last_date'].toString()) 
                          : null;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (_selectedCat == null)
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['category_name'] ?? '-', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 11)),
                                        Text(item['sub_category_name'] ?? '-', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  flex: 3,
                                  child: Text(item['item_name'] ?? '-', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${item['current_qty']}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: (item['current_qty'] as num) <= 5 ? Colors.orange : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(item['brand_name'] ?? '-', textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 12)),
                                ),
                              ],
                            ),
                            if (lastDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.access_time, size: 10, color: Theme.of(context).hintColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${"Last Stock In".tr}: ${lastDate.day}/${lastDate.month}/${lastDate.year}",
                                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(text.tr, style: GoogleFonts.inter(color: Theme.of(context).hintColor, fontSize: 11, fontWeight: FontWeight.bold), textAlign: align);
  }
}
