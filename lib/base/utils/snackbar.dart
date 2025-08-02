import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccessSnackbar(String text, {String? title}) {
  Get.snackbar(
    title ?? 'Success', 
    text,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.greenAccent,
    colorText: Colors.black,
    duration: Duration(seconds: 2),
    overlayBlur: 5,
  );
}


void showFailureSnackbar(String text, {String? title}) {
  Get.snackbar(
    title ?? 'Error', 
    text, 
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
    overlayBlur: 5, 
  );
}

