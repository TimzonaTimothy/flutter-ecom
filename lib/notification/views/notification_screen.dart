import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../order/views/review_screen.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_models.dart';




// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(NotificationController());
//     final screenWidth = MediaQuery.of(context).size.width;
//     final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Notifications", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             try {
//               Get.back();
//             } catch (e) {
//               print('Error navigating back: $e');
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Obx(() {
//               final count = controller.unreadCount.value;
//               return Visibility(
//                 visible: count > 0,
//                 child: Chip(
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                     side: BorderSide.none,
//                   ),
//                   label: Text(
//                     "$count NEW",
//                     style: const TextStyle(color: Colors.white),
//                     textScaler: TextScaler.linear(textScaleFactor),
//                   ),
//                   backgroundColor: AppStyles.primaryColor,
//                   elevation: 0,
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CircularProgressIndicator(color: AppStyles.primaryColor),
//           );
//         }

//         final groupedNotifications = controller.getGroupedNotifications();
//         if (groupedNotifications.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.notifications_none,
//                   size: 64,
//                   color: Colors.grey[600],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No notifications',
//                   style: AppStyles.headLineStyle4.copyWith(
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: groupedNotifications.entries.map((entry) {
//             return _buildSection(context, entry.key, entry.value, controller);
//           }).toList(),
//         );
//       }),
//     );
//   }

//   Widget _buildSection(
//     BuildContext context,
//     String title,
//     List<NotificationModel> notifications,
//     NotificationController controller,
//   ) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: AppStyles.headLineStyle3.copyWith(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14 * textScaleFactor,
//               ),
//             ),
//             const Spacer(),
//             if (notifications.any((n) => !n.isRead))
//               GestureDetector(
//                 onTap: () async {
//                   await controller.markAllAsRead();
//                 },
//                 child: Text(
//                   "Mark all as read",
//                   style: AppStyles.headLineStyle3.copyWith(
//                     color: AppStyles.primaryColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14 * textScaleFactor,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         ...notifications.map((notification) => _buildNotificationTile(context, notification, controller)),
//       ],
//     );
//   }

//   Widget _buildNotificationTile(
//     BuildContext context,
//     NotificationModel notification,
//     NotificationController controller,
//   ) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

//     return GestureDetector(
//       onTap: () async {
//         if (!notification.isRead) {
//           await controller.markAsRead(notification.id);
//           if (notification.title.toLowerCase().contains('review')) {
//             Get.to(() => LeaveReviewPage(orderId: notification.orderId));
//           }
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: notification.isRead ? AppStyles.whiteColor.withOpacity(0.7) : AppStyles.greColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.grey[200],
//               child: Icon(
//                 _getIconForNotification(notification.title),
//                 color: AppStyles.primaryColor,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           notification.title,
//                           style: AppStyles.headLineStyle4.copyWith(
//                             color: notification.isRead ? AppStyles.blackColor.withOpacity(0.6) : AppStyles.blackColor,
//                             fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         notification.getFormattedTime(),
//                         style: AppStyles.headLineStyle4.copyWith(
//                           color: notification.isRead ? Colors.grey[600] : AppStyles.blackColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     notification.message,
//                     style: AppStyles.textStyle.copyWith(
//                       color: notification.isRead ? Colors.grey[600] : AppStyles.blackColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getIconForNotification(String title) {
//     final lowerTitle = title.toLowerCase();
//     if (lowerTitle.contains('shipped')) {
//       return Icons.local_shipping;
//     } else if (lowerTitle.contains('sale')) {
//       return Icons.flash_on;
//     } else if (lowerTitle.contains('review')) {
//       return Icons.star_border;
//     } else {
//       return Icons.notifications;
//     }
//   }
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
        title: Text("Notifications", style: AppStyles.headLineStyle2),
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
              return Visibility(
                visible: count > 0,
                child: Chip(
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
                ),
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
          return RefreshIndicator(
            onRefresh: controller.fetchNotifications,
            color: AppStyles.primaryColor,
            backgroundColor: AppStyles.bgColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
                child: Center(
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
                        'No notifications',
                        style: AppStyles.headLineStyle4.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: AppStyles.primaryColor,
          backgroundColor: AppStyles.bgColor,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: groupedNotifications.entries.map((entry) {
              return _buildSection(context, entry.key, entry.value, controller);
            }).toList(),
          ),
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
            if (notifications.any((n) => !n.isRead))
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

  // Widget _buildNotificationTile(
  //   BuildContext context,
  //   NotificationModel notification,
  //   NotificationController controller,
  // ) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

  //   return GestureDetector(
  //     // onTap: () async {
  //     //   if (!notification.isRead.value) {
  //     //     await controller.markAsRead(notification.id);
  //     //     if (notification.title.toLowerCase().contains('review')) {
  //     //       Get.to(() => LeaveReviewPage(orderId: notification.orderId));
  //     //     }
  //     //   }
  //     // },
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 8),
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         // color: notification.isRead.value ? AppStyles.whiteColor.withOpacity(0.7) : AppStyles.greColor.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         children: [
  //           CircleAvatar(
  //             radius: 24,
  //             backgroundColor: Colors.grey[200],
  //             child: Icon(
  //               _getIconForNotification(notification.title),
  //               color: AppStyles.primaryColor,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         notification.title,
  //                         style: AppStyles.headLineStyle4.copyWith(
  //                           // color: notification.isRead.value ? AppStyles.blackColor.withOpacity(0.6) : AppStyles.blackColor,
  //                           // fontWeight: notification.isRead.value ? FontWeight.normal : FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     Text(
  //                       notification.getFormattedTime(),
  //                       style: AppStyles.headLineStyle4.copyWith(
  //                         // color: notification.isRead.value ? Colors.grey[600] : AppStyles.blackColor,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   notification.message,
  //                   style: AppStyles.textStyle.copyWith(
  //                     // color: notification.isRead.value ? Colors.grey[600] : AppStyles.blackColor,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  
  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await controller.markAsRead(notification.id);
          if (notification.title.toLowerCase().contains('review')) {
            Get.to(() => LeaveReviewPage(orderId: notification.orderId));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? AppStyles.whiteColor.withOpacity(0.7) : AppStyles.greColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(
                _getIconForNotification(notification.notificationType),
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
                            color: notification.isRead ? AppStyles.blackColor.withOpacity(0.6) : AppStyles.blackColor,
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        notification.getFormattedTime(),
                        style: AppStyles.headLineStyle4.copyWith(
                          color: notification.isRead ? Colors.grey[600] : AppStyles.blackColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppStyles.textStyle.copyWith(
                      color: notification.isRead ? Colors.grey[600] : AppStyles.blackColor,
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

  IconData _getIconForNotification(String notificationType) {
    final lowerNotificationType  = notificationType.toLowerCase();
    
    if (lowerNotificationType.contains('shipped')) {
      return Icons.local_shipping;
    } else if (lowerNotificationType.contains('delivered')) {
      return Icons.check_circle;
    }else if (lowerNotificationType.contains('placed')) {
      return Icons.shopping_cart_checkout;
    } else if (lowerNotificationType.contains('promotion')) {
      return Icons.local_offer;
    }else if (lowerNotificationType.contains('announcement')) {
      return Icons.campaign;
    } else {
      return Icons.notifications;
    }
  }
}