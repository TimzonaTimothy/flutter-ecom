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
      final fetchedNotifications = await NotificationService().getUnreadNotifications();
      notifications.assignAll(fetchedNotifications);
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
      notifications.removeWhere((n) => n.id == notificationId);
      await fetchUnreadCount(); // Update count after marking as read
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = notifications.map((n) => n.id).toList();
    if (unreadIds.isNotEmpty) {
      final success = await NotificationService().markAllNotificationsAsRead(unreadIds);
      if (success) {
        notifications.clear();
        await fetchUnreadCount();
      }
    }
  }

  // Group notifications by section (Today, Yesterday, etc.)
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