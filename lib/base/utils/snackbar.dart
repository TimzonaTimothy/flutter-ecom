import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccessSnackbar(String text) {
  Get.snackbar(
    "Success", // Title
    text, // Message
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.greenAccent,
    colorText: Colors.black,
    duration: Duration(seconds: 2),
  );
}

void showFailureSnackbar(String text) {
  Get.snackbar(
    "Success", // Title
    text, // Message
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
  );
}
