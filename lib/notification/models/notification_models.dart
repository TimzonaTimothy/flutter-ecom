
import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final int orderId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdDate;
  final DateTime modifiedDate;

  NotificationModel({
    required this.id,
    required this.orderId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdDate,
    required this.modifiedDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdDate: DateTime.parse(json['created_date'] as String),
      modifiedDate: DateTime.parse(json['modified_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_date': createdDate.toIso8601String(),
      'modified_date': modifiedDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Notification(id: $id, orderId: $orderId, title: $title, isRead: $isRead)';
  }

  // Helper to format time for UI (e.g., "1h", "1d")
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(createdDate);
    }
  }

  // Helper to determine section (Today, Yesterday, etc.)
  String getSectionTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(createdDate.year, createdDate.month, createdDate.day);

    if (notificationDate == today) {
      return 'TODAY';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY';
    } else {
      return DateFormat('MMMM d, yyyy').format(notificationDate);
    }
  }
}
