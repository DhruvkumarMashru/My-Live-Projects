// ignore_for_file: body_might_complete_normally_nullable

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/screens/login/signUp.dart';
import 'package:store_management_modern/shared/firebase_service.dart';
import 'package:store_management_modern/shared/roles.dart';
import 'package:store_management_modern/screens/Home/home.dart';
import 'package:store_management_modern/screens/make_a_sale/cashierScreens.dart';

import '../../localization/Local_controller.dart';
import '../../main.dart';

class Login extends GetWidget<LoginController> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyLocaleController());
    MyLocaleController controllerlan = Get.find();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1C2E),
              Color(0xFF1A2F4A),
              Color(0xFF243B55),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Top row: lang switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          String curr = shaedpref.getString("curruntLang") ?? "en";
                          if (curr == "en") controllerlan.ChangeLang("hi");
                          else if (curr == "hi") controllerlan.ChangeLang("gu");
                          else controllerlan.ChangeLang("en");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Image(
                            image: AssetImage("images/Translation.png"),
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Logo / header
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Welcome Back".tr,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sign in to your store account".tr,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Form card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Form(
                        key: controller.loginKey,
                        autovalidateMode: controller.loginAutoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Login".tr,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildField(
                              controller: controller.emailLoginController,
                              hint: "Email".tr,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return "The field is empty".tr;
                                } else if (!EmailValidator.validate(
                                    value.trim())) {
                                  return "The e-mail not valid".tr;
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            GetBuilder<LoginController>(
                              builder: (c) => _buildField(
                                controller: c.passwordLoginController,
                                hint: "Password".tr,
                                icon: Icons.lock_outline,
                                obscureText: c.passVisibility,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    c.passVisibility
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: c.passwordEye,
                                ),
                                onFieldSubmitted: (_) => c.signIn(
                                  key: c.loginKey,
                                  password: c.passwordLoginController.text,
                                  email: c.emailLoginController.text,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "The field is empty".tr;
                                  }
                                  if (value.trim().length < 8) {
                                    return "Password must be at least 8 characters".tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 28),
                            GetBuilder<LoginController>(
                              builder: (_) {
                                final isDisabled = controller.isLoading;
                                return AnimatedOpacity(
                                  opacity: isDisabled ? 0.6 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: GestureDetector(
                                    onTap: isDisabled
                                        ? null
                                        : () => controller.signIn(
                                              key: controller.loginKey,
                                              password: controller
                                                  .passwordLoginController.text,
                                              email: controller
                                                  .emailLoginController.text,
                                            ),
                                    child: Container(
                                      width: double.infinity,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4FC3F7),
                                            Color(0xFF0288D1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0288D1)
                                                .withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: isDisabled
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                "Login".tr,
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── OR divider ──────────────────────────────────────────
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR'.tr, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ),
                  ),

                  // ── Google Sign-In ──────────────────────────────────────
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _GoogleSignInButton(),
                  ),

                  const SizedBox(height: 28),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't Have An Account? ".tr,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.off(() => const SignUp()),
                        child: Text(
                          "Sign Up".tr,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4FC3F7),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(color: const Color(0xFFFF6B6B), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────
class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton();
  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await FirebaseService.signInWithGoogle();
      if (user == null) {
        setState(() => _loading = false);
        return; // cancelled
      }

      final role = await FirebaseService.resolveAndStoreRole(user);

      if (role == AppRoles.manager) {
        Get.offAll(() => const Home());
      } else {
        Get.offAll(() => const CashierScreensPage());
      }
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar(
        'Sign In Failed'.tr,
        e.toString(),
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _handleGoogleSignIn,
      child: AnimatedOpacity(
        opacity: _loading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google'.tr,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

