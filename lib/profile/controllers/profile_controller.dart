import 'dart:convert';

import '../../auth/service/auth_service.dart';
import '../../auth/service/http_interceptor.dart';
import '../../base/res/base_url.dart';

class Profile {
  // Example of making authenticated API calls
  static Future<void> fetchUserData() async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await AuthHttpClient.instance.get(
        '$baseUrl/user/profile/',
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('User data: $data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

 
}