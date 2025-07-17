

import 'package:get/get.dart';

import '../../base/utils/my_request.dart';
import '../../base/utils/snackbar.dart';
import '../views/sign_in.dart';

class OtpController extends GetxController {
  var isLoading = false.obs;

  Future<void> verifyOtp(String email, String otp) async {
    isLoading.value = true;

    final res = await MyRequest('auth/activate-otp/', {
      "email": email,
      "otp": otp,
    }, false, 200)
        .init()
        .postApi();

    isLoading.value = false;

    if (res != null) {
      showSuccessSnackbar("OTP Verified. Account activated.");
      Get.offAll(() => const SignInScreen());
    }
  }

  Future<void> resendOtp(String email) async {
    isLoading.value = true;

    final res = await MyRequest('auth/resend-otp/', {
      "email": email,
    }, false, 200)
        .init()
        .postApi();

    isLoading.value = false;

    if (res != null) {
      showSuccessSnackbar("OTP resent successfully.");
    }
  }
}