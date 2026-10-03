// ignore_for_file: avoid_print
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_management_modern/controller/theme_controller.dart';
import 'package:store_management_modern/localization/Local_controller.dart';
import 'package:store_management_modern/screens/login/login.dart';
import 'package:store_management_modern/screens/make_a_sale/cashierScreens.dart';
import 'package:store_management_modern/shared/roles.dart';
import 'package:store_management_modern/screens/Home/home.dart';
import 'package:store_management_modern/shared/my_binding/my_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/localization.dart';

late SharedPreferences shaedpref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  shaedpref = prefs;
  print(prefs.getString('token'));
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    Get.put(MyLocaleController());
    final themeCtrl = Get.put(ThemeController());

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
      theme: ThemeController.lightTheme,
      darkTheme: ThemeController.darkTheme,
      themeMode: themeCtrl.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      locale: shaedpref.getString("curruntLang") == null
          ? Get.deviceLocale
          : Locale(shaedpref.getString("curruntLang")!),
      translations: MyLocale(),
      home: _resolveStartPage(prefs),
    ));
  }

  Widget _resolveStartPage(SharedPreferences prefs) {
    final token = prefs.getString('token');
    if (token == null) return const Login();

    final role = prefs.getString('user_role') ?? AppRoles.employee;
    if (role == AppRoles.manager) return const Home();
    return const CashierScreensPage();
  }
}
