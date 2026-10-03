// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/performance_model.dart';
import '../shared/api_status.dart';
import '../shared/app_feedback.dart';
import '../shared/constants.dart';
import '../shared/remote_config.dart';
import 'package:http/http.dart' as http;
import '../shared/dummy_data.dart';
import '../local_db/app_database.dart';

class PerformanceController extends GetxController {
  // *********** Variables **********

  DateTime? dateTimeFrom = DateTime.now();
  DateTime? dateTimeTo = DateTime.now();

  List<PerformanceModel> listOfPerfomanceModel = [];

  Map<String, dynamic>? dashboardData;
  RxBool isThereData = false.obs;

  // *********** Methods **********

  @override
  onInit() {
    super.onInit();
    getSalesReportsData();
  }

  //================ Set Date =================
  setDateFrom(DateTime date) {
    dateTimeFrom = date;
    update();
  }

  setDateTo(DateTime date) {
    dateTimeTo = date;
    update();
  }

  //============== Here To Get Sales Reports ===============
  getSalesReportsData() async {
    if (!RemoteConfig.enabled) {
      // Offline build: no remote reports. Inject dummy data
      listOfPerfomanceModel = DummyData.getSales();
      update();
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(RemoteConfig.host!, apiSalesReport),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      print("Out sideeeeeeee");
      print(json.decode(response.body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        var body = json.decode(response.body);
        print("insideeeeeeeeeee");
        print(body);
        for (var i = 0; i < body['data'].length; i++) {
          listOfPerfomanceModel.add(PerformanceModel.formJson(body['data'][i]));
        }
        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }

  // * Get Date By Date From And To
  getDataByDate({required DateTime to, required DateTime from}) async {
    if (!RemoteConfig.enabled) {
      listOfPerfomanceModel = DummyData.getSales();
      update();
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(RemoteConfig.host!, apiSalesReport, {
          'to': to.toString(),
          'from': from.toString(),
        }),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      print("Out sideeeeeeee");
      print(json.decode(response.body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        listOfPerfomanceModel.clear();
        var body = json.decode(response.body);
        print("sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf");
        print(body);
        for (var i = 0; i < body['data'].length; i++) {
          listOfPerfomanceModel.add(PerformanceModel.formJson(body['data'][i]));
        }
        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }

  // ************* Get Performance Data ******************

  getDashBoardData({required DateTime to, required DateTime from}) async {
    if (!RemoteConfig.enabled) {
      await _loadLiveDashboardData(to: to, from: from);
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(RemoteConfig.host!, apiReports, {
          'to': to.toString(),
          'from': from.toString(),
        }),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var body = json.decode(response.body);
        print("Dashboardddddddddddddddddddddddddd");
        print(body);
        dashboardData = body;
        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }

  Future<void> _loadLiveDashboardData({required DateTime to, required DateTime from}) async {
    final db = await AppDatabase.instance;
    final toStr = to.toIso8601String().split('T')[0];
    final fromStr = from.toIso8601String().split('T')[0];

    // 1. Store Movements (Daily Sales count)
    final movements = await db.rawQuery('''
      SELECT substr(sale_date, 1, 10) as date, COUNT(*) as count 
      FROM sales 
      WHERE substr(sale_date, 1, 10) BETWEEN ? AND ? 
      GROUP BY date 
      ORDER BY date ASC
    ''', [fromStr, toStr]);

    // 2. Best Selling
    final bestSellers = await db.rawQuery('''
      SELECT i.name, SUM(si.qty) as total_qty
      FROM sale_items si
      INNER JOIN items i ON si.item_id = i.id
      INNER JOIN sales s ON si.sale_id = s.id
      WHERE substr(s.sale_date, 1, 10) BETWEEN ? AND ?
      GROUP BY si.item_id
      ORDER BY total_qty DESC
      LIMIT 5
    ''', [fromStr, toStr]);

    // 3. Least Selling (Improved with outer join)
    final leastSellers = await db.rawQuery('''
      SELECT i.name, COALESCE(SUM(si.qty), 0) as total_qty
      FROM items i
      LEFT JOIN sale_items si ON i.id = si.item_id
      LEFT JOIN sales s ON si.sale_id = s.id AND substr(s.sale_date, 1, 10) BETWEEN ? AND ?
      GROUP BY i.id
      ORDER BY total_qty ASC
      LIMIT 5
    ''', [fromStr, toStr]);

    // 4. Low Stock (Optimized with a single join on stock_movements)
    final lowStock = await db.rawQuery('''
      SELECT i.name, COALESCE(SUM(sm.qty_change), 0) as current_stock
      FROM items i
      LEFT JOIN stock_movements sm ON i.id = sm.item_id
      GROUP BY i.id
      ORDER BY current_stock ASC
      LIMIT 5
    ''');

    // 5. Total Sales Revenue
    final revenueRes = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM sales 
      WHERE substr(sale_date, 1, 10) BETWEEN ? AND ?
    ''', [fromStr, toStr]);
    final totalRevenue = (revenueRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // Construct dashboard data map similar to API response
    dashboardData = {
      'total_sales_revenue': totalRevenue,
      'best_selling': bestSellers.map((e) => {'name': e['name'], 'qty': e['total_qty']}).toList(),
      'least_selling': leastSellers.map((e) => {'name': e['name'], 'qty': e['total_qty']}).toList(),
      'low_stock': lowStock.map((e) => {'name': e['name'], 'stock': e['current_stock']}).toList(),
      'movements': movements.map((e) => {'date': e['date'], 'count': e['count']}).toList(),
    };

    update();
  }

  void removeFromList(int index) {
    listOfPerfomanceModel.removeAt(index);
    update();
  }

  //* ========================== DELETE Data =================
  deleteSalesData(int id) async {
    isThereData.value = false;
    if (!RemoteConfig.enabled) {
      AppFeedback.warning("This action isn’t available in offline mode.");
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.delete(
        Uri.http(RemoteConfig.host!, "$apiSales/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }
}
