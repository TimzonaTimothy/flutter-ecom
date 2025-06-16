import 'dart:developer';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import '../../auth/views/sign_in.dart';
import '../../main.dart';

Future saveToken(String token) async {
  log('Saving token: $token');
  prefs.setString('token', token);
}

String? getToken() {
  return prefs.getString('token');
}

Future removeToken() async {
  prefs.remove('token');
  showSuccessSnackbar("Logout successful");
  Get.to(() => SignInScreen());
}
