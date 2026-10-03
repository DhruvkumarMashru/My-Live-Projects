import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_db/app_database.dart';
import '../local_db/masters_db.dart';
import '../local_db/sales_db.dart';
import '../model/database_models.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static String? get userId => _auth.currentUser?.uid;

  // --- Auth ---
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  static Future<String> resolveAndStoreRole(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      String role = 'employee';

      if (doc.exists) {
        role = doc.data()?['role'] ?? 'employee';
      } else {
        // If first user in firebase (for this project), maybe make them manager?
        // But usually we check if any manager exists.
        final prefs = await SharedPreferences.getInstance();
        final hasOwner = prefs.getBool('has_owner') ?? false;
        role = hasOwner ? 'employee' : 'manager';

        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'New User',
          'email': user.email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (role == 'manager') {
          await prefs.setBool('has_owner', true);
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.uid);
      await prefs.setString('user_email', user.email!);
      await prefs.setString('user_role', role);
      await prefs.setString('user_name', user.displayName ?? 'New User');

      return role;
    } catch (e) {
      print("Role Resolution Error: $e");
      return 'employee';
    }
  }

  // --- Storage ---
  static Future<String?> uploadCompanyLogo(File file) async {
    return _upload(file, 'logo');
  }

  static Future<String?> uploadUserPhoto(File file) async {
    return _upload(file, 'photo');
  }

  static Future<String?> _upload(File file, String name) async {
    if (userId == null) return null;
    try {
      final ref = _storage.ref().child('users/$userId/$name.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Firebase Storage Error: $e");
      return null;
    }
  }

  // --- Firestore Sync ---
  static Future<void> syncLocalDataToCloud() async {
    if (userId == null) return;
    try {
      final db = await AppDatabase.instance;
      
      // 1. Sync Company Profile
      final profile = await db.query('company_profile', limit: 1);
      if (profile.isNotEmpty) {
        await _firestore.collection('users').doc(userId).collection('profile').doc('business_details').set(profile.first);
      }

      // 2. Sync Masters
      final categories = await MastersDb.getAllCategories();
      final subCats = await MastersDb.getAllSubCategories();
      final items = await MastersDb.getAllItems();
      final brands = await MastersDb.getAllBrands();

      final batch = _firestore.batch();
      final masterRef = _firestore.collection('users').doc(userId).collection('masters');

      for (var c in categories) {
        batch.set(masterRef.doc('categories').collection('list').doc(c.id.toString()), c.toMap());
      }
      for (var s in subCats) {
        batch.set(masterRef.doc('sub_categories').collection('list').doc(s.id.toString()), s.toMap());
      }
      for (var i in items) {
        batch.set(masterRef.doc('items').collection('list').doc(i.id.toString()), i.toMap());
      }
      for (var b in brands) {
        batch.set(masterRef.doc('brands').collection('list').doc(b.id.toString()), b.toMap());
      }

      await batch.commit();
      print("Sync to Cloud Complete");
    } catch (e) {
      print("Cloud Sync Error: $e");
    }
  }

  static Future<void> pullCloudDataToLocal() async {
    if (userId == null) return;
    try {
      final masterRef = _firestore.collection('users').doc(userId).collection('masters');
      
      // Pull and Insert logic... 
      // (This can be expanded to fully populate SQLite if it's empty)
      final catSnap = await masterRef.doc('categories').collection('list').get();
      for (var doc in catSnap.docs) {
        final model = CategoryModel.fromMap(doc.data());
        await MastersDb.insertCategory(model);
      }
      
      print("Pull from Cloud Complete");
    } catch (e) {
      print("Pull Sync Error: $e");
    }
  }
}
