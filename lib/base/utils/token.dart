import 'dart:developer';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import '../../auth/views/sign_in.dart';
import '../../main.dart';

Future saveTokens(String accessToken, String refreshToken) async {
  log('Saving access token: $accessToken');
  log('Saving refresh token: $refreshToken');
  await prefs.setString('token', accessToken);
  await prefs.setString('refreshToken', refreshToken);
}

String? getRefreshToken() {
  return prefs.getString('refreshToken');
}

String? getToken() {
  return prefs.getString('token');
}

Future removeToken() async {
  await prefs.remove('token');
  await prefs.remove('refreshToken');
  showSuccessSnackbar("Logout successful");
  Get.to(() => SignInScreen());
}
