// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/Home/home.dart';
import '../screens/login/manegerOrEmployee.dart';
import '../screens/make_a_sale/cashierScreens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/firebase_service.dart';
import '../shared/app_feedback.dart';
import '../shared/constants.dart';

class LoginController extends GetxController {
  // ******* Variables ***********
  bool passVisibility = true;
  bool isLoading = false;
  bool loginAutoValidate = false;
  bool signUpAutoValidate = false;

  static const _kUserRoles = 'user_roles';
  static const _kUserPasswords = 'user_passwords';
  static const _kUserNames = 'user_names';
  static const _kHasOwner = 'has_owner';
  static const _kManagerPassword = 'manager_password';
  static const _kUserCreatedAt = 'user_created_at';
  // Here is controllers for signup
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mangerPasswordController = TextEditingController();

  // Here is controller for login
  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();

  // Here is controller for reset manager controller
  TextEditingController currentManagerPasswodController =
      TextEditingController();
  TextEditingController newManagerPasswordController = TextEditingController();

  // Here is controller for reset controller
  TextEditingController currentPasswodController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  // When user login and going to manager or employees page
  TextEditingController managerPassController = TextEditingController();

  // Keys
  GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  GlobalKey<FormState> resetPasswordKey = GlobalKey<FormState>();
  GlobalKey<FormState> resetManagerPasswordKey = GlobalKey<FormState>();

  // ******* Methods ***********
  void passwordEye() {
    passVisibility = !passVisibility;
    update();
  }

  void _setLoading(bool value) {
    isLoading = value;
    update();
  }

  Future<Map<String, dynamic>> _readJsonMap(
    SharedPreferences prefs,
    String key,
  ) async {
    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _writeJsonMap(
    SharedPreferences prefs,
    String key,
    Map<String, dynamic> value,
  ) async {
    await prefs.setString(key, json.encode(value));
  }

  void _showAuthError(String message) {
    Get.snackbar(
      "Oops!".tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// ========= SignUp Method =========
  signUp({
    required GlobalKey<FormState> key,
    required String name,
    required String password,
    required String email,
    required String mangerPassword,
  }) async {
    final isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      signUpAutoValidate = true;
      update();
      return;
    }
    if (isLoading) return;
    if (key.currentState!.validate()) {
      key.currentState!.save();
      _setLoading(true);
      _showLoadingDialog("Creating Account".tr);

      try {
        final prefs = await SharedPreferences.getInstance();
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(), 
          password: password.trim()
        );
        
        final user = userCredential.user;
        if (user != null) {
          final hasOwner = prefs.getBool(_kHasOwner) ?? false;
          final role = hasOwner ? 'employee' : 'manager';
          
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': name.trim(),
            'email': email.trim().toLowerCase(),
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (role == 'manager') await prefs.setBool(_kHasOwner, true);
          
          await prefs.setString('token', user.uid);
          await prefs.setString('user_name', name.trim());
          await prefs.setString('user_email', email.trim());
          await prefs.setString('user_role', role);

          Get.back();
          _setLoading(false);
          return Get.offAll(() => const Home());
        }
      } catch (e) {
        Get.back();
        _setLoading(false);
        AppFeedback.error(e.toString());
      }
    }
  }

  void _showLoadingDialog(String title) {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (BuildContext context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: kprimaryColor),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(color: Colors.black, decoration: TextDecoration.none, fontSize: 16)),
          ]),
        ),
      ),
    );
  }


  /// ========= Manager tools (local-only) =========
  Future<List<Map<String, String>>> listLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = await _readJsonMap(prefs, _kUserRoles);
    final names = await _readJsonMap(prefs, _kUserNames);
    final createdAt = await _readJsonMap(prefs, _kUserCreatedAt);

    final users = roles.keys.map((email) {
      return <String, String>{
        'email': email.toString(),
        'role': (roles[email] ?? 'employee').toString(),
        'name': (names[email] ?? '').toString(),
        'createdAt': (createdAt[email] ?? '').toString(),
      };
    }).toList();

    users.sort((a, b) => (a['email'] ?? '').compareTo(b['email'] ?? ''));
    return users;
  }

  Future<void> createLocalUser({
    required String name,
    required String email,
    required String password,
    required String role, // 'manager' | 'employee'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();
    final normalizedPassword = password.trim();
    final normalizedRole = role.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPassword.isEmpty) {
      AppFeedback.error("Please fill all fields.");
      return;
    }
    if (!EmailValidator.validate(normalizedEmail)) {
      AppFeedback.error("The e-mail not valid");
      return;
    }
    if (normalizedPassword.length < 8) {
      AppFeedback.error("Password must be at least 8 characters");
      return;
    }
    if (normalizedRole != 'manager' &&
        normalizedRole != 'employee' &&
        normalizedRole != 'cashier') {
      AppFeedback.error("Invalid role");
      return;
    }

    final roles = await _readJsonMap(prefs, _kUserRoles);
    final passwords = await _readJsonMap(prefs, _kUserPasswords);
    final names = await _readJsonMap(prefs, _kUserNames);
    final createdAt = await _readJsonMap(prefs, _kUserCreatedAt);

    if (roles.containsKey(normalizedEmail)) {
      AppFeedback.error("This email is already registered");
      return;
    }

    roles[normalizedEmail] = normalizedRole;
    passwords[normalizedEmail] = normalizedPassword;
    names[normalizedEmail] = normalizedName;
    createdAt[normalizedEmail] = DateTime.now().toIso8601String();

    await _writeJsonMap(prefs, _kUserRoles, roles);
    await _writeJsonMap(prefs, _kUserPasswords, passwords);
    await _writeJsonMap(prefs, _kUserNames, names);
    await _writeJsonMap(prefs, _kUserCreatedAt, createdAt);
  }

  Future<void> resetLocalUserPassword({
    required String email,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = newPassword.trim();

    if (normalizedPassword.length < 8) {
      AppFeedback.error("Password must be at least 8 characters");
      return;
    }

    final roles = await _readJsonMap(prefs, _kUserRoles);
    if (!roles.containsKey(normalizedEmail)) {
      AppFeedback.error("No account found");
      return;
    }

    final passwords = await _readJsonMap(prefs, _kUserPasswords);
    passwords[normalizedEmail] = normalizedPassword;
    await _writeJsonMap(prefs, _kUserPasswords, passwords);
  }

  Future<void> deleteLocalUser({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();

    final roles = await _readJsonMap(prefs, _kUserRoles);
    if (!roles.containsKey(normalizedEmail)) return;

    // Prevent deleting the last/owner manager account.
    final managerCount = roles.values
        .where((v) => v != null && v.toString() == 'manager')
        .length;
    if (roles[normalizedEmail].toString() == 'manager' && managerCount <= 1) {
      AppFeedback.warning("You can’t delete the last manager account.");
      return;
    }

    final passwords = await _readJsonMap(prefs, _kUserPasswords);
    final names = await _readJsonMap(prefs, _kUserNames);
    final createdAt = await _readJsonMap(prefs, _kUserCreatedAt);

    roles.remove(normalizedEmail);
    passwords.remove(normalizedEmail);
    names.remove(normalizedEmail);
    createdAt.remove(normalizedEmail);

    await _writeJsonMap(prefs, _kUserRoles, roles);
    await _writeJsonMap(prefs, _kUserPasswords, passwords);
    await _writeJsonMap(prefs, _kUserNames, names);
    await _writeJsonMap(prefs, _kUserCreatedAt, createdAt);
  }

  /// ========== SignIn Method ==========
  signIn({
    required GlobalKey<FormState> key,
    required String password,
    required String email,
  }) async {
    final isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      loginAutoValidate = true;
      update();
      return;
    }
    if (isLoading) return;
    if (key.currentState!.validate()) {
      key.currentState!.save();
      _setLoading(true);
      _showLoadingDialog("Logging In".tr);

      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), 
          password: password.trim()
        );
        
        final user = userCredential.user;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data() ?? {};
          final role = data['role'] ?? 'employee';
          final name = data['name'] ?? '';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.uid);
          await prefs.setString('user_email', user.email!);
          await prefs.setString('user_role', role);
          await prefs.setString('user_name', name);

          if (role == 'manager') {
            await FirebaseService.pullCloudDataToLocal();
          }

          Get.back();
          _setLoading(false);
          passwordLoginController.clear();
          emailLoginController.clear();

          if (role == 'manager') {
            return Get.offAll(() => const ManegerOrEmployeePage());
          } else {
            return Get.offAll(() => const CashierScreensPage());
          }
        }
      } catch (e) {
        Get.back();
        _setLoading(false);
        AppFeedback.error("Login Failed: Check credentials".tr);
      }
    }
  }

  /// ========== Reset Password ==========
  resetPassword({
    required GlobalKey<FormState> key,
    required String currentPasswod,
    required String newPassword,
    required bool isManager,
  }) async {
    if (key.currentState!.validate()) {
      key.currentState!.save();
      _showLoadingDialog("Changing Password".tr);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword.trim());
          Get.back();
          AppFeedback.success("Password updated successfully");
          Get.off(() => const Home());
        }
      } catch (e) {
        Get.back();
        AppFeedback.error(e.toString());
      }
    }
  }

  /// ========== Sign in manager with just password ==========
  signInManager({required String password}) async {
    if (password.trim().length > 7) {
      _showLoadingDialog("Verifying".tr);
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('user_email');
        if (email != null) {
          // Re-auth logic for manager profile access
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, 
            password: password.trim()
          );
          
          Get.back();
          managerPassController.clear();
          return Get.to(() => const Home(), transition: Transition.zoom);
        }
      } catch (e) {
        Get.back();
        AppFeedback.error("Incorrect Password");
      }
    }
  }


  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mangerPasswordController.dispose();
    emailLoginController.dispose();
    passwordLoginController.dispose();
    currentManagerPasswodController.dispose();
    newManagerPasswordController.dispose();
    currentPasswodController.dispose();
    newPasswordController.dispose();
    managerPassController.dispose();
    super.onClose();
  }
}
