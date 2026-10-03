import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/local_db/app_database.dart';

class PurchaseReportsPage extends StatefulWidget {
  const PurchaseReportsPage({super.key});

  @override
  State<PurchaseReportsPage> createState() => _PurchaseReportsPageState();
}

class _PurchaseReportsPageState extends State<PurchaseReportsPage> {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final db = await AppDatabase.instance;
    final res = await db.rawQuery('''
      SELECT 
        p.id,
        p.purchase_date,
        p.qty,
        p.rate,
        p.total,
        v.company_name AS vendor_name,
        c.name AS category_name,
        sc.name AS sub_category_name,
        i.name AS item_name,
        br.name AS brand_name
      FROM purchases p
      LEFT JOIN vendors v ON p.vendor_id = v.id
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN sub_categories sc ON p.sub_category_id = sc.id
      LEFT JOIN items i ON p.item_id = i.id
      LEFT JOIN brands br ON p.brand_id = br.id
      ORDER BY p.purchase_date DESC
    ''');
    setState(() {
      _purchases = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF1A2F4A) : theme.colorScheme.primary;
    final headerTextColor = Colors.white;
    final rowAltColor = isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Purchase Reports".tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadPurchases();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text("No Purchases Found".tr, style: GoogleFonts.inter(fontSize: 16, color: theme.hintColor)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary bar
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          _summaryChip(theme, "Total Records".tr, "${_purchases.length}", Icons.list_alt_rounded),
                          const SizedBox(width: 16),
                          _summaryChip(theme, "Total Value".tr,
                              "₹${_purchases.fold<double>(0, (sum, p) => sum + ((p['total'] as num?)?.toDouble() ?? 0)).toStringAsFixed(2)}",
                              Icons.currency_rupee_rounded, valueColor: Colors.green),
                        ],
                      ),
                    ),
                    // Table
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(headerColor),
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 60,
                            columnSpacing: 20,
                            horizontalMargin: 16,
                            border: TableBorder.all(color: theme.dividerColor.withOpacity(0.15)),
                            columns: [
                              DataColumn(label: Text("Date".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Vendor Name".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Category".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Sub Category".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Item".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Brand".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Qty".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                              DataColumn(label: Text("Rate".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                              DataColumn(label: Text("Total".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                            ],
                            rows: _purchases.asMap().entries.map((entry) {
                              final i = entry.key;
                              final p = entry.value;
                              final dateStr = p['purchase_date']?.toString().split('T')[0] ?? '-';
                              final isAlt = i % 2 == 1;
                              final cellStyle = GoogleFonts.inter(fontSize: 12, color: theme.textTheme.bodyMedium?.color);
                              final boldStyle = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color);

                              return DataRow(
                                color: isAlt ? WidgetStateProperty.all(rowAltColor) : null,
                                cells: [
                                  DataCell(Text(dateStr, style: cellStyle)),
                                  DataCell(Text(p['vendor_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text(p['category_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text(p['sub_category_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text(p['item_name']?.toString() ?? '-', style: boldStyle)),
                                  DataCell(Text(p['brand_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text('${double.tryParse(p['qty']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}', style: cellStyle)),
                                  DataCell(Text('₹${double.tryParse(p['rate']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}', style: cellStyle)),
                                  DataCell(Text('₹${double.tryParse(p['total']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _summaryChip(ThemeData theme, String label, String value, IconData icon, {Color? valueColor}) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: theme.hintColor)),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? theme.textTheme.bodyLarge?.color)),
            ],
          ),
        ],
      ),
    );
  }
}
