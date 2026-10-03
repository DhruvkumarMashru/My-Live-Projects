import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../local_db/masters_db.dart';
import '../../local_db/sales_db_new.dart';
import '../../model/database_models.dart';

class BundleScreen extends StatefulWidget {
  const BundleScreen({Key? key}) : super(key: key);

  @override
  _BundleScreenState createState() => _BundleScreenState();
}

class _BundleScreenState extends State<BundleScreen> {
  List<BundleModel> _bundles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await SalesDbNew.getAllBundles();
    setState(() {
      _bundles = data;
      _isLoading = false;
    });
  }

  void _showAddEditForm() async {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController();
    final _descCtrl = TextEditingController();
    final _priceCtrl = TextEditingController();

    // Map of item_id -> quantity needed.
    Map<int, double> selectedBOMItems = {}; 
    
    final allItems = await MastersDb.getAllItems();
    
    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1C2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Add Bundle (BOM)",
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField("Bundle/Kit Name *", _nameCtrl, isRequired: true),
                  _buildTextField(
                    "Default Sale Price", _priceCtrl, 
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                  ),
                  _buildTextField("Description", _descCtrl),

                  const Divider(color: Colors.white24, height: 32),
                  Text("BOM Items Selector", style: GoogleFonts.inter(color: const Color(0xFF4FC3F7), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Show selected BOM
                  if (selectedBOMItems.isEmpty)
                    Text("No items added to this bundle yet.", style: GoogleFonts.inter(color: Colors.white54, fontSize: 13))
                  else
                    ...selectedBOMItems.entries.map((req) {
                      final i = allItems.firstWhere((x) => x.id == req.key);
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(i.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Req Qty: ${req.value}", style: const TextStyle(color: Color(0xFF4FC3F7))),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          onPressed: () {
                            setModalState(() => selectedBOMItems.remove(req.key));
                          },
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 12),
                  // Dropdown to add item
                  DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF162534),
                    decoration: InputDecoration(
                      labelText: "Add an Item to Bundle...",
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF162534),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: allItems.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        // Ask for Quantity Dialog
                        _askQtyDialog(v, allItems.firstWhere((e) => e.id == v).name, (double qty) {
                          setModalState(() {
                            selectedBOMItems[v] = qty;
                          });
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (selectedBOMItems.isEmpty) {
                            Get.snackbar("Error", "Bundle must have at least one item", backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }
                          
                          final bundle = BundleModel(
                            bundleName: _nameCtrl.text,
                            description: _descCtrl.text,
                            price: double.tryParse(_priceCtrl.text) ?? 0.0,
                          );

                          List<BundleItemModel> bim = [];
                          selectedBOMItems.forEach((key, val) {
                            bim.add(BundleItemModel(bundleId: 0, itemId: key, qty: val));
                          });

                          await SalesDbNew.insertBundle(bundle, bim);
                          Get.back();
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text("Save Bundle", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
    );
  }

  void _askQtyDialog(int itemId, String itemName, Function(double) onQty) {
    final qtyCtrl = TextEditingController(text: "1");
    Get.defaultDialog(
      backgroundColor: const Color(0xFF0F1C2E),
      titleStyle: GoogleFonts.inter(color: Colors.white),
      title: "Quantity Needed",
      content: TextField(
        controller: qtyCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Qty of $itemName per bundle",
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF162534),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7)),
        onPressed: () {
          Get.back();
          onQty(double.tryParse(qtyCtrl.text) ?? 1.0);
        },
        child: const Text("Add", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showViewDetails(BundleModel model) async {
    final items = await SalesDbNew.getBundleItems(model.id!);
    Get.defaultDialog(
      backgroundColor: const Color(0xFF0F1C2E),
      titleStyle: GoogleFonts.inter(color: Colors.white),
      title: "Bundle: ${model.bundleName}",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Price: ₹${model.price}", style: const TextStyle(color: Color(0xFF81C784))),
          const Divider(color: Colors.white24),
          const Text("Bill of Materials:", style: TextStyle(color: Colors.white54)),
          ...items.map((e) => ListTile(
            dense: true,
            title: Text(e.itemName, style: const TextStyle(color: Colors.white)),
            trailing: Text("Qty: ${e.qty}", style: const TextStyle(color: Color(0xFF4FC3F7))),
          )).toList(),
        ],
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Close", style: TextStyle(color: Colors.white54)),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label.tr,
          labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF162534),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: isRequired ? (v) => v!.isEmpty ? "Required" : null : null,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4FC3F7),
        child: const Icon(Icons.playlist_add_rounded, color: Colors.black),
        onPressed: () => _showAddEditForm(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bundles.length,
        itemBuilder: (ctx, i) {
          final b = _bundles[i];
          return Card(
            color: const Color(0xFF162534),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(b.bundleName, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text("Price: ₹${b.price}", style: const TextStyle(color: Color(0xFF81C784), fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
              onTap: () => _showViewDetails(b),
            ),
          );
        },
      ),
    );
  }
}
