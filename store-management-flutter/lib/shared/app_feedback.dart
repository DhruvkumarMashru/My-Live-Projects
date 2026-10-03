import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeedback {
  static void error(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      (title ?? "Error").tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      margin: const EdgeInsets.all(12),
    );
  }

  static void warning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      (title ?? "Warning").tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      margin: const EdgeInsets.all(12),
    );
  }

  static void success(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      (title ?? "Success").tr,
      message.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }
}

