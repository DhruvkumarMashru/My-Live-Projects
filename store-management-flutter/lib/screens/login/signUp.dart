// ignore_for_file: file_names, body_might_complete_normally_nullable

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/screens/login/login.dart';

import '../../localization/Local_controller.dart';
import '../../main.dart';

class SignUp extends GetWidget<LoginController> {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyLocaleController());
    MyLocaleController controllerlan = Get.find();
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back to login
                          TextButton.icon(
                            onPressed: () => Get.off(() => const Login()),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16, color: Colors.white54),
                            label: Text(
                              "Login".tr,
                              style: GoogleFonts.inter(
                                  color: Colors.white54, fontSize: 14),
                            ),
                          ),
                          // Language toggle
                          InkWell(
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
                                width: 26,
                                height: 26,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Header
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Create Account".tr,
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Set up your store account".tr,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.white54),
                      ),

                      const SizedBox(height: 36),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Form(
                          key: controller.signUpKey,
                          autovalidateMode: controller.signUpAutoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              _buildField(
                                ctrl: controller.nameController,
                                hint: "Full Name".tr,
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (v) => v!.trim().isEmpty
                                    ? "The field is empty".tr
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                ctrl: controller.emailController,
                                hint: "Email".tr,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v!.trim().isEmpty) {
                                    return "The field is empty".tr;
                                  } else if (!EmailValidator.validate(
                                      v.trim())) {
                                    return "The e-mail not valid".tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              GetBuilder<LoginController>(
                                builder: (c) => _buildField(
                                  ctrl: c.passwordController,
                                  hint: "Password".tr,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: c.passVisibility,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      c.passVisibility
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white38,
                                      size: 20,
                                    ),
                                    onPressed: c.passwordEye,
                                  ),
                                  onFieldSubmitted: (_) => controller.signUp(
                                    key: controller.signUpKey,
                                    name: controller.nameController.text,
                                    password: c.passwordController.text,
                                    email: controller.emailController.text,
                                    mangerPassword: '',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "The field is empty".tr;
                                    }
                                    if (v.trim().length < 8) {
                                      return "Password must be at least 8 characters".tr;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign Up button
                      GetBuilder<LoginController>(
                        builder: (c) {
                          final isDisabled = c.isLoading;
                          return AnimatedOpacity(
                            opacity: isDisabled ? 0.6 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: isDisabled
                                  ? null
                                  : () => c.signUp(
                                        key: c.signUpKey,
                                        name: c.nameController.text,
                                        password: c.passwordController.text,
                                        email: c.emailController.text,
                                        mangerPassword: '',
                                      ),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF81C784),
                                      Color(0xFF388E3C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF388E3C)
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
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          "Sign Up".tr,
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

                      const SizedBox(height: 24),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ".tr,
                              style: GoogleFonts.inter(
                                  color: Colors.white54, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => Get.off(() => const Login()),
                              child: Text(
                                "Login".tr,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4FC3F7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
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
      controller: ctrl,
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
          borderSide: const BorderSide(color: Color(0xFF81C784), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle:
            GoogleFonts.inter(color: const Color(0xFFFF6B6B), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
