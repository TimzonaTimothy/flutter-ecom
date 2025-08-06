import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_models.dart';

// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final notificationsToday = [
//       NotificationItem(Icons.local_shipping, "Order Shipped", "1h"),
//       NotificationItem(Icons.flash_on, "Flash Sale Alert", "1h"),
//       NotificationItem(Icons.star_border, "Product Review Request", "1h"),
//     ];

//     final notificationsYesterday = [
//       NotificationItem(Icons.local_shipping, "Order Shipped", "1d"),
//     ];

//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Notification", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Chip(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 side: BorderSide.none,
//               ),
//               label: const Text("2 NEW", style: TextStyle(color: Colors.white)),
//               backgroundColor: AppStyles.primaryColor,
//               elevation: 0,
//             ),
//           )
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildSection("TODAY", notificationsToday),
//           const SizedBox(height: 24),
//           _buildSection("YESTERDAY", notificationsYesterday),
//           _buildSection("TODAY", notificationsToday),
//           const SizedBox(height: 24),
//           _buildSection("YESTERDAY", notificationsYesterday),
//           _buildSection("TODAY", notificationsToday),
//           const SizedBox(height: 24),
//           _buildSection("YESTERDAY", notificationsYesterday),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<NotificationItem> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(title,
//                 style: AppStyles.headLineStyle3
//                     .copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
//             const Spacer(),
//             Text("Mark all as read",
//                 style: AppStyles.headLineStyle3.copyWith(
//                     color: AppStyles.primaryColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         ...items.map((item) => _buildNotificationTile(item)),
//       ],
//     );
//   }

//   Widget _buildNotificationTile(NotificationItem item) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppStyles.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.grey[200],
//             child: Icon(item.icon, color: AppStyles.primaryColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                         child: Text(item.title,
//                             style: AppStyles.headLineStyle4
//                                 .copyWith(color: AppStyles.blackColor))),
//                     Text(item.time, style: AppStyles.headLineStyle4),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   style: AppStyles.textStyle,
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class NotificationItem {
//   final IconData icon;
//   final String title;
//   final String time;

//   NotificationItem(this.icon, this.title, this.time);
// }




class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Notification", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            try {
              Get.back();
            } catch (e) {
              print('Error navigating back: $e');
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(() {
              final count = controller.unreadCount.value;
              return Chip(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  side: BorderSide.none,
                ),
                label: Text(
                  "$count NEW",
                  style: const TextStyle(color: Colors.white),
                  textScaler: TextScaler.linear(textScaleFactor),
                ),
                backgroundColor: AppStyles.primaryColor,
                elevation: 0,
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppStyles.primaryColor),
          );
        }

        final groupedNotifications = controller.getGroupedNotifications();
        if (groupedNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'No new notifications',
                  style:AppStyles.headLineStyle4,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: groupedNotifications.entries.map((entry) {
            return _buildSection(context, entry.key, entry.value, controller);
          }).toList(),
        );
      }),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<NotificationModel> notifications,
    NotificationController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppStyles.headLineStyle3.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14 * textScaleFactor,
              ),
            ),
            const Spacer(),
            if (notifications.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  await controller.markAllAsRead();
                },
                child: Text(
                  "Mark all as read",
                  style: AppStyles.headLineStyle3.copyWith(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * textScaleFactor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...notifications.map((notification) => _buildNotificationTile(context, notification, controller)),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

    return GestureDetector(
      onTap: () async {
        await controller.markAsRead(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppStyles.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(
                _getIconForNotification(notification.title),
                color: AppStyles.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppStyles.headLineStyle4.copyWith(
                            color: AppStyles.blackColor,
                            // textScaler: TextScaler.linear(textScaleFactor),
                          ),
                        ),
                      ),
                      Text(
                        notification.getFormattedTime(),
                        style: AppStyles.headLineStyle4.copyWith(
                          // textScaler: TextScaler.linear(textScaleFactor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppStyles.textStyle.copyWith(
                      // textScaler: TextScaler.linear(textScaleFactor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForNotification(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('shipped')) {
      return Icons.local_shipping;
    } else if (lowerTitle.contains('sale')) {
      return Icons.flash_on;
    } else if (lowerTitle.contains('review')) {
      return Icons.star_border;
    } else {
      return Icons.notifications;
    }
  }
}