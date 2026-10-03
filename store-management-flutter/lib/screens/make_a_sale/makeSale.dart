import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../local_db/masters_db.dart';
import '../../local_db/sales_db_new.dart';
import '../../model/database_models.dart';

class MakeSalePage extends StatefulWidget {
  const MakeSalePage({Key? key}) : super(key: key);

  @override
  _MakeSalePageState createState() => _MakeSalePageState();
}

class _MakeSalePageState extends State<MakeSalePage> {
  bool _isLoading = true;

  List<ItemModel> _allItems = [];
  List<BundleModel> _allBundles = [];
  
  // The cart which will mix items and bundles
  List<CartEntry> _cart = [];
  
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await MastersDb.getAllItems();
    final bundles = await SalesDbNew.getAllBundles();
    
    setState(() {
      _allItems = items;
      _allBundles = bundles;
      _isLoading = false;
    });
  }

  void _addItemToCart(ItemModel item) {
    setState(() {
      // Check if already in cart
      final idx = _cart.indexWhere((e) => e.item?.id == item.id);
      if (idx >= 0) {
        _cart[idx].qty += 1;
        _cart[idx].total = _cart[idx].qty * _cart[idx].price;
      } else {
        // Defaults rate from masters or 100
        double price = item.ratePerQty > 0 ? item.ratePerQty : 100.0;
        _cart.add(CartEntry(item: item, qty: 1, price: price, total: price));
      }
    });
  }

  void _addBundleToCart(BundleModel bundle) {
    setState(() {
      final idx = _cart.indexWhere((e) => e.bundle?.id == bundle.id);
      if (idx >= 0) {
        _cart[idx].qty += 1;
        _cart[idx].total = _cart[idx].qty * _cart[idx].price;
      } else {
        _cart.add(CartEntry(bundle: bundle, qty: 1, price: bundle.price, total: bundle.price));
      }
    });
  }

  void _updateCartItemQty(int index, double newQty) {
    setState(() {
      _cart[index].qty = newQty;
      _cart[index].total = newQty * _cart[index].price;
    });
  }

  void _updateCartItemPrice(int index, double newPrice) {
    setState(() {
      _cart[index].price = newPrice;
      _cart[index].total = _cart[index].qty * newPrice;
    });
  }

  double get _grandTotal {
    return _cart.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _processSale() async {
    if (_cart.isEmpty) {
      Get.snackbar("Error", "Cart is empty!");
      return;
    }

    final sale = SaleModel(
      customerName: _customerNameCtrl.text,
      mobileNumber: _customerPhoneCtrl.text,
      totalAmount: _grandTotal,
      netPayable: _grandTotal, // Defaulting net to grand total
      saleDate: DateTime.now().toIso8601String(),
    );

    List<SaleItemModel> itemsToSave = _cart.map((e) {
      return SaleItemModel(
        saleId: 0,
        itemId: e.item?.id,
        bundleId: e.bundle?.id,
        qty: e.qty,
        rate: e.price,
        total: e.total,
      );
    }).toList();

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    await SalesDbNew.processSale(sale, itemsToSave);
    
    Get.back(); // close loading
    Get.snackbar(
      "Success", 
      "Sale processed & Stock instantly deducted via BOM logic!",
      backgroundColor: const Color(0xFF81C784),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.all(24)
    );

    setState(() {
      _cart.clear();
      _customerNameCtrl.clear();
      _customerPhoneCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF0A1628), body: Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7))));

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Retail Sales Flow".tr,
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
      ),
      body: Row(
        // We will layout search on top, cart in middle.
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search section
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ItemModel>(
                          dropdownColor: const Color(0xFF162534),
                          decoration: _inputDeco("Search & Add Item..."),
                          items: _allItems.map((e) => DropdownMenuItem(value: e, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (v) {
                            if (v != null) _addItemToCart(v);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<BundleModel>(
                          dropdownColor: const Color(0xFF162534),
                          decoration: _inputDeco("Search & Add Bundle Kit..."),
                          items: _allBundles.map<DropdownMenuItem<BundleModel>>((e) => DropdownMenuItem<BundleModel>(value: e, child: Text(e.bundleName, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (v) {
                            if (v != null) _addBundleToCart(v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Cart Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFF0F1C2E),
                    child: Row(
                      children: [
                        const Expanded(flex: 3, child: Text("Description", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Type", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Qty", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Rate", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                        const Expanded(flex: 2, child: Text("Total", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 40), // for delete icon space
                      ],
                    ),
                  ),

                  // Cart List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (ctx, i) {
                        final ci = _cart[i];
                        final desc = ci.item?.name ?? ci.bundle?.bundleName ?? '';
                        final type = ci.item != null ? 'Item' : 'Bundle';
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(desc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              Expanded(
                                flex: 2, 
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: (ci.item != null ? Colors.blue : Colors.purple).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                  child: Text(type, style: TextStyle(color: ci.item != null ? Colors.blueAccent : Colors.amberAccent, fontSize: 12)),
                                )
                              ),
                              Expanded(
                                flex: 2, 
                                child: TextFormField(
                                  initialValue: ci.qty.toStringAsFixed(0),
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                  onChanged: (v) => _updateCartItemQty(i, double.tryParse(v) ?? 0),
                                  decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38))),
                                )
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2, 
                                child: TextFormField(
                                  initialValue: ci.price.toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                  onChanged: (v) => _updateCartItemPrice(i, double.tryParse(v) ?? 0),
                                  decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38))),
                                )
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2, 
                                child: Text("₹${ci.total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold))
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white38, size: 20),
                                onPressed: () => setState(() => _cart.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer Checkout
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162534),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _customerNameCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDeco("Customer Name"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _customerPhoneCtrl,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: _inputDeco("Customer Phone"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("GRAND TOTAL", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("₹ ${_grandTotal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _processSale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3F7),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("PROCESS SALE", style: GoogleFonts.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF162534),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class CartEntry {
  final ItemModel? item;
  final BundleModel? bundle;
  double qty;
  double price;
  double total;

  CartEntry({this.item, this.bundle, required this.qty, required this.price, required this.total});
}
