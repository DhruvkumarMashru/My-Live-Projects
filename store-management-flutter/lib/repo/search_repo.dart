import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../shared/api_status.dart';
import '../shared/app_feedback.dart';
import '../shared/remote_config.dart';

class SearchRepo {
  static List<Map<String, dynamic>> listOfData = [];

  static Future<List<Map<String, dynamic>>> getData({
    required String apiPath,
    required String nameAtapi,
    required String? itemName,
  }) async {
    listOfData.clear();
    if (!RemoteConfig.enabled) return listOfData;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(RemoteConfig.host!, apiPath, {nameAtapi: itemName}),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var body = json.decode(response.body);
        for (var i = 0; i < body['data'].length; i++) {
          listOfData.add(body['data'][i]);
        }
        return listOfData;
      }
      ApiStatus.checkStatus(response);
      return listOfData;
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return listOfData;
    }
  }
}
