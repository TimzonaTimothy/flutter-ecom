
import 'dart:developer';

import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../../base/utils/token.dart';
import '../../home/views/home_screen.dart';
import '../models/user_log.dart';

class LoginController extends GetxController {
  var isLoad = false.obs;

  Future<void> loginUser(String username, String password) async {
    isLoad.value = true;
    update();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/jwt/create/"),
        body: {"username": username, "password": password},
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar("Login successful");
        log(response.body);
        // User user = User.fromJson(jsonDecode(response.body));
        await saveToken(jsonDecode(response.body)['access']);

        // log('User: ${user.username}, ${user.isActive}');

        Get.offAll(() => HomeScreen());
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
