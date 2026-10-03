import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import '../local_db/sales_db.dart';

class InvoicePdfService {
  static Future<void> printInvoice({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required Map<String, dynamic>? biz,
  }) async {
    final pdf = pw.Document();

    // Load Logo if exists
    pw.ImageProvider? logoImage;
    final logoPath = biz?['logo_path']?.toString();
    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        if (logoPath.startsWith('http')) {
          final response = await http.get(Uri.parse(logoPath));
          if (response.statusCode == 200) {
            logoImage = pw.MemoryImage(response.bodyBytes);
          }
        } else {
          final file = File(logoPath.replaceFirst('file://', ''));
          if (await file.exists()) {
            logoImage = pw.MemoryImage(await file.readAsBytes());
          }
        }
      } catch (e) {
        print("PDF Logo Load Error: $e");
      }
    }

    final bizName = biz?['company_name']?.toString() ?? 'Your Business Name';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.Container(width: 60, height: 60, child: pw.Image(logoImage))
                else
                  pw.Container(width: 60, height: 60),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(bizName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text(biz?['address']?.toString() ?? '', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("${biz?['city'] ?? ''}, ${biz?['state'] ?? ''} ${biz?['pin_code'] ?? ''}", style: const pw.TextStyle(fontSize: 10)),
                    if (biz?['gst'] != null) pw.Text("GST: ${biz!['gst']}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Phone: ${biz?['contact_number'] ?? ''}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),

            // Invoice Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Bill To:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(sale.customerName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Mobile: ${sale.mobileNumber ?? '-'}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("INVOICE #${sale.id}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text("Date: ${sale.saleDate.split('T')[0]}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  children: [
                    _pdfCell("#", align: pw.TextAlign.center, color: PdfColors.white),
                    _pdfCell("Item Particulars", color: PdfColors.white),
                    _pdfCell("Qty", align: pw.TextAlign.center, color: PdfColors.white),
                    _pdfCell("Rate", align: pw.TextAlign.right, color: PdfColors.white),
                    _pdfCell("Total", align: pw.TextAlign.right, color: PdfColors.white),
                  ],
                ),
                // Items
                ...items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;
                  return pw.TableRow(
                    children: [
                      _pdfCell("${i + 1}", align: pw.TextAlign.center),
                      _pdfCell(it.itemName ?? (it.bundleId != null ? "Combo: ${it.bundleName}" : "Item")),
                      _pdfCell(it.qty.toStringAsFixed(0), align: pw.TextAlign.center),
                      _pdfCell("Rs. ${it.rate.toStringAsFixed(2)}", align: pw.TextAlign.right),
                      _pdfCell("Rs. ${it.total.toStringAsFixed(2)}", align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _totalRow("Gross Amount", sale.totalAmount),
                      _totalRow("Discount", sale.discount),
                      pw.Divider(),
                      _totalRow("NET PAYABLE", sale.netPayable, isBold: true),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 50),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [pw.SizedBox(width: 100, child: pw.Divider()), pw.Text("Customer Signature", style: const pw.TextStyle(fontSize: 8))]),
                pw.Column(children: [pw.SizedBox(width: 100, child: pw.Divider()), pw.Text("Authorized Signatory", style: const pw.TextStyle(fontSize: 8))]),
              ],
            ),
          ];
        },
      ),
    );

    // Show Print Dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${sale.id}.pdf',
    );
  }

  static pw.Widget _pdfCell(String text, {pw.TextAlign align = pw.TextAlign.left, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 10, color: color, fontWeight: color != null ? pw.FontWeight.bold : null),
      ),
    );
  }

  static pw.Widget _totalRow(String label, double val, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : null)),
        pw.Text("Rs. ${val.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : null)),
      ],
    );
  }
}
