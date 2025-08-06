import 'package:get/get.dart';

import '../models/notification_models.dart';
import '../service/notification_service.dart';
class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final fetchedNotifications = await NotificationService().getNotifications();
      notifications.assignAll(fetchedNotifications);
      await fetchUnreadCount(); // Ensure count is updated after fetching
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await NotificationService().getUnreadNotificationCount();
      unreadCount.value = count;
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final success = await NotificationService().markNotificationAsRead(notificationId);
    if (success) {
      // Update the notification in-place instead of removing
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          orderId: notifications[index].orderId,
          title: notifications[index].title,
          message: notifications[index].message,
          isRead: true,
          createdDate: notifications[index].createdDate,
          modifiedDate: DateTime.now(),
        );
        notifications.refresh(); // Trigger UI update
        await fetchUnreadCount(); // Update unread count reactively
      }
    }
  }

  Future<void> markAllAsRead() async {
    // Only mark unread notifications
    final unreadIds = notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isNotEmpty) {
      final success = await NotificationService().markAllNotificationsAsRead(unreadIds);
      if (success) {
        // Update all unread notifications in-place
        for (final id in unreadIds) {
          final index = notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            notifications[index] = NotificationModel(
              id: notifications[index].id,
              orderId: notifications[index].orderId,
              title: notifications[index].title,
              message: notifications[index].message,
              isRead: true,
              createdDate: notifications[index].createdDate,
              modifiedDate: DateTime.now(),
            );
          }
        }
        notifications.refresh(); // Trigger UI update
        await fetchUnreadCount(); // Update unread count reactively
      }
    }
  }

  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    for (final notification in notifications) {
      final section = notification.getSectionTitle();
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(notification);
    }
    return grouped;
  }
}