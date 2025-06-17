import 'dart:convert';
import 'dart:developer';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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
  Get.to(() => const SignInScreen());
}

Future<void> verifyToken() async {
  final token = getToken();
  if (token == null) {
    showFailureSnackbar("No token found. Please sign in again.");
    Get.offAll(() => const SignInScreen());
    return;
  }

  final url = Uri.parse(
      'https://yourapi.com/auth/jwt/verify/'); // Replace with your real endpoint

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'token': token}),
  );

  if (response.statusCode == 200) {
    // Token is valid
    log('Token verified successfully');
  } else {
    // Token is invalid or expired
    await removeToken(); // Clears tokens and redirects
    showFailureSnackbar("Session expired. Please log in again.");
  }
}
