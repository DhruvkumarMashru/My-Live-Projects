import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../local_db/masters_db.dart';
import '../../model/database_models.dart';
import '../../shared/master_validation.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({Key? key}) : super(key: key);

  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<BrandModel> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MastersDb.getAllBrands();
    setState(() {
      _brands = data;
      _isLoading = false;
    });
  }

  void _showAddEditForm([BrandModel? model]) {
    final _formKey = GlobalKey<FormState>();
    final _nameCtrl = TextEditingController(text: model?.name ?? '');
    final _remarksCtrl = TextEditingController(text: model?.remarks ?? '');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model == null ? "Add Brand".tr : "Edit Brand".tr,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Brand Name *".tr,
                    prefixIcon: const Icon(Icons.branding_watermark_rounded),
                  ),
                  validator: MasterValidation.validateBrandName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksCtrl,
                  decoration: InputDecoration(
                    labelText: "Remarks".tr,
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                  validator: MasterValidation.validateRemarks,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newModel = BrandModel(
                          id: model?.id,
                          name: _nameCtrl.text,
                          remarks: _remarksCtrl.text,
                          isActive: model?.isActive ?? 1,
                        );
                        if (model == null) {
                          await MastersDb.insertBrand(newModel);
                        } else {
                          await MastersDb.updateBrand(newModel);
                        }
                        Get.back();
                        _loadData();
                      }
                    },
                    child: Text("Save".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showViewDetails(BrandModel model) {
    Get.defaultDialog(
      title: "Brand Details".tr,
      content: Column(
        children: [
          _detailTile("Brand Name".tr, model.name),
          _detailTile("Remarks".tr, model.remarks ?? '-'),
          _detailTile("Status".tr, model.isActive == 1 ? 'Active'.tr : 'Inactive'.tr),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          _showAddEditForm(model);
        },
        child: Text("Edit".tr),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Back".tr),
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${label.tr}:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () => _showAddEditForm(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _brands.length,
        itemBuilder: (ctx, i) {
          final b = _brands[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(b.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text("${"Status".tr}: ${b.isActive == 1 ? 'Active'.tr : 'Inactive'.tr}", style: TextStyle(color: b.isActive == 1 ? Colors.green : Colors.red, fontSize: 12)),
              trailing: Switch(
                value: b.isActive == 1,
                onChanged: (v) async {
                  b.isActive = v ? 1 : 0;
                  await MastersDb.updateBrand(b);
                  _loadData();
                },
              ),
              onTap: () => _showViewDetails(b),
            ),
          );
        },
      ),
    );
  }
}
