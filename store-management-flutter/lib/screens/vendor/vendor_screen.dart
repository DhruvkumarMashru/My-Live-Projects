import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/app_database.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});
  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  List<Map<String, dynamic>> _vendors = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('vendors', orderBy: 'company_name ASC');
    setState(() { _vendors = rows; _isLoading = false; });
  }

  void _showAddEditForm([Map<String, dynamic>? existing]) {
    final formKey = GlobalKey<FormState>();
    final companyCtrl = TextEditingController(text: existing?['company_name'] ?? '');
    final addressCtrl = TextEditingController(text: existing?['address'] ?? '');
    final cityCtrl = TextEditingController(text: existing?['city'] ?? '');
    final pinCtrl = TextEditingController(text: existing?['pin_code'] ?? '');
    final stateCtrl = TextEditingController(text: existing?['state'] ?? '');
    final countryCtrl = TextEditingController(text: existing?['country'] ?? '');
    final panCtrl = TextEditingController(text: existing?['pan'] ?? '');
    final gstCtrl = TextEditingController(text: existing?['gst'] ?? '');
    final contactPersonCtrl = TextEditingController(text: existing?['contact_person'] ?? '');
    final contactNumberCtrl = TextEditingController(text: existing?['contact_number'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');

    Get.to(() => Scaffold(
      appBar: AppBar(title: Text(existing == null ? "Add Vendor".tr : "Edit Vendor".tr)),
      body: Form(
        key: formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _sectionHeader("Business Details".tr, Icons.store_rounded),
          _field(companyCtrl, "Company Name".tr + " *", Icons.business_rounded, required: true),
          _field(addressCtrl, "Address".tr, Icons.location_on_outlined),
          Row(children: [
            Expanded(child: _field(cityCtrl, "City".tr, Icons.location_city_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _field(
              pinCtrl, "Pin Code".tr, Icons.pin_drop_rounded, 
              keyboardType: TextInputType.number, 
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)]
            )),
          ]),
          Row(children: [
            Expanded(child: _field(stateCtrl, "State".tr, Icons.map_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _field(countryCtrl, "Country".tr, Icons.flag_rounded)),
          ]),
          _sectionHeader("Business Legal Identity".tr, Icons.verified_rounded),
          _field(panCtrl, "PAN".tr, Icons.credit_card_rounded),
          _field(gstCtrl, "GST".tr, Icons.receipt_long_rounded),
          _sectionHeader("Contact Information".tr, Icons.phone_rounded),
          _field(contactPersonCtrl, "Contact Person Name".tr, Icons.person_rounded),
          _field(
            contactNumberCtrl, "Contact Number".tr, Icons.phone_android_rounded, 
            keyboardType: TextInputType.phone, 
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]
          ),
          _field(emailCtrl, "Email ID".tr, Icons.email_rounded),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            icon: const Icon(Icons.save_rounded),
            label: Text("Save".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'company_name': companyCtrl.text, 'address': addressCtrl.text, 'city': cityCtrl.text, 'pin_code': pinCtrl.text,
                  'state': stateCtrl.text, 'country': countryCtrl.text, 'pan': panCtrl.text, 'gst': gstCtrl.text,
                  'contact_person': contactPersonCtrl.text, 'contact_number': contactNumberCtrl.text, 'email': emailCtrl.text,
                  'is_active': existing?['is_active'] ?? 1,
                };
                final db = await AppDatabase.instance;
                if (existing != null) {
                  await db.update('vendors', data, where: 'id = ?', whereArgs: [existing['id']]);
                } else {
                  await db.insert('vendors', data);
                }
                Get.back();
                _loadData();
                Get.snackbar("Success".tr, "Vendor saved!".tr, backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
          )),
          const SizedBox(height: 32),
        ]),
      ),
    ));
  }

  Widget _sectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(top: 16, bottom: 10), child: Row(children: [
      Icon(icon, size: 20, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
    ]));
  }

  Widget _field(
    TextEditingController ctrl, 
    String label, 
    IconData icon, {
    bool required = false, 
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), 
      child: TextFormField(
        controller: ctrl, 
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label, 
          prefixIcon: Icon(icon, size: 20)
        ), 
        validator: required ? (v) => (v == null || v.isEmpty) ? "Required".tr : null : null
      )
    );
  }

  void _showViewDetails(Map<String, dynamic> v) {
    final theme = Theme.of(context);
    Get.dialog(AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(v['company_name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _infoRow(Icons.location_on_outlined, "Address".tr, "${v['address'] ?? ''}, ${v['city'] ?? ''} ${v['pin_code'] ?? ''}"),
        _infoRow(Icons.map_rounded, "State".tr + " / " + "Country".tr, "${v['state'] ?? ''}, ${v['country'] ?? ''}"),
        _infoRow(Icons.credit_card_rounded, "PAN".tr, v['pan'] ?? ''),
        _infoRow(Icons.receipt_long_rounded, "GST".tr, v['gst'] ?? ''),
        _infoRow(Icons.person_rounded, "Contact Person Name".tr, v['contact_person'] ?? ''),
        _infoRow(Icons.phone_android_rounded, "Contact Number".tr, v['contact_number'] ?? ''),
        _infoRow(Icons.email_rounded, "Email ID".tr, v['email'] ?? ''),
      ])),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text("Back".tr)),
        ElevatedButton(onPressed: () { Get.back(); _showAddEditForm(v); }, child: Text("Edit".tr)),
      ],
    ));
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Icon(icon, size: 16, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
      Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: theme.hintColor))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text("Vendor".tr)), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Vendor".tr)),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddEditForm(), child: const Icon(Icons.add_rounded)),
      body: _vendors.isEmpty
          ? Center(child: Text("No vendors yet. Tap + to add.".tr, style: TextStyle(color: theme.hintColor)))
          : ListView.builder(
              padding: const EdgeInsets.all(16), itemCount: _vendors.length,
              itemBuilder: (ctx, i) {
                final v = _vendors[i];
                return Card(
                  color: theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 10), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.local_shipping_rounded, color: theme.colorScheme.primary)
                    ),
                    title: Text(v['company_name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text("${v['contact_person'] ?? ''} | ${v['contact_number'] ?? ''}\n${v['city'] ?? ''}, ${v['state'] ?? ''}", style: TextStyle(color: theme.hintColor)),
                    isThreeLine: true,
                    trailing: Switch(
                      activeColor: theme.colorScheme.primary,
                      value: v['is_active'] == 1, 
                      onChanged: (val) async {
                        final db = await AppDatabase.instance;
                        await db.update('vendors', {'is_active': val ? 1 : 0}, where: 'id = ?', whereArgs: [v['id']]);
                        _loadData();
                      }
                    ),
                    onTap: () => _showViewDetails(v),
                  )
                );
              }),
    );
  }
}
