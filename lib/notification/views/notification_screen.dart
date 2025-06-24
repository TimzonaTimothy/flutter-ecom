import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
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
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Notification'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text("2 NEW", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.brown,
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection("TODAY", notificationsToday),
          SizedBox(height: 24),
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
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Text("Mark all as read", style: TextStyle(color: Colors.brown)),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) => _buildNotificationTile(item)).toList(),
      ],
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Icon(item.icon, color: Colors.brown),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold))),
                    Text(item.time, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
