import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_management_modern/local_db/app_database.dart';
import 'package:store_management_modern/shared/firebase_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});
  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _contactNumberCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _businessNumberCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _regNumberCtrl = TextEditingController();
  final _licenceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _miscCtrl = TextEditingController();

  String? _logoUrl, _photoUrl;
  File? _logoFile, _photoFile;
  bool _isLoading = false;
  int? _profileId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('company_profile', limit: 1);
    if (rows.isNotEmpty) {
      final r = rows.first;
      _profileId = r['id'] as int;
      _nameCtrl.text = r['company_name']?.toString() ?? '';
      _addressCtrl.text = r['address']?.toString() ?? '';
      _cityCtrl.text = r['city']?.toString() ?? '';
      _pinCtrl.text = r['pin_code']?.toString() ?? '';
      _stateCtrl.text = r['state']?.toString() ?? '';
      _countryCtrl.text = r['country']?.toString() ?? '';
      _contactPersonCtrl.text = r['contact_person']?.toString() ?? '';
      _contactNumberCtrl.text = r['contact_number']?.toString() ?? '';
      _emailCtrl.text = r['email']?.toString() ?? '';
      _businessNumberCtrl.text = r['business_number']?.toString() ?? '';
      _panCtrl.text = r['pan']?.toString() ?? '';
      _gstCtrl.text = r['gst']?.toString() ?? '';
      _regNumberCtrl.text = r['registration_number']?.toString() ?? '';
      _licenceCtrl.text = r['licence_number']?.toString() ?? '';
      _descriptionCtrl.text = r['business_description']?.toString() ?? '';
      _websiteCtrl.text = r['website']?.toString() ?? '';
      _linkedinCtrl.text = r['linkedin']?.toString() ?? '';
      _instagramCtrl.text = r['instagram']?.toString() ?? '';
      _facebookCtrl.text = r['facebook']?.toString() ?? '';
      _xCtrl.text = r['x_platform']?.toString() ?? '';
      _miscCtrl.text = r['miscellaneous']?.toString() ?? '';
      _logoUrl = r['logo_path']?.toString();
      _photoUrl = r['photo_path']?.toString();
      setState(() {});
    }
  }

  Future<void> _pickLogo() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (xFile == null) return;
    setState(() => _logoFile = File(xFile.path));
  }

  Future<void> _pickPhoto() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (xFile == null) return;
    setState(() => _photoFile = File(xFile.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Storage logic: Try to upload to Firebase, but ALWAYS store the local path as a fallback
    String? logoPath = _logoUrl;
    if (_logoFile != null) {
      logoPath = _logoFile!.path; // Store local path immediately
      try {
        final url = await FirebaseService.uploadCompanyLogo(_logoFile!);
        if (url != null) {
          logoPath = url; // Upgrade to network URL if upload succeeds
        }
      } catch (e) {
        print("Logo upload skipped/failed: $e");
      }
    }

    String? photoPath = _photoUrl;
    if (_photoFile != null) {
      photoPath = _photoFile!.path; // Store local path immediately
      try {
        final url = await FirebaseService.uploadUserPhoto(_photoFile!);
        if (url != null) {
          photoPath = url; // Upgrade to network URL if upload succeeds
        }
      } catch (e) {
        print("Photo upload skipped/failed: $e");
      }
    }

    final data = {
      'logo_path': logoPath,
      'photo_path': photoPath,
      'company_name': _nameCtrl.text,
      'address': _addressCtrl.text,
      'city': _cityCtrl.text,
      'pin_code': _pinCtrl.text,
      'state': _stateCtrl.text,
      'country': _countryCtrl.text,
      'contact_person': _contactPersonCtrl.text,
      'contact_number': _contactNumberCtrl.text,
      'email': _emailCtrl.text,
      'business_number': _businessNumberCtrl.text,
      'pan': _panCtrl.text,
      'gst': _gstCtrl.text,
      'registration_number': _regNumberCtrl.text,
      'licence_number': _licenceCtrl.text,
      'business_description': _descriptionCtrl.text,
      'website': _websiteCtrl.text,
      'linkedin': _linkedinCtrl.text,
      'instagram': _instagramCtrl.text,
      'facebook': _facebookCtrl.text,
      'x_platform': _xCtrl.text,
      'miscellaneous': _miscCtrl.text,
    };

    final db = await AppDatabase.instance;
    if (_profileId != null) {
      await db.update('company_profile', data, where: 'id = ?', whereArgs: [_profileId]);
    } else {
      await db.insert('company_profile', data);
    }

    // Sync to Firebase
    await FirebaseService.syncLocalDataToCloud();

    setState(() => _isLoading = false);
    Get.snackbar('Success'.tr, 'Company profile saved!'.tr, backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Company Profile'.tr)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── Logo ────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _pickLogo,
                              child: _imageContainer(_logoFile, _logoUrl, Icons.store_rounded),
                            ),
                            const SizedBox(height: 8),
                            Text('Logo'.tr, style: theme.textTheme.labelMedium),
                          ],
                        ),
                        const SizedBox(width: 40),
                        // Photo
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: _imageContainer(_photoFile, _photoUrl, Icons.person_rounded),
                            ),
                            const SizedBox(height: 8),
                            Text('Profile Photo'.tr, style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Business Details ────────────────────────
                  _sectionHeader('Business Details'.tr, Icons.store_rounded),
                  _field(_nameCtrl, 'Business Name'.tr + ' *', Icons.storefront_rounded, required: true),
                  _field(_addressCtrl, 'Address'.tr, Icons.location_on_outlined),
                  Row(children: [
                    Expanded(child: _field(_cityCtrl, 'City'.tr, Icons.location_city_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _field(
                      _pinCtrl, 'Pin Code'.tr, Icons.pin_drop_rounded, 
                      keyboardType: TextInputType.number, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)]
                    )),
                  ]),
                  Row(children: [
                    Expanded(child: _field(_stateCtrl, 'State'.tr, Icons.map_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _field(_countryCtrl, 'Country'.tr, Icons.flag_rounded)),
                  ]),
                  _field(_descriptionCtrl, 'Business Description'.tr, Icons.description_rounded, maxLines: 3),

                  // ─── Legal Identity ──────────────────────────
                  _sectionHeader('Business Legal Identity'.tr, Icons.verified_rounded),
                  _field(_panCtrl, 'PAN'.tr, Icons.credit_card_rounded),
                  _field(_gstCtrl, 'GST'.tr, Icons.receipt_long_rounded),
                  _field(_regNumberCtrl, 'Registration Number'.tr, Icons.assignment_rounded),
                  _field(_licenceCtrl, 'Licence Number'.tr, Icons.card_membership_rounded),

                  // ─── Contact Information ─────────────────────
                  _sectionHeader('Contact Information'.tr, Icons.phone_rounded),
                  _field(_contactPersonCtrl, 'Contact Person Name'.tr, Icons.person_rounded),
                  _field(
                    _contactNumberCtrl, 'Contact Number'.tr, Icons.phone_android_rounded, 
                    keyboardType: TextInputType.phone, 
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]
                  ),
                  _field(_emailCtrl, 'Email'.tr, Icons.email_rounded),
                  _field(
                    _businessNumberCtrl, 'Business Number'.tr, Icons.business_center_rounded, 
                    keyboardType: TextInputType.phone, 
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]
                  ),

                  // ─── Social Media ────────────────────────────
                  _sectionHeader('Social Media'.tr, Icons.share_rounded),
                  _field(_websiteCtrl, 'Website'.tr, Icons.language_rounded),
                  _field(_linkedinCtrl, 'LinkedIn'.tr, Icons.work_outline_rounded),
                  _field(_instagramCtrl, 'Instagram'.tr, Icons.camera_alt_rounded),
                  _field(_facebookCtrl, 'Facebook'.tr, Icons.facebook_rounded),
                  _field(_xCtrl, 'X'.tr, Icons.alternate_email_rounded),

                  // ─── Miscellaneous ───────────────────────────
                  _sectionHeader('Miscellaneous Info'.tr, Icons.more_horiz_rounded),
                  _field(_miscCtrl, 'Other Info'.tr, Icons.info_outline_rounded, maxLines: 3),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: Text('Save Profile'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
      ]),
    );
  }

  Widget _field(
    TextEditingController ctrl, 
    String label, 
    IconData icon, {
    bool required = false, 
    int maxLines = 1, 
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      ),
    );
  }

  Widget _imageContainer(File? file, String? url, IconData fallback) {
    final theme = Theme.of(context);
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        image: file != null
            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
            : (url != null && url.isNotEmpty)
                ? (url.startsWith('http') 
                    ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                    : DecorationImage(image: FileImage(File(url)), fit: BoxFit.cover)) 
                : null,
      ),
      child: (file == null && (url == null || url.isEmpty))
          ? Icon(fallback, size: 36, color: theme.iconTheme.color)
          : null,
    );
  }
}

