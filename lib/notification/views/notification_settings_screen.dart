import 'dart:io';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/push_notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled =
          await PushNotificationService.instance.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (value) {
        // Show dialog asking user to confirm
        final confirmed = await _showEnableNotificationDialog();
        if (confirmed) {
          final success =
              await PushNotificationService.instance.enableNotifications();
          if (success) {
            await PushNotificationService.instance.setNotificationEnabled(true);
            setState(() {
              _notificationsEnabled = true;
            });
            showSuccessSnackbar('Notifications enabled successfully!');
          } else {
            showFailureSnackbar(
                'Failed to enable notifications. Please check your permissions.');
          }
        }
      } else {
        await PushNotificationService.instance.setNotificationEnabled(false);
        setState(() {
          _notificationsEnabled = false;
        });
        showSuccessSnackbar('Notifications disabled');
      }
    } catch (e) {
      print('Error toggling notifications: $e');
      showFailureSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showEnableNotificationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Enable Notifications',
                style: AppStyles.headLineStyle2,
              ),
              content: const Text(
                'You will receive push notifications for:\n\n'
                '• Order updates\n'
                '• Shipping notifications\n'
                '• Special offers\n'
                '• Important announcements\n\n'
                'You can disable this anytime in settings.',
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    Expanded(
                  child: OutlinedButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      backgroundColor: WidgetStateProperty.all(
                          AppStyles.primaryColor.withOpacity(0.1)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: AppStyles.primaryColor, width: 0.5),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: AppStyles.headLineStyle3
                          .copyWith(color: AppStyles.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    label: Text(
                      "Enable",
                      style: AppStyles.headLineStyle3
                          .copyWith(color: AppStyles.whiteColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                  ]
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Notification Settings", style: AppStyles.headLineStyle2),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: AppStyles.primaryColor,
            ))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
              children: [
                Card(
                  color: AppStyles.whiteColor.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications,
                                color: AppStyles.primaryColor),
                            const SizedBox(width: 12),
                            Text('Push Notifications',
                                style: AppStyles.headLineStyle3),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Receive notifications about your orders, shipping updates, and special offers.',
                            style: AppStyles.textStyle),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enable Notifications',
                              style: AppStyles.headLineStyle4
                                  .copyWith(color: AppStyles.blackColor),
                            ),
                            Platform.isIOS
                                ? CupertinoSwitch(
                                    value: _notificationsEnabled,
                                    onChanged: _toggleNotifications,
                                  )
                                : Switch(
                                    activeColor: AppStyles.primaryColor,
                                    value: _notificationsEnabled,
                                    onChanged: _toggleNotifications,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_notificationsEnabled) ...[
                  Card(
                    color: AppStyles.whiteColor.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notification Types',
                              style: AppStyles.headLineStyle3),
                          const SizedBox(height: 12),
                          _buildNotificationTypeItem(
                            icon: Icons.local_shipping,
                            title: 'Order Updates',
                            subtitle:
                                'Get notified when your order status changes',
                            enabled: true,
                          ),
                          _buildNotificationTypeItem(
                            icon: Icons.card_giftcard,
                            title: 'Special Offers',
                            subtitle:
                                'Receive notifications about deals and promotions',
                            enabled: true,
                          ),
                          _buildNotificationTypeItem(
                            icon: Icons.announcement,
                            title: 'Announcements',
                            subtitle: 'Important updates and news',
                            enabled: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppStyles.whiteColor.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notification Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '✓ Notifications are enabled\n'
                            '✓ You will receive order updates\n'
                            '✓ Push notifications are active',
                            style: TextStyle(
                              color: AppStyles.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: AppStyles.whiteColor.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Why Enable Notifications?',
                              style: AppStyles.headLineStyle3),
                          const SizedBox(height: 12),
                          Text(
                              '• Stay updated on your order status\n'
                              '• Get instant shipping notifications\n'
                              '• Never miss special offers\n'
                              '• Receive important announcements',
                              style: AppStyles.textStyle),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildNotificationTypeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              color: enabled ? AppStyles.primaryColor : AppStyles.greColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppStyles.headLineStyle4
                        .copyWith(color: AppStyles.blackColor)),
                Text(subtitle, style: AppStyles.textStyle),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: enabled ? AppStyles.primaryColor : AppStyles.greColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
