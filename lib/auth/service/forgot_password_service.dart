import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../base/res/base_url.dart';

class PasswordResetService {
  static const String _baseUrl = baseUrl;

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final url = Uri.parse("$_baseUrl/auth/password-reset/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return {
      "status": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }

  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("$_baseUrl/auth/password-reset-confirm/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
        "confirm_password": confirmPassword
      }),
    );

    return {
      "status": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }
}
