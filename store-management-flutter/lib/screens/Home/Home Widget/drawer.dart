import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/screens/login/login.dart';
import 'package:store_management_modern/screens/login/resetPassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/confirmAndcancel.dart';
import '../../admin/rbac_management.dart';
import '../../admin/user_management.dart';
import '../../Inventory Screens/inventory_report_screen.dart';
import '../../Performance Screens/performance.dart';
import '../../vendor/vendor_screen.dart';
import '../../../controller/theme_controller.dart';
import '../../company_profile/company_profile_screen.dart';
import '../../masters/masters_screen.dart';
import '../../login/ResetManegerPassword.dart';
import '../../make_a_sale/cashierScreens.dart';
import '../../purchases/stock_in_page.dart';
import '../../Account/accounts.dart';
import '../../../shared/roles.dart';
import '../../../shared/profile_service.dart';
import '../../reports/purchase_reports.dart';
import '../../Performance Screens/selesReports.dart';
import '../../../controller/demo_controller.dart';

class DrawerWidget extends GetWidget<LoginController> {
  DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snap) {
          final prefs = snap.data;
          final role = prefs?.getString('user_role') ?? AppRoles.employee;
          final name = prefs?.getString('user_name') ?? 'User';
          final email = prefs?.getString('user_email') ?? '';

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () async {
                        await ProfileService.pickAndSaveAvatar();
                        (context as Element).markNeedsBuild();
                      },
                      child: FutureBuilder<File?>(
                        future: ProfileService.loadAvatarFile(),
                        builder: (ctx, snapshot) {
                          final file = snapshot.data;
                          return Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: file != null
                                      ? Image.file(file, fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          child: const Icon(Icons.person_rounded,
                                              color: Colors.white60, size: 32),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.edit_rounded,
                                      color: theme.colorScheme.primary, size: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _rolePill(role),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _tile(
                      context,
                      icon: Icons.business_center_outlined,
                      label: "Company Profile".tr,
                      onTap: () => Get.to(() => const CompanyProfileScreen()),
                      accentColor: theme.colorScheme.primary,
                    ),
                    _tile(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      label: "Accounts".tr,
                      onTap: () => Get.to(() => AccountsPage()),
                      accentColor: Colors.orange,
                    ),
                    if (RolePermissions.canSeePurchases(role, prefs: prefs))
                      _tile(
                        context,
                        icon: Icons.add_shopping_cart_rounded,
                        label: "Stock In (Purchase)".tr,
                        onTap: () => Get.to(() => const StockInPage()),
                        accentColor: theme.colorScheme.primary,
                      ),
                    if (RolePermissions.canSeeMakeSale(role, prefs: prefs))
                      _tile(
                        context,
                        icon: Icons.point_of_sale_rounded,
                        label: "Make Sale".tr,
                        onTap: () => Get.to(() => const CashierScreensPage()),
                        accentColor: Colors.green,
                      ),
                    
                    _sectionHeader(context, label: "MASTERS"),
                    if (RolePermissions.canSeeSuppliers(role, prefs: prefs))
                      _tile(
                        context,
                        icon: Icons.local_shipping_outlined,
                        label: "Vendor Master".tr,
                        onTap: () => Get.to(() => const VendorScreen()),
                      ),
                    if (RolePermissions.canSeeInventory(role, prefs: prefs))
                      _tile(
                        context,
                        icon: Icons.settings_suggest_outlined,
                        label: "Masters Setup".tr,
                        onTap: () => Get.to(() => const MastersScreen()),
                      ),
                    
                    _sectionHeader(context, label: "REPORTS"),
                    _tile(
                      context,
                      icon: Icons.inventory_2_outlined,
                      label: "Stock Report".tr,
                      onTap: () => Get.to(() => const InventoryPage()),
                    ),
                    _tile(
                      context,
                      icon: Icons.receipt_long_outlined,
                      label: "Sales Reports".tr,
                      onTap: () => Get.to(() => const SelesReportsPage()),
                    ),
                    _tile(
                      context,
                      icon: Icons.history_rounded,
                      label: "Purchase Reports".tr,
                      onTap: () => Get.to(() => const PurchaseReportsPage()),
                    ),

                    if (RolePermissions.canManageUsers(role)) ...[
                      _sectionHeader(context, label: "ADMIN"),
                      _tile(
                        context,
                        icon: Icons.admin_panel_settings_outlined,
                        label: "User Management".tr,
                        onTap: () => Get.to(() => const UserManagementPage()),
                        accentColor: theme.colorScheme.primary,
                      ),
                      _tile(
                        context,
                        icon: Icons.security_outlined,
                        label: "RBAC Permissions".tr,
                        onTap: () => Get.to(() => const RbacManagementPage()),
                        accentColor: Colors.purple,
                      ),
                    ],

                    _sectionHeader(context, label: "ACCOUNT"),
                    GetX<DemoController>(
                      builder: (demo) => SwitchListTile(
                        secondary: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.science_outlined, color: Colors.amber, size: 18),
                        ),
                        title: Text("Demo Mode (Dummy Data)".tr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text("Populates app with demo records".tr, style: const TextStyle(fontSize: 11)),
                        value: demo.isDemoMode.value,
                        onChanged: (v) => _confirmDemoToggle(context, demo, v),
                      ),
                    ),
                    _tile(
                      context,
                      icon: Icons.lock_outline_rounded,
                      label: "Reset Password".tr,
                      onTap: () => Get.to(() => const ResetPassword()),
                    ),
                    _tile(
                      context,
                      icon: Icons.language_rounded,
                      label: "Change Language".tr,
                      onTap: () => _showLanguagePicker(context),
                    ),
                    _tile(
                      context,
                      icon: Icons.logout_rounded,
                      label: "Logout".tr,
                      iconColor: const Color(0xFFFF6B6B),
                      labelColor: const Color(0xFFFF6B6B),
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDemoToggle(BuildContext context, DemoController demo, bool value) {
    final theme = Theme.of(context);
    Get.defaultDialog(
      backgroundColor: theme.cardColor,
      titleStyle: GoogleFonts.inter(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.w700),
      title: value ? "Enable Demo Mode?".tr : "Disable Demo Mode?".tr,
      content: Column(
        children: [
          Icon(value ? Icons.science_rounded : Icons.cleaning_services_rounded, 
               color: Colors.amber, size: 40),
          const SizedBox(height: 12),
          Text(
            value 
              ? "This will CLEAR your current data and insert dummy records for demonstration.".tr
              : "This will CLEAR ALL dummy data. App will be empty.".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
          ),
        ],
      ),
      textCancel: "Cancel".tr,
      textConfirm: "Proceed".tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await demo.toggleDemoMode(value);
        Get.snackbar("Database Reset", value ? "App populated with Demo Data" : "App data cleared",
            backgroundColor: Colors.amber, colorText: Colors.black);
      },
    );
  }

  Widget _rolePill(String role) {
    Color color;
    IconData icon;
    String label;
    switch (role) {
      case AppRoles.manager:
        color = const Color(0xFF4FC3F7);
        icon = Icons.admin_panel_settings_rounded;
        label = "Manager";
        break;
      case AppRoles.cashier:
        color = const Color(0xFFCE93D8);
        icon = Icons.point_of_sale_rounded;
        label = "Cashier";
        break;
      default:
        color = const Color(0xFF81C784);
        icon = Icons.badge_rounded;
        label = "Employee";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? accentColor,
    Color? iconColor,
    Color? labelColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ic = iconColor ?? accentColor ?? (isDark ? Colors.white60 : Colors.black54);
    final lc = labelColor ?? (isDark ? Colors.white70 : Colors.black87);
    
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ic.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ic, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: lc,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: isDark ? Colors.white24 : Colors.black26, size: 18),
      onTap: onTap,
    );
  }

  Widget _sectionHeader(BuildContext context, {required String label}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black26,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final theme = Theme.of(context);
    Get.defaultDialog(
      backgroundColor: theme.cardColor,
      titleStyle: GoogleFonts.inter(
          color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.w700),
      title: "Logout".tr,
      content: Column(
        children: [
          const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B), size: 40),
          const SizedBox(height: 12),
          Text(
            "Are you sure you want to logout?".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
          ),
        ],
      ),
      textCancel: "Cancel".tr,
      textConfirm: "Logout".tr,
      cancelTextColor: theme.textTheme.bodyMedium?.color,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE53935),
      onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('token');
        Get.offAll(() => const Login());
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Language".tr, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
            const SizedBox(height: 16),
            ListTile(
              title: Text("English", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Get.updateLocale(const Locale('en', 'US')); Get.back(); },
            ),
            ListTile(
              title: Text("हिंदी (Hindi)", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Get.updateLocale(const Locale('hi', 'IN')); Get.back(); },
            ),
            ListTile(
              title: Text("ગુજરાતી (Gujarati)", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Get.updateLocale(const Locale('gu', 'IN')); Get.back(); },
            ),
          ],
        ),
      ),
    );
  }
}
