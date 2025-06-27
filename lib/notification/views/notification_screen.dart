import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsToday = [
      NotificationItem(Icons.local_shipping, "Order Shipped", "1h"),
      NotificationItem(Icons.flash_on, "Flash Sale Alert", "1h"),
      NotificationItem(Icons.star_border, "Product Review Request", "1h"),
    ];

    final notificationsYesterday = [
      NotificationItem(Icons.local_shipping, "Order Shipped", "1d"),
    ];

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
            Get.back();
          },
        ),
        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text("2 NEW", style: TextStyle(color: Colors.white)),
              backgroundColor: AppStyles.primaryColor,
              elevation: 0,
              
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection("TODAY", notificationsToday),
          const SizedBox(height: 24),
          _buildSection("YESTERDAY", notificationsYesterday),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<NotificationItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Text("Mark all as read",
                style: AppStyles.headLineStyle3.copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildNotificationTile(item)),
      ],
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
       
        color:  AppStyles.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Icon(item.icon, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(item.title,
                            style:
                                AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor))),
                    Text(item.time, style: AppStyles.headLineStyle4),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  style: AppStyles.textStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String time;

  NotificationItem(this.icon, this.title, this.time);
}
