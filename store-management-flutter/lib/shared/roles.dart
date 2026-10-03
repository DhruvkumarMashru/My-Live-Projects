import 'package:shared_preferences/shared_preferences.dart';

class AppRoles {
  static const String manager = 'manager';
  static const String employee = 'employee';
  static const String cashier = 'cashier';
}

/// Keys for per-role RBAC toggles stored in SharedPreferences.
/// Format: rbac_<role>_<feature>  → '1' (allowed) | '0' (denied)
class RbacKeys {
  static const _features = [
    'purchases',
    'suppliers',
    'inventory',
    'accounts',
    'performance',
    'generate_offers',
    'make_sale',
  ];

  static List<String> get features => _features;

  static String key(String role, String feature) => 'rbac_${role}_$feature';

  /// Default permissions for each role (used when no stored value exists).
  static bool defaultPermission(String role, String feature) {
    if (role == AppRoles.manager) return true;
    if (role == AppRoles.employee) {
      return feature == 'make_sale'; // employee only sees Make Sale by default
    }
    if (role == AppRoles.cashier) {
      return feature == 'make_sale'; // cashier only sees Make Sale by default
    }
    return false;
  }
}

class RolePermissions {
  // ---- Async versions (read live RBAC toggles from SharedPreferences) ----

  static Future<bool> _check(String role, String feature) async {
    if (role == AppRoles.manager) return true; // manager always has all rights
    final prefs = await SharedPreferences.getInstance();
    final storedKey = RbacKeys.key(role, feature);
    final stored = prefs.getString(storedKey);
    if (stored == null) {
      return RbacKeys.defaultPermission(role, feature);
    }
    return stored == '1';
  }

  static Future<bool> canSeePurchasesAsync(String role) =>
      _check(role, 'purchases');
  static Future<bool> canSeeSuppliersAsync(String role) =>
      _check(role, 'suppliers');
  static Future<bool> canSeeInventoryAsync(String role) =>
      _check(role, 'inventory');
  static Future<bool> canSeeAccountsAsync(String role) =>
      _check(role, 'accounts');
  static Future<bool> canSeePerformanceAsync(String role) =>
      _check(role, 'performance');
  static Future<bool> canSeeGenerateOffersAsync(String role) =>
      _check(role, 'generate_offers');
  static Future<bool> canSeeMakeSaleAsync(String role) =>
      _check(role, 'make_sale');
  static Future<bool> canManageUsersAsync(String role) async =>
      role == AppRoles.manager;

  // ---- Synchronous helpers (kept for backward compat, use prefs snapshot) ----
  // These are called with a pre-loaded SharedPreferences snapshot.

  static bool canSeePurchases(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'purchases', prefs);
  static bool canSeeSuppliers(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'suppliers', prefs);
  static bool canSeeInventory(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'inventory', prefs);
  static bool canSeeAccounts(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'accounts', prefs);
  static bool canSeePerformance(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'performance', prefs);
  static bool canSeeGenerateOffers(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'generate_offers', prefs);
  static bool canSeeMakeSale(String role, {SharedPreferences? prefs}) =>
      _syncCheck(role, 'make_sale', prefs);
  static bool canManageUsers(String role) => role == AppRoles.manager;

  static bool _syncCheck(
      String role, String feature, SharedPreferences? prefs) {
    if (role == AppRoles.manager) return true;
    if (prefs == null) return RbacKeys.defaultPermission(role, feature);
    final stored = prefs.getString(RbacKeys.key(role, feature));
    if (stored == null) return RbacKeys.defaultPermission(role, feature);
    return stored == '1';
  }
}
