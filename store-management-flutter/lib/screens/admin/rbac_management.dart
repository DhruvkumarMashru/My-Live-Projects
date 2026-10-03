import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_management_modern/shared/roles.dart';

class RbacManagementPage extends StatefulWidget {
  const RbacManagementPage({super.key});

  @override
  State<RbacManagementPage> createState() => _RbacManagementPageState();
}

class _RbacManagementPageState extends State<RbacManagementPage> {
  bool _loading = true;
  bool _saving = false;

  // Map: role -> feature -> allowed
  final Map<String, Map<String, bool>> _permissions = {
    AppRoles.employee: {},
    AppRoles.cashier: {},
  };

  final _featureLabels = const {
    'purchases': 'Purchases',
    'suppliers': 'Suppliers',
    'inventory': 'Inventory',
    'accounts': 'Accounts',
    'performance': 'Performance',
    'generate_offers': 'Generate Offers',
    'make_sale': 'Make Sale',
  };

  final _featureIcons = const {
    'purchases': Icons.shopping_cart_outlined,
    'suppliers': Icons.local_shipping_outlined,
    'inventory': Icons.inventory_2_outlined,
    'accounts': Icons.account_balance_wallet_outlined,
    'performance': Icons.bar_chart_outlined,
    'generate_offers': Icons.local_offer_outlined,
    'make_sale': Icons.point_of_sale_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final role in [AppRoles.employee, AppRoles.cashier]) {
      final map = <String, bool>{};
      for (final feature in RbacKeys.features) {
        final stored = prefs.getString(RbacKeys.key(role, feature));
        map[feature] = stored == null
            ? RbacKeys.defaultPermission(role, feature)
            : stored == '1';
      }
      _permissions[role] = map;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    for (final role in [AppRoles.employee, AppRoles.cashier]) {
      for (final feature in RbacKeys.features) {
        final allowed = _permissions[role]![feature] ?? false;
        await prefs.setString(RbacKeys.key(role, feature), allowed ? '1' : '0');
      }
    }
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          'RBAC Permissions',
          style: GoogleFonts.ebGaramond(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 39, 62, 82),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 39, 62, 82),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Control which features each role can access.\nManager always has full access.',
                    style: GoogleFonts.ebGaramond(
                      textStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildRoleCard(
                        role: AppRoles.manager,
                        label: 'Manager',
                        color: const Color(0xFF1B5E20),
                        icon: Icons.admin_panel_settings,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleCard(
                        role: AppRoles.employee,
                        label: 'Employee',
                        color: const Color(0xFF1565C0),
                        icon: Icons.badge_outlined,
                        readOnly: false,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleCard(
                        role: AppRoles.cashier,
                        label: 'Cashier',
                        color: const Color(0xFF6A1B9A),
                        icon: Icons.point_of_sale,
                        readOnly: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 62, 82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _saving ? 'Saving…' : 'Save Permissions',
                        style: GoogleFonts.ebGaramond(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String label,
    required Color color,
    required IconData icon,
    required bool readOnly,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Role header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.ebGaramond(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (readOnly) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Full Access',
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Feature toggles
          ...RbacKeys.features.map((feature) {
            final label = _featureLabels[feature] ?? feature;
            final iconData = _featureIcons[feature] ?? Icons.circle_outlined;
            final isAllowed = readOnly
                ? true
                : (_permissions[role]?[feature] ?? false);
            return SwitchListTile(
              secondary: Icon(iconData,
                  color: isAllowed ? color : Colors.grey.shade400),
              title: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isAllowed ? FontWeight.w600 : FontWeight.normal,
                  color: isAllowed ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
              value: isAllowed,
              activeColor: color,
              onChanged: readOnly
                  ? null
                  : (val) {
                      setState(() {
                        _permissions[role]![feature] = val;
                      });
                    },
            );
          }),
        ],
      ),
    );
  }
}
