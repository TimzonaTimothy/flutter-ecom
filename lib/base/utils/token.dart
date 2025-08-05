import 'dart:convert';
import 'dart:developer';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../auth/views/sign_in.dart';
import '../../main.dart';
import '../res/base_url.dart';

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

// Future saveTokens(String accessToken, String refreshToken) async {
//   log('Saving access token: [HIDDEN]');
//   log('Saving refresh token: $refreshToken');
//   await prefs.setString('token', accessToken);
//   await prefs.setString('refreshToken', refreshToken);
// }

// String? getRefreshToken() {
//   return prefs.getString('refreshToken');
// }

// String? getToken() {
//   return prefs.getString('token');
// }

// Future removeToken() async {
//   await prefs.remove('token');
//   await prefs.remove('refreshToken');
//   // showSuccessSnackbar("Logout successful");
//   Get.offAll(() => const SignInScreen());
// }

// Future<void> verifyToken() async {
//   final token = getToken();
//   if (token == null) {
//     showFailureSnackbar("No token found. Please sign in again.");
//     Get.offAll(() => const SignInScreen());
//     return;
//   }

//   final url = Uri.parse(
//       '$baseURLGeneral/auth/jwt/verify/'); 

//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'token': token}),
//   );

//   if (response.statusCode == 200) {
//     // Token is valid
//     log('Token verified successfully');
//   } else {
//     // Token is invalid or expired
//     await removeToken(); // Clears tokens and redirects
//     showFailureSnackbar("Session expired. Please log in again.");
//   }
// }


// Future<bool> refreshAccessToken() async {
//   final refreshToken = getRefreshToken();
//   if (refreshToken == null) {
//     log('No refresh token found');
//     return false;
//   }

//   final url = Uri.parse('$baseURLGeneral/auth/refresh/'); 
//   try {
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'refresh': refreshToken}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final newAccessToken = data['access'];
//       await saveTokens(newAccessToken, refreshToken); 
//       log('Token refreshed successfully');
//       return true;
//     } else {
//       log('Token refresh failed: ${response.body}');
//       await removeToken(); // Clear tokens and redirect to login
//       showFailureSnackbar('Session expired. Please log in again.');
//       return false;
//     }
//   } catch (e) {
//     log('Error refreshing token: $e');
//     await removeToken();
//     showFailureSnackbar('Session expired. Please log in again.');
//     return false;
//   }
// }



// Future<void> verifyToken() async {
//   final token = getToken();
//   if (token == null) {
//     showFailureSnackbar("No token found. Please sign in again.");
//     Get.offAll(() => const SignInScreen());
//     return;
//   }

//   final url = Uri.parse(
//       '$baseURLGeneral/auth/verify/'); 

//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'token': token}),
//   );

//   if (response.statusCode == 200) {
//     // Token is valid
//     log('Token verified successfully');
//   } else {
//     // Token is invalid or expired
//     await removeToken(); // Clears tokens and redirects
//     showFailureSnackbar("Session expired. Please log in again.");
//   }
// }



// Future<bool> verifyTokenOnly() async {
//   final token = getToken();
//   if (token == null) return false;

//   final url = Uri.parse('https://yourapi.com/auth/jwt/verify/');

//   try {
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'token': token}),
//     );

//     return response.statusCode == 200;
//   } catch (e) {
//     log("Token verification error: $e");
//     return false;
//   }
// }

// Map<String, String> authHeader() {
//   final authToken = getToken();

//   Map<String, String> res = {
//     'Authorization': 'Bearer $authToken',
//   };
//   return res;
// }