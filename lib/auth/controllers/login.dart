import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../../base/utils/token.dart';
import '../views/sign_up_otp_code.dart';

class LoginController extends GetxController {
  var isLoad = false.obs;

  Future<void> loginUser(String email, String password) async {
    isLoad.value = true;
    update();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login/"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar("Login successful");
        log(response.body);
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);

        // ✅ Save user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("user_id", data['user']['id']);
        Get.offAll(
          () => const BottomNavBar(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        isLoad.value = false;
        update();
        return;
      } else {
        // showFailureSnackbar(
        //   jsonDecode(response.body)['detail'] ?? 'Login failed',
        // );
        final data = jsonDecode(response.body);
        final errorMessage = data['error']?['details']?['detail'] ??
            data['detail'] ??
            'Login failed';

        showFailureSnackbar(errorMessage);
        if (errorMessage.toLowerCase().contains('account not activated') ||
            errorMessage.toLowerCase().contains('not activated')) {
          // Save email for OTP verification
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("otp_email", email);

          await Future.delayed(const Duration(milliseconds: 800));
          // Redirect to OTP screen
          Get.to(
            () => const SignUpOtpCode(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 500),
          );
        }
      }

      log('Data ${response.body}');
    } catch (e) {
      log('Login failed: $e');
    } finally {
      isLoad.value = false;
      update();
    }
  }
}
