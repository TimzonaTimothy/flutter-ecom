import 'package:get/get.dart';

import '../../base/utils/push_notification_service.dart';
import '../../base/utils/snackbar.dart';
import '../models/notification_models.dart';
import '../service/notification_service.dart';


// class NotificationController extends GetxController {
//   final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
//   final RxInt unreadCount = 0.obs;
//   final RxBool isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchNotifications();
//     fetchUnreadCount();
//   }

//   Future<void> fetchNotifications() async {
//     try {
//       isLoading.value = true;
//       final fetchedNotifications = await NotificationService().getNotifications();
//       notifications.assignAll(fetchedNotifications);
//       await fetchUnreadCount(); // Ensure count is updated after fetching
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> fetchUnreadCount() async {
//     try {
//       final count = await NotificationService().getUnreadNotificationCount();
//       unreadCount.value = count;
//     } catch (e) {
//       print('Error fetching unread count: $e');
//     }
//   }

//   Future<void> markAsRead(int notificationId) async {
//     final success = await NotificationService().markNotificationAsRead(notificationId);
//     if (success) {
//       // Update the notification in-place instead of removing
//       final index = notifications.indexWhere((n) => n.id == notificationId);
//       if (index != -1) {
//         notifications[index] = NotificationModel(
//           id: notifications[index].id,
//           orderId: notifications[index].orderId,
//           title: notifications[index].title,
//           message: notifications[index].message,
//           isRead: true,
//           notificationType: notifications[index].notificationType,
//           createdDate: notifications[index].createdDate,
//           modifiedDate: DateTime.now(),
//         );
//         notifications.refresh(); // Trigger UI update
//         await fetchUnreadCount(); // Update unread count reactively
//       }
//     }
//   }

//   Future<void> markAllAsRead() async {
//     // Only mark unread notifications
//     final unreadIds = notifications.where((n) => !n.isRead).map((n) => n.id).toList();
//     if (unreadIds.isNotEmpty) {
//       final success = await NotificationService().markAllNotificationsAsRead(unreadIds);
//       if (success) {
//         // Update all unread notifications in-place
//         for (final id in unreadIds) {
//           final index = notifications.indexWhere((n) => n.id == id);
//           if (index != -1) {
//             notifications[index] = NotificationModel(
//               id: notifications[index].id,
//               orderId: notifications[index].orderId,
//               title: notifications[index].title,
//               message: notifications[index].message,
//               isRead: true,
//               notificationType: notifications[index].notificationType,
//               createdDate: notifications[index].createdDate,
//               modifiedDate: DateTime.now(),
//             );
//           }
//         }
//         notifications.refresh(); // Trigger UI update
//         await fetchUnreadCount(); // Update unread count reactively
//       }
//     }
//   }

//   Map<String, List<NotificationModel>> getGroupedNotifications() {
//     final Map<String, List<NotificationModel>> grouped = {};
//     for (final notification in notifications) {
//       final section = notification.getSectionTitle();
//       if (!grouped.containsKey(section)) {
//         grouped[section] = [];
//       }
//       grouped[section]!.add(notification);
//     }
//     return grouped;
//   }
// }


class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();
  final PushNotificationService _pushService = PushNotificationService.instance;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, bool> notificationPreferences = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    try {
      isLoading.value = true;
      final fetchedNotifications = await _service.getNotifications(unreadOnly: unreadOnly);
      notifications.assignAll(fetchedNotifications);
      unreadCount.value = await _service.getUnreadNotificationCount();
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

Future<void> fetchNotificationPreferences() async {
    try {
      final prefs = await _pushService.getNotificationPreferences();
      notificationPreferences.assignAll(prefs);
    } catch (e) {
      print('Error fetching notification preferences: $e');
    }
  }

  Future<void> toggleNotificationType(String type, bool enabled) async {
    try {
      await _pushService.setNotificationTypeEnabled(type, enabled);
      notificationPreferences[type] = enabled;
      notificationPreferences.refresh();
    } catch (e) {
      print('Error toggling notification type $type: $e');
      showFailureSnackbar('Failed to update notification preference');
    }
  }
  
  Future<void> markAsRead(int notificationId) async {
    final success = await _service.markNotificationAsRead(notificationId);
    if (success) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          orderId: notifications[index].orderId,
          title: notifications[index].title,
          message: notifications[index].message,
          isRead: true,
          notificationType: notifications[index].notificationType,
          createdDate: notifications[index].createdDate,
          modifiedDate: DateTime.now(),
        );
        notifications.refresh();
        unreadCount.value = await _service.getUnreadNotificationCount();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isNotEmpty) {
      final success = await _service.markAllNotificationsAsRead(unreadIds);
      if (success) {
        for (final id in unreadIds) {
          final index = notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            notifications[index] = NotificationModel(
              id: notifications[index].id,
              orderId: notifications[index].orderId,
              title: notifications[index].title,
              message: notifications[index].message,
              isRead: true,
              notificationType: notifications[index].notificationType,
              createdDate: notifications[index].createdDate,
              modifiedDate: DateTime.now(),
            );
          }
        }
        notifications.refresh();
        unreadCount.value = await _service.getUnreadNotificationCount();
      }
    }
  }

  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    for (final notification in notifications) {
      final section = notification.getSectionTitle();
      grouped.putIfAbsent(section, () => []).add(notification);
    }
    return grouped;
  }
}