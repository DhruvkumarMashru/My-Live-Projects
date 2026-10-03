import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../local_db/vendor_db.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({Key? key}) : super(key: key);

  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  List<VendorModel> _vendors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await VendorDb.getAllVendors();
    setState(() {
      _vendors = data;
      _isLoading = false;
    });
  }

  void _showAddEditForm([VendorModel? model]) {
    final _formKey = GlobalKey<FormState>();

    final _companyNameCtrl = TextEditingController(text: model?.companyName ?? '');
    final _addressCtrl = TextEditingController(text: model?.address ?? '');
    final _cityCtrl = TextEditingController(text: model?.city ?? '');
    final _pinCtrl = TextEditingController(text: model?.pinCode ?? '');
    final _stateCtrl = TextEditingController(text: model?.state ?? '');
    final _countryCtrl = TextEditingController(text: model?.country ?? '');
    
    final _panCtrl = TextEditingController(text: model?.pan ?? '');
    final _gstCtrl = TextEditingController(text: model?.gst ?? '');
    
    final _contactPersonCtrl = TextEditingController(text: model?.contactPerson ?? '');
    final _contactNumberCtrl = TextEditingController(text: model?.contactNumber ?? '');
    final _emailCtrl = TextEditingController(text: model?.email ?? '');

    Get.bottomSheet(
      Container(
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
                model == null ? "Add Vendor" : "Edit Vendor",
                style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Company Details"),
              _buildTextField("Company Name *", _companyNameCtrl, isRequired: true),
              _buildTextField("Address", _addressCtrl),
              Row(
                children: [
                  Expanded(child: _buildTextField("City", _cityCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Pin Code", _pinCtrl)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField("State", _stateCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Country", _countryCtrl)),
                ],
              ),

              _buildSectionTitle("Business Legal Info"),
              Row(
                children: [
                  Expanded(child: _buildTextField("PAN", _panCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("GST", _gstCtrl)),
                ],
              ),

              _buildSectionTitle("Contact Information"),
              _buildTextField("Contact Person", _contactPersonCtrl),
              Row(
                children: [
                  Expanded(child: _buildTextField("Number", _contactNumberCtrl, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Email", _emailCtrl, keyboardType: TextInputType.emailAddress)),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newModel = VendorModel(
                        id: model?.id,
                        companyName: _companyNameCtrl.text,
                        address: _addressCtrl.text,
                        city: _cityCtrl.text,
                        pinCode: _pinCtrl.text,
                        state: _stateCtrl.text,
                        country: _countryCtrl.text,
                        pan: _panCtrl.text,
                        gst: _gstCtrl.text,
                        contactPerson: _contactPersonCtrl.text,
                        contactNumber: _contactNumberCtrl.text,
                        email: _emailCtrl.text,
                        isActive: model?.isActive ?? 1,
                      );
                      if (model == null) {
                        await VendorDb.insertVendor(newModel);
                      } else {
                        await VendorDb.updateVendor(newModel);
                      }
                      Get.back();
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Save Vendor", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.tr,
        style: GoogleFonts.inter(
          color: const Color(0xFF4FC3F7),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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

  Future<void> _toggleStatus(VendorModel model) async {
    model.isActive = model.isActive == 1 ? 0 : 1;
    await VendorDb.updateVendor(model);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628), // Dark aesthetic
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Vendors".tr,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vendors.length,
              itemBuilder: (ctx, i) {
                final v = _vendors[i];
                return Card(
                  color: const Color(0xFF162534),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                v.companyName,
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Switch(
                              value: v.isActive == 1,
                              onChanged: (val) => _toggleStatus(v),
                              activeColor: const Color(0xFF4FC3F7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Contact: ${v.contactPerson ?? 'N/A'} | ${v.contactNumber ?? ''}",
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Location: ${v.city ?? ''}, ${v.state ?? ''}",
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _showAddEditForm(v),
                            icon: const Icon(Icons.edit_rounded, color: Color(0xFF4FC3F7), size: 16),
                            label: Text("Edit", style: GoogleFonts.inter(color: const Color(0xFF4FC3F7))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4FC3F7),
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
        onPressed: () => _showAddEditForm(),
      ),
    );
  }
}
