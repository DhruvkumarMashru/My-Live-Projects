// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_management_modern/model/supplier_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/api_status.dart';
import '../shared/app_feedback.dart';
import '../shared/constants.dart';
import '../shared/remote_config.dart';
import '../shared/dummy_data.dart';

class SupplierController extends GetxController {
  // ************ Variables ***************

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RxBool isThereData = false.obs;
  List<Map<String, dynamic>> supplierList = [];
  List<SupplierModel> listOfSupplierModel = [];

  GlobalKey<FormState> supplierKey = GlobalKey<FormState>();

  DateTime dateTimeFrom = DateTime.now();
  DateTime dateTimeTo = DateTime.now();

  // ************ Methods ****************

  //================ Set Date =================

  setDateFrom(DateTime date) {
    dateTimeFrom = date;
    update();
  }

  setDateTo(DateTime date) {
    dateTimeTo = date;
    update();
  }

  // ************** Here for added new supplier *******************
  addNewSupplier(
      {required String name,
      required String phone,
      required GlobalKey<FormState> key}) async {
    print("WEeeeeeeeeeeeeeeeee are printing phone");
    print(phone.toString());
    if (!RemoteConfig.enabled) {
      AppFeedback.warning("Suppliers sync is disabled in offline mode.");
      return;
    }
    if (key.currentState!.validate()) {
      key.currentState!.save();
      showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (BuildContext context) => Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    CircularProgressIndicator(
                      color: kprimaryColor,
                      backgroundColor: kprimaryColor,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Adding...',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        http.Response response =
            await http.post(Uri.http(RemoteConfig.host!, apiSuppliers), headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}'
        }, body: {
          'name': name,
          'phone': phone,
        });
        print("Codeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
        // print(json.decode(response.body));
        if (response.statusCode == 201 || response.statusCode == 200) {
          print("Indesssssssssssssssssssssssssss");
          nameController.clear();
          phoneController.clear();
          Get.back();
          return Get.snackbar('Supplier', 'The supplier has added successfully',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2));
        }
        Get.back();
        ApiStatus.checkStatus(response);
      } catch (e) {
        Get.back();
        AppFeedback.error("Network error. Please try again.");
        return;
      }
    }
  }

  // ************** Here to get supplier data *******************

  getSuppliersData() async {
    if (!RemoteConfig.enabled) {
      supplierList = DummyData.getSuppliers();
      update();
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(
          RemoteConfig.host!,
          apiSuppliers,
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}'
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var body = json.decode(response.body);
        supplierList.clear();
        for (var i = 0; i < body['data'].length; i++) {
          supplierList.add(body['data'][i]);
        }

        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }

////////////////////////////
  removeFromList(int index) {
    supplierList.removeAt(index);
    update();
  }

  ////////////////////////////////
  //================ Delete supplier ////////////////
  deleteSupplier(int id) async {
    isThereData.value = false;
    if (!RemoteConfig.enabled) {
      AppFeedback.warning("Suppliers sync is disabled in offline mode.");
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.delete(
        Uri.http(
          RemoteConfig.host!,
          "$apiSuppliers/$id",
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}'
        },
      );
      // print(json.decode(response.body));
      if (response.statusCode == 201 || response.statusCode == 200) {
        update();
      }

      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }

  //* ================ HERE To Get Supplier Invoices ===================
  getSupplierInvoices(
      {required id, required DateTime to, required DateTime from}) async {
    if (!RemoteConfig.enabled) {
      listOfSupplierModel.clear();
      update();
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(
        Uri.http(
          RemoteConfig.host!,
          "$apiSuppliers/$id",
          {'to': to.toString(), 'from': from.toString()},
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}'
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var body = json.decode(response.body);
        print(body);

        for (var i = 0; i < body['data']['invoices'].length; i++) {
          listOfSupplierModel
              .add(SupplierModel.fromJson(body['data']['invoices'][i]));
        }
        update();
      }
      ApiStatus.checkStatus(response);
    } catch (e) {
      AppFeedback.error("Network error. Please try again.");
      return;
    }
  }
}
