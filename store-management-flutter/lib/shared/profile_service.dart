import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../local_db/app_database.dart';

class ProfileService {
  static Future<void> pickAndSaveAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final db = await AppDatabase.instance;
      // Ensure company_profile exists
      final check = await db.query('company_profile', limit: 1);
      if (check.isEmpty) {
        await db.insert('company_profile', {'id': 1, 'photo_path': image.path});
      } else {
        await db.update('company_profile', {'photo_path': image.path}, where: 'id = ?', whereArgs: [check.first['id']]);
      }
    }
  }

  static Future<File?> loadAvatarFile() async {
    final path = await getProfileImage();
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) return file;
    }
    return null;
  }

  static Future<String?> getProfileImage() async {
    try {
      final db = await AppDatabase.instance;
      final row = await db.query('company_profile', limit: 1);
      if (row.isNotEmpty) {
        return row.first['photo_path']?.toString() ?? row.first['logo_path']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
