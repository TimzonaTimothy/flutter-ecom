import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../base/bottom_nav_bar.dart';
import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../../base/utils/token.dart';

class LoginController extends GetxController {
  var isLoad = false.obs;

  Future<void> loginUser(String email, String password) async {
    isLoad.value = true;
    update();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/auth/jwt/create/"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar("Login successful");
        log(response.body);
        // User user = User.fromJson(jsonDecode(response.body));
        // await saveToken(jsonDecode(response.body)['access']);
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);

        // log('User: ${user.username}, ${user.isActive}');

        Get.offAll(
          () => const BottomNavBar(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        isLoad.value = false;
        update();
        return;
      } else {
        showFailureSnackbar(
          jsonDecode(response.body)['detail'] ?? 'Login failed',
        );
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
