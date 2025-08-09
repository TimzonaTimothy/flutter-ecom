import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../auth/service/auth_service.dart';
import '../../auth/service/http_interceptor.dart';
import '../../base/res/base_url.dart';
import '../models/profile_model.dart';


class ProfileController extends GetxController {
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uri = Uri.parse('$baseUrl/auth/profile/');
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.get(
        uri,
        headers: headers,
        
      );

      print('Profile response: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        userProfile.value = UserModel.fromJson(json);
      } else {
        errorMessage.value = 'Failed to fetch profile: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      print('Profile fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> updateUserProfile({
  //   String? firstName,
  //   String? lastName,
  //   String? phone,
  //   String? city,
  //   String? state,
  //   String? gender,
  //   String? country,
  //   XFile? profilePictureFile,
  // }) async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';

  //     final uri = Uri.parse('$baseUrl/auth/profile/');
  //     final headers = await AuthService.instance.getAuthHeaders();
  //     final response = await http.patch(
  //       uri,
  //       headers: headers,
  //       body: jsonEncode({
  //         'first_name': firstName,
  //         'last_name': lastName,
  //         'phone': phone,
  //         'gender':gender,
  //         'city': city,
  //         'state': state,
  //         'country': country,
  //         'profile_picture': profilePicture,
  //       }..removeWhere((key, value) => value == null || value.isEmpty)),
  //     );

  //     print('Update profile response: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final json = jsonDecode(response.body);
  //       userProfile.value = UserModel.fromJson(json);
  //       return true;
  //     } else {
  //       errorMessage.value = 'Failed to update profile: ${response.statusCode}';
  //       return false;
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'Network error: $e';
  //     print('Profile update error: $e');
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }


Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? gender,
    XFile? profilePictureFile,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uri = Uri.parse('$baseUrl/auth/profile/');
      final headers = await AuthService.instance.getAuthHeaders();

      // Create a multipart request
      var request = http.MultipartRequest('PATCH', uri)
        ..headers.addAll(headers)
        ..fields['first_name'] = firstName ?? ''
        ..fields['last_name'] = lastName ?? ''
        ..fields['phone'] = phone ?? ''
        ..fields['city'] = city ?? ''
        ..fields['state'] = state ?? ''
        ..fields['country'] = country ?? ''
        ..fields['gender'] = gender ?? '';

      // Add profile picture file if selected
      if (profilePictureFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePictureFile.path,
          filename: 'profile_picture.${profilePictureFile.path.split('.').last}',
        ));
      }

      print('Update profile request fields: ${request.fields}');
      if (profilePictureFile != null) {
        print('Update profile request file: ${profilePictureFile.path}');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Update profile response: $responseBody');

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);
        userProfile.value = UserModel.fromJson(json);
        return true;
      } else {
        final json = jsonDecode(responseBody);
        if (json is Map && json.containsKey('profile_picture')) {
          errorMessage.value = 'Profile picture error: ${json['profile_picture'].join(', ')}';
        } else if (json is Map && json.containsKey('gender')) {
          errorMessage.value = 'Gender error: ${json['gender'].join(', ')}';
        } else {
          errorMessage.value = json['detail'] ?? 'Failed to update profile: ${response.statusCode}';
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      print('Profile update error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      update();

      final uri = Uri.parse('$baseUrl/auth/change-password/');
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      print('Change password response: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final json = jsonDecode(response.body);
        errorMessage.value = json['error']?['details']?['detail'] ??
            json['detail'] ??
            'Login failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      print('Change password error: $e');
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
