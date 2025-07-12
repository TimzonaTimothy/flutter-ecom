import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../views/sign_in.dart';
import '../views/sign_up_otp_code.dart';

class RegisterController extends GetxController {
  var isLoad = false.obs;

  Future<void> registerUser(
    String firstname,
    String lastname,
    String email,
    String password,
    String confirmPassword,
  ) async {
    isLoad.value = true;
    update();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/users/"),
        body: {
          "first_name": firstname,
          "last_name": lastname,
          "email": email,
          "password": password,
          "password_confirm": confirmPassword,
        },
      );

      if (response.statusCode == 201) {
        showSuccessSnackbar("Registration successful. Please login.");
        log('Registration success: ${response.body}');
        Get.offAll(
          () => const SignUpOtpCode(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        isLoad.value = false;
        update();
      } else {
        final error = jsonDecode(response.body);
        showFailureSnackbar(error.toString());
      }
    } catch (e) {
      log('Registration failed: $e');
      showFailureSnackbar("Registration failed. Please try again.");
    } finally {
      isLoad.value = false;
      update();
    }
  }
}
