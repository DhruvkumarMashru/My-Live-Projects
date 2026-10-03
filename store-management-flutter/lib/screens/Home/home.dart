import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_management_modern/localization/Local_controller.dart';
import 'package:store_management_modern/screens/Inventory Screens/inventory_report_screen.dart';
import 'package:store_management_modern/screens/purchases/stock_in_page.dart';
import 'package:store_management_modern/screens/Performance Screens/performance.dart';
import 'package:store_management_modern/screens/vendor/vendor_screen.dart';
import '../../controller/performance_controller.dart';
import '../../controller/theme_controller.dart';
import '../../main.dart';
import '../Account/accounts.dart';
import '../GenerateOffers/Generate Offers.dart';
import '../make_a_sale/cashierScreens.dart';
import 'package:store_management_modern/screens/company_profile/company_profile_screen.dart';
import 'package:store_management_modern/screens/masters/masters_screen.dart';
import 'Home Widget/drawer.dart';
import 'Home Widget/homeWidget.dart';
import '../../shared/profile_service.dart';
import '../../shared/roles.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    MyLocaleController controllerlan = Get.find();
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text("HOME".tr),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white),
              onPressed: () => themeCtrl.toggleTheme(),
            ),
            FutureBuilder<String?>(
              future: ProfileService.getProfileImage(),
              builder: (context, snap) {
                final url = snap.data;
                return GestureDetector(
                  onTap: () => Get.to(() => const CompanyProfileScreen()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      backgroundImage: (url != null && url.isNotEmpty && url.startsWith('http')) ? NetworkImage(url) : null,
                      child: (url == null || url.isEmpty || !url.startsWith('http')) ? const Icon(Icons.business_center_rounded, size: 16, color: Colors.white) : null,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.translate_rounded, color: Colors.white),
              onPressed: () => _showLanguagePicker(context, controllerlan),
            ),
          ],
        ),
        drawer: DrawerWidget(),
        body: FutureBuilder<Map<String, dynamic>>(
          future: SharedPreferences.getInstance().then(
            (p) => {
              'role': p.getString('user_role') ?? AppRoles.employee,
              'prefs': p,
              'name': p.getString('user_name') ?? '',
            },
          ),
          builder: (context, snap) {
            final role =
                (snap.data?['role'] as String?) ?? AppRoles.employee;
            final prefs = snap.data?['prefs'] as SharedPreferences?;
            final name = (snap.data?['name'] as String?) ?? '';

            return Column(
              children: [
                // Greeting banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [const Color(0xFF0F1C2E), const Color(0xFF243B55)]
                          : [const Color(0xFF0288D1), const Color(0xFF0277BD)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good ${_greeting()}! 👋",
                            style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name.isNotEmpty ? name : "Store Manager",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _roleBadge(role),
                    ],
                  ),
                ),

                // Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (ctx, snapPrefs) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildRow(
                                context: context,
                                items: [
                                  if (RolePermissions.canSeePurchases(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Stock In (Purchase)".tr,
                                      image: "images/1.png",
                                      onTap: () =>
                                          Get.to(() => const StockInPage()),
                                    ),
                                  if (RolePermissions.canSeeMakeSale(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Make Sale".tr,
                                      image: "images/2.png",
                                      onTap: () => Get.to(
                                          () => const CashierScreensPage()),
                                    ),

                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildRow(
                                context: context,
                                items: [
                                  if (RolePermissions.canSeeSuppliers(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Vendor".tr,
                                      image: "images/3.png",
                                      onTap: () => Get.to(
                                          () => const VendorScreen()),
                                    ),
                                  if (RolePermissions.canSeeInventory(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Masters Setup".tr,
                                      image: "images/5.png",
                                      onTap: () => Get.to(
                                          () => MastersScreen()),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildRow(
                                context: context,
                                items: [
                                  if (RolePermissions.canSeeAccounts(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Inventory".tr,
                                      image: "images/4.png",
                                      onTap: () => Get.to(
                                          () => const InventoryPage()),
                                    ),
                                  if (RolePermissions.canSeePerformance(role,
                                      prefs: prefs))
                                    _MenuItem(
                                      name: "Performance".tr,
                                      image: "images/6.png",
                                      onTap: () => Get.to(
                                          () => const PerformancePage()),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (RolePermissions.canSeeGenerateOffers(role,
                                  prefs: prefs))
                                GetBuilder<PerformanceController>(
                                  builder: (ctrl) => GestureDetector(
                                    onTap: () {
                                      Get.to(() => GenerateOffersPage());
                                      ctrl.getSalesReportsData();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF8C00),
                                            Color(0xFFFF5722),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF5722)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.local_offer_outlined,
                                              color: Colors.white,
                                              size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Generate Offers".tr,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(
      {required BuildContext context, required List<_MenuItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: items.indexOf(item) > 0 ? 8 : 0,
              right: items.indexOf(item) < items.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: item.onTap,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.19,
                child: HomeWidget(name: item.name, imagepath: item.image),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _roleBadge(String role) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Morning";
    if (hour < 17) return "Afternoon";
    return "Evening";
  }

  void _showLanguagePicker(BuildContext context, MyLocaleController ctrl) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Change Language".tr, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () { ctrl.ChangeLang('en'); Get.back(); },
            ),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('हिंदी (Hindi)'),
              onTap: () { ctrl.ChangeLang('hi'); Get.back(); },
            ),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('ગુજરાતી (Gujarati)'),
              onTap: () { ctrl.ChangeLang('gu'); Get.back(); },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String name;
  final String image;
  final VoidCallback onTap;
  const _MenuItem({
    required this.name,
    required this.image,
    required this.onTap,
  });
}
