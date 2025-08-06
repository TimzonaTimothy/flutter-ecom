import 'dart:convert';

import '../../auth/service/auth_service.dart';
import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../models/notification_models.dart';
import 'package:http/http.dart' as http;



class NotificationService {

  static const String _baseUrl =baseUrl;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final _token = await AuthService.instance.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/me/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        showFailureSnackbar('Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      showFailureSnackbar('Error fetching notifications');
      return [];
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final _token = await AuthService.instance.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/count/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] as int;
      } else {
        showFailureSnackbar('Failed to fetch notification count: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching notification count: $e');
      showFailureSnackbar('Error fetching notification count');
      return 0;
    }
  }

  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final _token = await AuthService.instance.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/update/?id=$notificationId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar('Notification marked as read');
        return true;
      } else {
        showFailureSnackbar('Failed to update notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating notification: $e');
      showFailureSnackbar('Error updating notification');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead(List<int> notificationIds) async {
    try {
      bool allSuccess = true;
      for (final id in notificationIds) {
        final success = await markNotificationAsRead(id);
        if (!success) allSuccess = false;
      }
      if (allSuccess) {
        showSuccessSnackbar('All notifications marked as read');
      } else {
        showFailureSnackbar('Some notifications could not be marked as read');
      }
      return allSuccess;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      showFailureSnackbar('Error marking all notifications as read');
      return false;
    }
  }

 
Future<List<NotificationModel>> getAllNotifications() async {
  try {
    final _token = await AuthService.instance.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/notifications/me/'), // same endpoint
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      showFailureSnackbar('Failed to fetch notifications: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching notifications: $e');
    showFailureSnackbar('Error fetching notifications');
    return [];
  }
}

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final _token = await AuthService.instance.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/me/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        showFailureSnackbar('Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      showFailureSnackbar('Error fetching notifications');
      return [];
    }
  }

  

 
}