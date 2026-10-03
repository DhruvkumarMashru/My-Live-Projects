import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/local_db/app_database.dart';
import '../reports/invoice_viewer.dart';

class SelesReportsPage extends StatefulWidget {
  const SelesReportsPage({super.key});

  @override
  State<SelesReportsPage> createState() => _SelesReportsPageState();
}

class _SelesReportsPageState extends State<SelesReportsPage> {
  List<Map<String, dynamic>> _salesRows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final db = await AppDatabase.instance;
    // Join sales + sale_items + masters to get flat rows with all columns
    final res = await db.rawQuery('''
      SELECT 
        s.id AS sale_id,
        s.sale_date,
        s.customer_name,
        s.mobile_number,
        si.qty,
        si.rate,
        si.total,
        c.name AS category_name,
        sc.name AS sub_category_name,
        i.name AS item_name,
        b.bundle_name AS bundle_name
      FROM sales s
      INNER JOIN sale_items si ON si.sale_id = s.id
      LEFT JOIN categories c ON si.category_id = c.id
      LEFT JOIN sub_categories sc ON si.sub_category_id = sc.id
      LEFT JOIN items i ON si.item_id = i.id
      LEFT JOIN bundles b ON si.bundle_id = b.id
      ORDER BY s.sale_date DESC, s.id DESC
    ''');
    setState(() {
      _salesRows = res;
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
        title: Text("Sales Reports".tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadSales();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salesRows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text("No Sales Found".tr, style: GoogleFonts.inter(fontSize: 16, color: theme.hintColor)),
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
                          _summaryChip(theme, "Total Items Sold".tr, "${_salesRows.length}", Icons.list_alt_rounded),
                          const SizedBox(width: 16),
                          _summaryChip(theme, "Total Value".tr,
                              "₹${_salesRows.fold<double>(0, (sum, r) => sum + ((r['total'] as num?)?.toDouble() ?? 0)).toStringAsFixed(2)}",
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
                              DataColumn(label: Text("Customer Name".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Category".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Sub Category".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Item".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                              DataColumn(label: Text("Qty".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                              DataColumn(label: Text("Rate".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                              DataColumn(label: Text("Total".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13)), numeric: true),
                              DataColumn(label: Text("Contact No.".tr, style: GoogleFonts.inter(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 13))),
                            ],
                            rows: _salesRows.asMap().entries.map((entry) {
                              final i = entry.key;
                              final r = entry.value;
                              final dateStr = r['sale_date']?.toString().split('T')[0] ?? '-';
                              final isAlt = i % 2 == 1;
                              final cellStyle = GoogleFonts.inter(fontSize: 12, color: theme.textTheme.bodyMedium?.color);
                              final boldStyle = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color);

                              // For combo items, show bundle name; otherwise show item name
                              final itemDisplay = r['item_name']?.toString() ?? r['bundle_name']?.toString() ?? '-';

                              return DataRow(
                                color: isAlt ? WidgetStateProperty.all(rowAltColor) : null,
                                onSelectChanged: (_) {
                                  final saleId = r['sale_id'];
                                  if (saleId != null) {
                                    Get.to(() => ProfessionalInvoiceViewer(saleId: saleId as int));
                                  }
                                },
                                cells: [
                                  DataCell(Text(dateStr, style: cellStyle)),
                                  DataCell(Text(r['customer_name']?.toString() ?? '-', style: boldStyle)),
                                  DataCell(Text(r['category_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text(r['sub_category_name']?.toString() ?? '-', style: cellStyle)),
                                  DataCell(Text(itemDisplay, style: boldStyle)),
                                  DataCell(Text('${double.tryParse(r['qty']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}', style: cellStyle)),
                                  DataCell(Text('₹${double.tryParse(r['rate']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}', style: cellStyle)),
                                  DataCell(Text('₹${double.tryParse(r['total']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green))),
                                  DataCell(Text(r['mobile_number']?.toString() ?? '-', style: cellStyle)),
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
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.green),
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
