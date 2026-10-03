import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/local_db/app_database.dart';
import 'package:store_management_modern/local_db/sales_db.dart';
import '../../shared/invoice_pdf_service.dart';

class ProfessionalInvoiceViewer extends StatefulWidget {
  final int saleId;
  const ProfessionalInvoiceViewer({super.key, required this.saleId});

  @override
  State<ProfessionalInvoiceViewer> createState() => _ProfessionalInvoiceViewerState();
}

class _ProfessionalInvoiceViewerState extends State<ProfessionalInvoiceViewer> {
  SaleModel? _sale;
  List<SaleItemModel> _items = [];
  Map<String, dynamic>? _biz;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final details = await SalesDb.getSaleFullDetails(widget.saleId);
    final db = await AppDatabase.instance;
    final bizRows = await db.query('company_profile', limit: 1);
    
    if (details != null) {
      setState(() {
        _sale = details['sale'];
        _items = details['items'];
        if (bizRows.isNotEmpty) _biz = bizRows.first;
        _isLoading = false;
      });
    }
  }

  /// Builds the logo widget — supports local file path or network URL
  Widget _buildLogo() {
    final logoPath = _biz?['logo_path']?.toString();
    if (logoPath == null || logoPath.isEmpty) {
      return Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Icon(Icons.store_rounded, size: 44, color: Colors.blue[900]),
      );
    }

    // Check if it's a local file path
    if (logoPath.startsWith('/') || logoPath.startsWith('file://') || logoPath.contains('\\')) {
      final file = File(logoPath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
        );
      }
    }

    // Network URL
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        logoPath,
        width: 80, height: 80,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.store_rounded, size: 44, color: Colors.blue[900]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_sale == null) return Scaffold(body: Center(child: Text("Error loading invoice".tr)));

    final bizName = _biz?['company_name']?.toString() ?? 'Your Business Name';

    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () {
              if (_sale != null && _items.isNotEmpty) {
                InvoicePdfService.printInvoice(
                  sale: _sale!,
                  items: _items,
                  biz: _biz,
                );
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 800,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header / Letter Pad ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(bizName, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.blue[900])),
                          const SizedBox(height: 4),
                          if ((_biz?['address']?.toString() ?? '').isNotEmpty)
                            Text(_biz!['address'].toString(), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700])),
                          Text(
                            "${_biz?['city'] ?? ''}, ${_biz?['state'] ?? ''} ${(_biz?['pin_code']?.toString() ?? '').isNotEmpty ? '- ${_biz!['pin_code']}' : ''}".trim(),
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700]),
                          ),
                          if ((_biz?['gst']?.toString() ?? '').isNotEmpty)
                            Text("GST: ${_biz!['gst']}", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                          if ((_biz?['pan']?.toString() ?? '').isNotEmpty)
                            Text("PAN: ${_biz!['pan']}", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[800])),
                          if ((_biz?['contact_number']?.toString() ?? '').isNotEmpty)
                            Text("Ph: ${_biz!['contact_number']}", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700])),
                          if ((_biz?['email']?.toString() ?? '').isNotEmpty)
                            Text(_biz!['email'].toString(), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 3, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[300]!]))),
                
                // ─── Invoice Info ───────────────────────────
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bill To:".tr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(_sale!.customerName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                        if ((_sale!.mobileNumber ?? '').isNotEmpty)
                          Text("${"Mobile".tr}: ${_sale!.mobileNumber}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("INVOICE-${_sale!.id}", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.blue[900])),
                        ),
                        const SizedBox(height: 8),
                        Text("${"Date".tr}: ${_sale!.saleDate.split('T')[0]}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                
                // ─── Table ──────────────────────────────────
                Table(
                  border: TableBorder.all(color: Colors.grey[300]!),
                  columnWidths: const {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(3.5),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.2),
                    4: FlexColumnWidth(1.3),
                  },
                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue[900]),
                      children: [
                        _tableHeader("#"),
                        _tableHeader("Item Particulars".tr),
                        _tableHeader("Qty".tr),
                        _tableHeader("Rate".tr),
                        _tableHeader("Total".tr),
                      ],
                    ),
                    // Data rows
                    ..._items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final it = entry.value;
                      final isAlt = idx % 2 == 1;

                      // Determine item display name
                      String itemDisplay;
                      String? itemSub;
                      if (it.bundleId != null) {
                        itemDisplay = "Combo: ${it.bundleName ?? 'Bundle'}";
                      } else {
                        itemDisplay = it.itemName ?? 'Item #${it.itemId}';
                        final parts = <String>[];
                        if (it.categoryName != null) parts.add(it.categoryName!);
                        if (it.subCategoryName != null) parts.add(it.subCategoryName!);
                        if (it.brandName != null) parts.add(it.brandName!);
                        if (parts.isNotEmpty) itemSub = parts.join(' › ');
                      }

                      return TableRow(
                        decoration: BoxDecoration(color: isAlt ? Colors.grey[50] : Colors.white),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("${idx + 1}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(itemDisplay, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                                if (itemSub != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(itemSub, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500])),
                                  ),
                              ],
                            ),
                          ),
                          Padding(padding: const EdgeInsets.all(10), child: Text("${it.qty.toStringAsFixed(0)}", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text("₹${it.rate.toStringAsFixed(2)}", textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text("₹${it.total.toStringAsFixed(2)}", textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700))),
                        ],
                      );
                    }),
                  ],
                ),
                
                // ─── Summary ────────────────────────────────
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _summaryRow("Gross Amount".tr, _sale!.totalAmount),
                          const SizedBox(height: 6),
                          _summaryRow("Discount".tr, _sale!.discount, isNegative: true),
                          const SizedBox(height: 8),
                          Container(height: 1.5, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          _summaryRow("NET PAYABLE".tr, _sale!.netPayable, isBold: true, fontSize: 17),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // ─── Footer ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 150, height: 1, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text("Customer Signature".tr, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 150, height: 1, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text("For $bizName", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                        Text("(Authorized Signatory)".tr, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "Thank you for your business!".tr,
                    style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white), textAlign: TextAlign.center),
  );

  Widget _summaryRow(String label, double val, {bool isNegative = false, bool isBold = false, double fontSize = 13}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: fontSize, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: isBold ? Colors.black87 : Colors.grey[700])),
        Text(
          "${isNegative ? '- ' : ''}₹${val.toStringAsFixed(2)}",
          style: GoogleFonts.inter(fontSize: fontSize, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: isBold ? Colors.blue[900] : Colors.grey[800]),
        ),
      ],
    );
  }
}
