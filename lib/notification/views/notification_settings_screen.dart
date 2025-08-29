import 'dart:convert';
import 'dart:io';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../auth/service/auth_service.dart';
import '../../base/res/base_url.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/utils/push_notification_service.dart';
import '../controllers/notification_controller.dart';

// class NotificationSettingsScreen extends StatefulWidget {
//   const NotificationSettingsScreen({super.key});

//   @override
//   _NotificationSettingsScreenState createState() =>
//       _NotificationSettingsScreenState();
// }

// class _NotificationSettingsScreenState
//     extends State<NotificationSettingsScreen> {
//   bool _notificationsEnabled = false;
//   bool _isLoading = true;
//   bool _isSyncing = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotificationSettings();
//   }

//   Future<void> _loadNotificationSettings() async {
//     try {
      
//       final localEnabled =
//           await PushNotificationService.instance.areNotificationsEnabled();
//       print('Local notifications enabled: $localEnabled');

//       final backendEnabled = await _getBackendNotificationPreference();
//       print('Backend notifications enabled: $backendEnabled');

//       final actualEnabled = backendEnabled ?? localEnabled;
//       print('Actual enabled state: $actualEnabled');

//       setState(() {
//         _notificationsEnabled = actualEnabled;
//         _isLoading = false;
//       });

//       if (localEnabled != actualEnabled) {
//         print('Syncing local settings to: $actualEnabled');
//         await PushNotificationService.instance
//             .setNotificationEnabled(actualEnabled);
//         if (!actualEnabled) {
//           await FirebaseMessaging.instance.unsubscribeFromTopic('all');
//           print('Unsubscribed from topic "all" during settings load');
//         }
//       }
//     } catch (e) {
//       print('Error loading notification settings: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool> _updateBackendNotificationPreference(bool enabled) async {
//     try {
//       const fullUrl = baseUrl;
//       final url = Uri.parse('$fullUrl/notifications/preferences/');
//       final headers = await AuthService.instance.getAuthHeaders();
//       final body = json.encode({'push_notifications_enabled': enabled});

//       print('Sending PATCH to $url with headers: $headers, body: $body');

//       final response = await http.patch(url, headers: headers, body: body);

//       print('Response status: ${response.statusCode}, body: ${response.body}');

//       if (response.statusCode == 200) {
//         print(
//             'Backend notification preference updated successfully to: $enabled');
//         return true;
//       } else {
//         print(
//             'Failed to update backend notification preference: ${response.statusCode}, ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error updating backend notification preference: $e');
//       return false;
//     }
//   }

//   Future<bool?> _getBackendNotificationPreference() async {
//     try {
//       const fullUrl = baseUrl;
//       final url = Uri.parse('$fullUrl/notifications/preferences/');
//       final headers = await AuthService.instance.getAuthHeaders();

//       print('Sending GET to $url with headers: $headers');

//       final response = await http.get(url, headers: headers);

//       print(
//           'GET response status: ${response.statusCode}, body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final enabled = data['push_notifications_enabled'] as bool?;
//         print('Backend push_notifications_enabled: $enabled');
//         return enabled;
//       } else {
//         print(
//             'Failed to get backend notification preference: ${response.statusCode}, ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error getting backend notification preference: $e');
//       return null;
//     }
//   }

//   Future<void> _toggleNotifications(bool value) async {
//     setState(() {
//       _isSyncing = true;
//     });

//     try {
//       print('Toggling notifications to: $value');
//       if (value) {
//         final confirmed = await _showEnableNotificationDiaprint();
//         print('Dialog confirmed: $confirmed');
//         if (confirmed) {
//           final success =
//               await PushNotificationService.instance.enableNotifications();
//           print('Enable notifications success: $success');
//           if (success) {
//             final backendSuccess =
//                 await _updateBackendNotificationPreference(true);
//             print('Backend update (enable) success: $backendSuccess');
//             if (backendSuccess) {
//               setState(() {
//                 _notificationsEnabled = true;
//               });
//               showSuccessSnackbar('Notifications enabled successfully!');
//             } else {
//               await PushNotificationService.instance
//                   .setNotificationEnabled(false);
//               showFailureSnackbar(
//                   'Failed to sync with server. Please try again.');
//             }
//           } else {
//             showFailureSnackbar(
//                 'Failed to enable notifications. Please check your permissions.');
//           }
//         }
//       } else {
//         print('Attempting to disable notifications');
//         // Update local state first to prevent notifications during sync
//         await PushNotificationService.instance.setNotificationEnabled(false);
//         final backendSuccess =
//             await _updateBackendNotificationPreference(false);
//         print('Backend update (disable) success: $backendSuccess');
//         if (backendSuccess) {
//           await FirebaseMessaging.instance.unsubscribeFromTopic('all');
//           print('Unsubscribed from topic "all"');
//           setState(() {
//             _notificationsEnabled = false;
//           });
//           showSuccessSnackbar('Notifications disabled');
//         } else {
//           // Rollback local state
//           await PushNotificationService.instance.setNotificationEnabled(true);
//           setState(() {
//             _notificationsEnabled = true;
//           });
//           showFailureSnackbar('Failed to sync with server. Please try again.');
//         }
//       }
//     } catch (e) {
//       print('Error toggling notifications: $e');
//       await _loadNotificationSettings();
//       showFailureSnackbar('An error occurred. Please try again.');
//     } finally {
//       setState(() {
//         _isSyncing = false;
//       });
//     }
//   }

//   Future<bool> _showEnableNotificationDiaprint() async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDiaprint(
//               title: Text(
//                 'Enable Notifications',
//                 style: AppStyles.headLineStyle2,
//               ),
//               content: const Text(
//                 'You will receive push notifications for:\n\n'
//                 '• Order updates\n'
//                 '• Shipping notifications\n'
//                 '• Special offers\n'
//                 '• Important announcements\n\n'
//                 'You can disable this anytime in settings.',
//               ),
//               actions: [
//                 Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: ButtonStyle(
//                             padding: WidgetStateProperty.all(
//                                 const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 14)),
//                             backgroundColor: WidgetStateProperty.all(
//                                 AppStyles.primaryColor.withOpacity(0.1)),
//                             shape: WidgetStateProperty.all(
//                               RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20)),
//                             ),
//                             side: WidgetStateProperty.all(
//                               BorderSide(
//                                   color: AppStyles.primaryColor, width: 0.5),
//                             ),
//                           ),
//                           onPressed: () => Navigator.of(context).pop(false),
//                           child: Text(
//                             'Cancel',
//                             style: AppStyles.headLineStyle3
//                                 .copyWith(color: AppStyles.primaryColor),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => Navigator.of(context).pop(true),
//                           label: Text(
//                             "Enable",
//                             style: AppStyles.headLineStyle3
//                                 .copyWith(color: AppStyles.whiteColor),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppStyles.primaryColor,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20)),
//                           ),
//                         ),
//                       ),
//                     ]),
//               ],
//             );
//           },
//         ) ??
//         false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Notification Settings", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//               color: AppStyles.primaryColor,
//             ))
//           : ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               children: [
//                 Card(
//                   color: AppStyles.whiteColor.withOpacity(0.7),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.notifications,
//                                 color: AppStyles.primaryColor),
//                             const SizedBox(width: 12),
//                             Text('Push Notifications',
//                                 style: AppStyles.headLineStyle3),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                             'Receive notifications about your orders, shipping updates, and special offers.',
//                             style: AppStyles.textStyle),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Enable Notifications',
//                               style: AppStyles.headLineStyle4
//                                   .copyWith(color: AppStyles.blackColor),
//                             ),
//                             Platform.isIOS
//                                 ? CupertinoSwitch(
//                                     value: _notificationsEnabled,
//                                     onChanged: _toggleNotifications,
//                                   )
//                                 : Switch(
//                                     activeColor: AppStyles.primaryColor,
//                                     value: _notificationsEnabled,
//                                     onChanged: _toggleNotifications,
//                                   ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (_notificationsEnabled) ...[
//                   Card(
//                     color: AppStyles.whiteColor.withOpacity(0.7),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Notification Types',
//                               style: AppStyles.headLineStyle3),
//                           const SizedBox(height: 12),
//                           _buildNotificationTypeItem(
//                             icon: Icons.local_shipping,
//                             title: 'Order Updates',
//                             subtitle:
//                                 'Get notified when your order status changes',
//                             enabled: true,
//                           ),
//                           _buildNotificationTypeItem(
//                             icon: Icons.card_giftcard,
//                             title: 'Special Offers',
//                             subtitle:
//                                 'Receive notifications about deals and promotions',
//                             enabled: true,
//                           ),
//                           _buildNotificationTypeItem(
//                             icon: Icons.announcement,
//                             title: 'Announcements',
//                             subtitle: 'Important updates and news',
//                             enabled: true,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Card(
//                     color: AppStyles.whiteColor.withOpacity(0.7),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Notification Info',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             '✓ Notifications are enabled\n'
//                             '✓ You will receive order updates\n'
//                             '✓ Push notifications are active',
//                             style: TextStyle(
//                               color: AppStyles.primaryColor,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   Card(
//                     color: AppStyles.whiteColor.withOpacity(0.7),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Why Enable Notifications?',
//                               style: AppStyles.headLineStyle3),
//                           const SizedBox(height: 12),
//                           Text(
//                               '• Stay updated on your order status\n'
//                               '• Get instant shipping notifications\n'
//                               '• Never miss special offers\n'
//                               '• Receive important announcements',
//                               style: AppStyles.textStyle),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//     );
//   }

//   Widget _buildNotificationTypeItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool enabled,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon,
//               color: enabled ? AppStyles.primaryColor : AppStyles.greColor),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: AppStyles.headLineStyle4
//                         .copyWith(color: AppStyles.blackColor)),
//                 Text(subtitle, style: AppStyles.textStyle),
//               ],
//             ),
//           ),
//           Icon(
//             enabled ? Icons.check_circle : Icons.radio_button_unchecked,
//             color: enabled ? AppStyles.primaryColor : AppStyles.greColor,
//             size: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }


// lib/screens/notification_settings_screen.dart



class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationController _controller = Get.find<NotificationController>();
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final localEnabled = await PushNotificationService.instance.areNotificationsEnabled();
      final backendEnabled = await _getBackendNotificationPreference();
      final actualEnabled = backendEnabled ?? localEnabled;

      setState(() {
        _isLoading = false;
      });

      if (localEnabled != actualEnabled) {
        await PushNotificationService.instance.setNotificationEnabled(actualEnabled);
        if (!actualEnabled) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
        }
      }

      _controller.notificationPreferences['push_notifications_enabled'] = actualEnabled;
      _controller.notificationPreferences.refresh();
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _getBackendNotificationPreference() async {
    try {
      final url = Uri.parse('$baseUrl/notifications/preferences/');
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      print('GET response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['push_notifications_enabled'] as bool?;
      } else {
        print('Failed to get backend notification preference: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting backend notification preference: $e');
      return null;
    }
  }

  Future<bool> _updateBackendNotificationPreference(bool enabled) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/preferences/');
      final headers = await AuthService.instance.getAuthHeaders();
      final body = json.encode({'push_notifications_enabled': enabled});

      print('Sending PATCH to $url with headers: $headers, body: $body');

      final response = await http.patch(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        print('Backend notification preference updated successfully to: $enabled');
        return true;
      } else {
        print('Failed to update backend notification preference: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating backend notification preference: $e');
      return false;
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isSyncing = true;
    });

    try {
      if (value) {
        final confirmed = await _showEnableNotificationDiaprint();
        if (confirmed) {
          final success = await PushNotificationService.instance.enableNotifications();
          if (success) {
            final backendSuccess = await _updateBackendNotificationPreference(true);
            if (backendSuccess) {
              setState(() {
                _controller.notificationPreferences['push_notifications_enabled'] = true;
              });
              showSuccessSnackbar('Notifications enabled successfully!');
            } else {
              await PushNotificationService.instance.setNotificationEnabled(false);
              showFailureSnackbar('Failed to sync with server. Please try again.');
            }
          } else {
            showFailureSnackbar('Failed to enable notifications. Please check your permissions.');
          }
        }
      } else {
        await PushNotificationService.instance.setNotificationEnabled(false);
        final backendSuccess = await _updateBackendNotificationPreference(false);
        if (backendSuccess) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
          setState(() {
            _controller.notificationPreferences['push_notifications_enabled'] = false;
          });
          showSuccessSnackbar('Notifications disabled');
        } else {
          await PushNotificationService.instance.setNotificationEnabled(true);
          setState(() {
            _controller.notificationPreferences['push_notifications_enabled'] = true;
          });
          showFailureSnackbar('Failed to sync with server. Please try again.');
        }
      }
    } catch (e) {
      print('Error toggling notifications: $e');
      await _loadNotificationSettings();
      showFailureSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _toggleNotificationType(String type, bool value) async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _controller.toggleNotificationType(type, value);
      showSuccessSnackbar('$type notifications ${value ? 'enabled' : 'disabled'}');
    } catch (e) {
      showFailureSnackbar('Failed to update $type notifications');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<bool> _showEnableNotificationDiaprint() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enable Notifications', style: AppStyles.headLineStyle2),
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
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                          backgroundColor: WidgetStateProperty.all(AppStyles.primaryColor.withOpacity(0.1)),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          side: WidgetStateProperty.all(BorderSide(color: AppStyles.primaryColor, width: 0.5)),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel', style: AppStyles.headLineStyle3.copyWith(color: AppStyles.primaryColor)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        label: Text("Enable", style: AppStyles.headLineStyle3.copyWith(color: AppStyles.whiteColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notificationsEnabled = _controller.notificationPreferences['push_notifications_enabled'] ?? false;
      final orderUpdatesEnabled = _controller.notificationPreferences['order_updates'] ?? true;
      final promotionsEnabled = _controller.notificationPreferences['promotions'] ?? true;
      final announcementsEnabled = _controller.notificationPreferences['announcements'] ?? true;

      return Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Notification Settings", style: AppStyles.headLineStyle2),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppStyles.primaryColor))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Card(
                    color: AppStyles.whiteColor.withOpacity(0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications, color: AppStyles.primaryColor),
                              const SizedBox(width: 12),
                              Text('Push Notifications', style: AppStyles.headLineStyle3),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Receive notifications about your orders, shipping updates, and special offers.',
                            style: AppStyles.textStyle,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Enable Notifications',
                                style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor),
                              ),
                              _isSyncing
                                  ? CircularProgressIndicator(color: AppStyles.primaryColor)
                                  : Platform.isIOS
                                      ? CupertinoSwitch(
                                          value: notificationsEnabled,
                                          onChanged: _toggleNotifications,
                                        )
                                      : Switch(
                                          activeColor: AppStyles.primaryColor,
                                          value: notificationsEnabled,
                                          onChanged: _toggleNotifications,
                                        ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (notificationsEnabled) ...[
                    Card(
                      color: AppStyles.whiteColor.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification Types', style: AppStyles.headLineStyle3),
                            const SizedBox(height: 12),
                            _buildNotificationTypeItem(
                              icon: Icons.local_shipping,
                              title: 'Order Updates',
                              subtitle: 'Get notified when your order status changes',
                              enabled: orderUpdatesEnabled,
                              onChanged: (value) => _toggleNotificationType('order_updates', value),
                            ),
                            _buildNotificationTypeItem(
                              icon: Icons.card_giftcard,
                              title: 'Special Offers',
                              subtitle: 'Receive notifications about deals and promotions',
                              enabled: promotionsEnabled,
                              onChanged: (value) => _toggleNotificationType('promotions', value),
                            ),
                            _buildNotificationTypeItem(
                              icon: Icons.announcement,
                              title: 'Announcements',
                              subtitle: 'Important updates and news',
                              enabled: announcementsEnabled,
                              onChanged: (value) => _toggleNotificationType('announcements', value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AppStyles.whiteColor.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification Info', style: AppStyles.headLineStyle3),
                            const SizedBox(height: 12),
                            Text(
                              '✓ Notifications are enabled\n'
                              '✓ Order updates: ${orderUpdatesEnabled ? 'On' : 'Off'}\n'
                              '✓ Special offers: ${promotionsEnabled ? 'On' : 'Off'}\n'
                              '✓ Announcements: ${announcementsEnabled ? 'On' : 'Off'}',
                              style: TextStyle(color: AppStyles.primaryColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: AppStyles.whiteColor.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Why Enable Notifications?', style: AppStyles.headLineStyle3),
                            const SizedBox(height: 12),
                            Text(
                              '• Stay updated on your order status\n'
                              '• Get instant shipping notifications\n'
                              '• Never miss special offers\n'
                              '• Receive important announcements',
                              style: AppStyles.textStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      );
    });
  }

  Widget _buildNotificationTypeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: enabled ? AppStyles.primaryColor : AppStyles.greColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor)),
                Text(subtitle, style: AppStyles.textStyle),
              ],
            ),
          ),
          _isSyncing
              ? CircularProgressIndicator(color: AppStyles.primaryColor)
              : Platform.isIOS
                  ? CupertinoSwitch(
                      value: enabled,
                      onChanged: onChanged,
                    )
                  : Switch(
                      activeColor: AppStyles.primaryColor,
                      value: enabled,
                      onChanged: onChanged,
                    ),
        ],
      ),
    );
  }
}