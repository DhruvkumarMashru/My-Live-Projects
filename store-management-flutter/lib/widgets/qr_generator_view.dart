import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:store_management_modern/model/inventroy_model.dart';
import 'package:store_management_modern/widgets/smallButton.dart';

class QRGeneratorView extends StatelessWidget {
  final InventoryModel product;

  const QRGeneratorView({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If barcode is empty or just generic 'null' string
    final hasValidBarcode = product.barcode.isNotEmpty && product.barcode != 'null';

    return Dialog(
      backgroundColor: const Color(0xFF0F1C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Product QR Code",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.productName,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: hasValidBarcode
                  ? QrImageView(
                      data: product.barcode,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    )
                  : SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Text(
                          "No barcode assigned\nto this product.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
            if (hasValidBarcode) ...[
              const SizedBox(height: 16),
              Text(
                "Code: ${product.barcode}",
                style: GoogleFonts.inter(
                  color: const Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Close",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
