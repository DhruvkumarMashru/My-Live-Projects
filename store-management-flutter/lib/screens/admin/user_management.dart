import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/shared/app_feedback.dart';
import 'package:store_management_modern/shared/roles.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _controller = Get.find<LoginController>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _resetPassword = TextEditingController();
  bool _obscureCreate = true;
  bool _obscureReset = true;

  String _role = AppRoles.employee;
  bool _loading = true;
  List<Map<String, String>> _users = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _resetPassword.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final users = await _controller.listLocalUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Color _roleColor(String role) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    switch (role) {
      case AppRoles.manager:
        return isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0288D1);
      case AppRoles.cashier:
        return isDark ? const Color(0xFFCE93D8) : const Color(0xFF8E24AA);
      default:
        return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case AppRoles.manager:
        return Icons.admin_panel_settings_rounded;
      case AppRoles.cashier:
        return Icons.point_of_sale_rounded;
      default:
        return Icons.badge_rounded;
    }
  }

  Future<void> _openCreateUser() async {
    _name.clear();
    _email.clear();
    _password.clear();
    _role = AppRoles.employee;
    _obscureCreate = true;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await Get.bottomSheet(
      StatefulBuilder(builder: (ctx, setSheetState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Add New User".tr,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Fill in the details below".tr,
                    style: GoogleFonts.inter(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
                const SizedBox(height: 24),
                _themedField(
                  context,
                  controller: _name,
                  hint: "Name".tr,
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _themedField(
                  context,
                  controller: _email,
                  hint: "Email".tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _themedField(
                  context,
                  controller: _password,
                  hint: "Password (min 8 chars)".tr,
                  icon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  obscureText: _obscureCreate,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCreate ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: theme.iconTheme.color?.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    onPressed: () => setSheetState(() => _obscureCreate = !_obscureCreate),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Role".tr,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppRoles.employee,
                    AppRoles.cashier,
                    AppRoles.manager,
                  ].map((r) {
                    final selected = _role == r;
                    final color = _roleColor(r);
                    final label = r.tr;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => _role = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? color.withValues(alpha: 0.15) : theme.dividerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? color : theme.dividerColor.withValues(alpha: 0.2),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(_roleIcon(r), color: selected ? color : theme.hintColor, size: 18),
                                const SizedBox(height: 4),
                                Text(label,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? color : theme.hintColor,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textTheme.bodyMedium?.color,
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Get.back(),
                        child: Text("Cancel".tr, style: GoogleFonts.inter(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
                            AppFeedback.error("Please fill all fields".tr);
                            return;
                          }
                          await _controller.createLocalUser(
                            name: _name.text,
                            email: _email.text,
                            password: _password.text,
                            role: _role,
                          );
                          Get.back();
                          await _refresh();
                        },
                        child: Text("Create".tr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Extra padding for keyboard
                SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _openResetPassword(String email) async {
    _resetPassword.clear();
    _obscureReset = true;
    final theme = Theme.of(context);
    await Get.defaultDialog(
      backgroundColor: theme.cardColor,
      titleStyle: GoogleFonts.inter(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.w700),
      title: "Reset Password".tr,
      content: StatefulBuilder(builder: (ctx, setDialogState) {
        return Column(
          children: [
            Text(email,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13)),
            const SizedBox(height: 16),
            _themedField(
              context,
              controller: _resetPassword,
              hint: "New Password".tr,
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureReset,
              suffixIcon: IconButton(
                icon: Icon(_obscureReset ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5), size: 18),
                onPressed: () => setDialogState(() => _obscureReset = !_obscureReset),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text("Cancel".tr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _controller.resetLocalUserPassword(
                        email: email,
                        newPassword: _resetPassword.text,
                      );
                      Get.back();
                      AppFeedback.success("Password updated".tr);
                    },
                    child: Text("Save".tr),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDelete(String email) async {
    final theme = Theme.of(context);
    await Get.defaultDialog(
      backgroundColor: theme.cardColor,
      titleStyle: GoogleFonts.inter(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.w700),
      title: "Delete User".tr,
      middleTextStyle: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
      middleText: "Are You Sure?".tr,
      textCancel: "Cancel".tr,
      textConfirm: "Delete".tr,
      cancelTextColor: theme.textTheme.bodyMedium?.color,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE53935),
      onConfirm: () async {
        Get.back();
        await _controller.deleteLocalUser(email: email);
        await _refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("User Management".tr),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateUser,
        icon: const Icon(Icons.person_add_rounded),
        label: Text("Add New User".tr, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text("No users found".tr,
                          style: GoogleFonts.inter(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final u = _users[i];
                    final email = u['email'] ?? '';
                    final name = (u['name'] ?? '').trim();
                    final role = (u['role'] ?? 'employee').trim();
                    final color = _roleColor(role);
                    final icon = _roleIcon(role);
                    final roleLabel = role.tr;

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isEmpty ? email : name,
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: GoogleFonts.inter(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(roleLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _actionBtn(
                                  context,
                                  icon: Icons.lock_reset_rounded,
                                  color: isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0288D1),
                                  onTap: () => _openResetPassword(email),
                                  tooltip: "Reset Password".tr,
                                ),
                                const SizedBox(height: 8),
                                _actionBtn(
                                  context,
                                  icon: Icons.delete_outline_rounded,
                                  color: const Color(0xFFE53935),
                                  onTap: () => _confirmDelete(email),
                                  tooltip: "Delete".tr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

Widget _themedField(
  BuildContext context, {
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool obscureText = false,
  Widget? suffixIcon,
}) {
  final theme = Theme.of(context);
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      suffixIcon: suffixIcon,
    ),
  );
}
