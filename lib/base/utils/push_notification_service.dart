import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/service/auth_service.dart';
import '../res/base_url.dart';

// Inputs to accept for the push notifications
// https://www.youtube.com/watch?v=OHFyGRLfKxo
// https://www.youtube.com/watch?v=uKz8tWbMuUw

// Firebase configuration file lib\firebase_options.dart generated successfully with the following Firebase apps:

// Platform  Firebase App Id
// web       1:689947014186:web:6e3fa0136cdeaaa0457f53
// android   1:689947014186:android:c3ba824dbdad0aef457f53
// ios       1:689947014186:ios:5094f14ee8afe2fe457f53
// macos     1:689947014186:ios:5094f14ee8afe2fe457f53
// windows   1:689947014186:web:5ee299cd5b086ad4457f53

// for Android:
//   Android package name (hint: com.company.appname)
//   google-services.json

// for ios:
//   Apple bundle ID (hint: com.company.appname)
//   GoogleServices-info.plist

// Pre-requisites Before Renaming
// Before we perform a package rename, it's critical to have a clean slate to start from and ensure nothing's lost in translation. Here's what you need to do:

// Backup Your Project: Always start by creating a backup of your entire Flutter project. It never hurts to play it safe.

// Check Your Current Package Name: Use the command mentioned earlier to verify your current package name so that you know what you're changing from.

// Close Your IDE: If you have your project open in an IDE like Android Studio, it's best to close it to prevent file access conflicts.

// Clean Your Flutter Build: Run the following command to clear out old build files:

// flutter clean

// Fetch and Update Packages: Ensure you have the latest packages by running:
// flutter pub get

// necessary configurations
// for android: google-services.json
// path => project/android/app/google-services.json

// for ios: GoogleServices-info.plist
// path => project/ios/Runner/GoogleServices-info.plist

// make sure the bundle id matches with bundle identifier

// changing of platform package name | bundle id
// for android
// reference: https://www.dhiwise.com/post/flutter-change-package-name-essentials-for-flutter-developers
// For Android, navigate to your android/app/src/main directory and look for the AndroidManifest.xml file. This file contains the package attribute you need to modify.
// <manifest xmlns:android="http://schemas.android.com/apk/res/android"
// package="your.new.package.name">

// Don't forget to update the 'applicationId' in your build.gradle file located at android/app to reflect your new package name:
// android {
// ...
// defaultConfig {
//     ...
//     applicationId "your.new.package.name"
//     ...
//   }
// }

// for ios
// To change bundle id
// 1. Adding the rename dependency to your pubspec.yaml file
// 2. Running flutter pub get
// 3. Running flutter pub run rename --bundleId your.new.package.name
// 4. Searching for CFBundleIdentifier in your IDE and replacing its value with the new bundle ID
// 5. Running the flutter clean command in the terminal

// How to use Flutter Package Rename Tool for automated Package Name Change
// video reference: https://youtu.be/vyhxHlx8bik?si=bieXvX1fxJG-dAjB
// First, you'll need to add the rename dependency to your pubspec.yaml file:
// dev_dependencies:
//   rename: ^3.0.2

// Next, save the file and run:
// flutter pub get
// This command installs the package. Now, use a single command to change the package name:
// flutter pub run rename --bundleId your.new.package.name

// Common Issues and Troubleshooting
// Even with the most detailed instructions, changing package name of your Flutter app can sometimes lead to issues. Here are some common problems and their solutions:

// • Build Failures: After a rename, if your project refuses to build, double-check all paths and identifiers. For Android, sync your project with Gradle files. For iOS, ensure that the Bundle Identifier in Xcode matches the new name.

// • Missed Files: Did you use the global search to hunt down every instance of the old package name? Sometimes, a few might slip through the cracks. Run a global search for the old package name in your IDE to catch these stragglers.

// • Android Studio Refactoring: If you've used Android Studio's refactoring tool, ensure it didn't miss any directories or XML attributes, as these are crucial.

// • Dart File Imports: After changing the directory structure, verify that the import paths in your Dart files reflect the new package name. Broken imports will halt your project quickly.

// • Version Control Conflicts: If you're using version control like Git, renaming might lead to a large number of changes. Always rename in a separate branch to avoid disrupting the main development line.

// • Mismatched Configuration: Make sure your pubspec.yaml and Info.plist (for iOS) reflect the new settings. A mismatch here can lead to inconsistent app behavior.

// class PushNotificationService {
//   static final PushNotificationService _instance = PushNotificationService._();
//   static PushNotificationService get instance => _instance;
//   PushNotificationService._();

//   final _firebase = FirebaseMessaging.instance;
//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   // Channel IDs
//   static const String _highImportanceChannelId = 'high_importance_channel';
//   static const String _generalChannelId = 'general_channel';

//   // Notification sound file names
//   static const String _androidSoundFile = 'benji4';
//   static const String _iosSoundFile = 'benji4';

//   /// Initialize notification services
//   Future<void> initialize({
//     required Function(String) onTokenRefresh,
//     required String userId,
//     required Future<void> Function(String token) updateTokenCallback,
//   }) async {
//     try {
//       await _requestPermissions();
//       await _setupLocalNotifications();
//       await _setupMessagingListeners();
//       await _setupFCMToken(userId, updateTokenCallback);

//       _setupTokenRefreshListener(onTokenRefresh);
//     } catch (e) {
//       log('Error initializing push notifications: $e');
//       rethrow;
//     }
//   }

//   /// Request notification permissions
//   Future<void> _requestPermissions() async {
//     try {
//       await _firebase.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         announcement: false,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//       );

//       // Request permission for iOS foreground notifications
//       if (Platform.isIOS) {
//         await _firebase.setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//       }
//     } catch (e) {
//       log('Error requesting permissions: $e');
//       rethrow;
//     }
//   }

//   /// Setup local notifications
//   Future<void> _setupLocalNotifications() async {
//     try {
//       const androidSettings =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//       const iosSettings = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );

//       await _localNotifications.initialize(
//         const InitializationSettings(
//             android: androidSettings, iOS: iosSettings),
//         onDidReceiveNotificationResponse: _handleNotificationTap,
//       );

//       // Create Android notification channels
//       // await _createNotificationChannels();
//     } catch (e) {
//       log('Error setting up local notifications: $e');

//     }
//   }

//   /// Setup FCM token and subscribe to topics
//   Future<void> _setupFCMToken(
//     String userId,
//     Future<void> Function(String token) updateTokenCallback,
//   ) async {
//     try {
//       final token = await _firebase.getToken();
//       if (token != null) {
//         await updateTokenCallback(token);
//         await _firebase.subscribeToTopic('benji-vendor');
//       }
//     } catch (e) {
//       log('Error setting up FCM token: $e');

//     }
//   }

//   /// Setup token refresh listener
//   void _setupTokenRefreshListener(Function(String) onTokenRefresh) {
//     FirebaseMessaging.instance.onTokenRefresh.listen((token) {
//       onTokenRefresh(token);
//     });
//   }

//   /// Setup message listeners for different app states
//   Future<void> _setupMessagingListeners() async {
//     // Terminated state
//     final initialMessage = await _firebase.getInitialMessage();
//     if (initialMessage != null) {
//       await _handleMessage(initialMessage);
//     }

//     // Foreground state
//     FirebaseMessaging.onMessage.listen(_handleMessage);

//     // Background state
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//   }

//   /// Handle incoming messages
//   Future<void> _handleMessage(RemoteMessage message) async {
//     try {
//       if (message.notification != null) {
//         await showNotification(
//           title: message.notification?.title ?? '',
//           body: message.notification?.body ?? '',
//           imageAndroid: message.notification?.android?.imageUrl,
//           imageIOS: message.notification?.apple?.imageUrl,
//           data: message.data,
//         );
//       }
//     } catch (e) {
//       log('Error handling message: $e');
//     }
//   }

//   /// Handle notification taps
//   void _handleNotificationTap(NotificationResponse response) {
//     // Add your notification tap handling logic here
//     log('Notification tapped: ${response.payload}');
//   }

//   /// Show local notification
//   Future<void> showNotification({
//     required String title,
//     required String body,
//     String? imageAndroid,
//     String? imageIOS,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       BigPictureStyleInformation? bigPictureStyleInformation;

//       if (imageAndroid != null) {
//         final bytes = await _getImageBytes(imageAndroid);
//         final filePath = await _saveImageToFile(bytes);
//         bigPictureStyleInformation = BigPictureStyleInformation(
//           FilePathAndroidBitmap(filePath),
//           contentTitle: title,
//           summaryText: body,
//           // largeIcon: FilePathAndroidBitmap(filePath),
//         );
//       }

//       final androidDetails = AndroidNotificationDetails(
//         _highImportanceChannelId,
//         'High Importance Notifications',
//         channelDescription: 'This channel is used for important notifications.',
//         importance: Importance.high,
//         priority: Priority.high,
//         styleInformation: bigPictureStyleInformation,
//         sound: const RawResourceAndroidNotificationSound(_androidSoundFile),
//         icon: 'notificationicon',
//       );

//       List<DarwinNotificationAttachment>? iosAttachments;
//       if (imageIOS != null) {
//         try {
//           iosAttachments = [DarwinNotificationAttachment(imageIOS)];
//         } catch (e) {
//           log('Error creating iOS attachment: $e');
//         }
//       }

//       final iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//         sound: _iosSoundFile,
//         attachments: iosAttachments,
//       );

//       await _localNotifications.show(
//         DateTime.now().millisecond, // Unique ID for each notification
//         title,
//         body,
//         NotificationDetails(android: androidDetails, iOS: iosDetails),
//         payload: data?.toString(),
//       );
//     } catch (e) {
//       log('Error showing notification: $e');

//     }
//   }

//   /// Get image bytes from URL
//   Future<Uint8List> _getImageBytes(String imageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         return response.bodyBytes;
//       }
//       throw Exception('Failed to load image: ${response.statusCode}');
//     } catch (e) {
//       log('Error downloading image: $e');
//       rethrow;
//     }
//   }

//   /// Save image to local storage
//   Future<String> _saveImageToFile(Uint8List bytes) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final fileName =
//           'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final filePath = '${directory.path}/$fileName';

//       await File(filePath).writeAsBytes(bytes);
//       return filePath;
//     } catch (e) {
//       log('Error saving image: $e');
//       rethrow;
//     }
//   }
// }

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  static PushNotificationService get instance => _instance;
  PushNotificationService._();

  final _firebase = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String _highImportanceChannelId = 'high_importance_channel';
  static const String _generalChannelId = 'general_channel';

  // Notification sound file names
  static const String _androidSoundFile = 'benji4';
  static const String _iosSoundFile = 'benji4';

  // SharedPreferences keys
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _fcmTokenKey = 'fcm_token';

  /// Check if notifications are enabled by user
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  /// Set notification preference
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);

    if (enabled) {
      await enableNotifications();
    } else {
      await disableNotifications();
    }
  }

  /// Enable notifications - request permissions and setup
  Future<bool> enableNotifications() async {
    try {
      // Request permissions first
      final granted = await _requestPermissions();
      if (!granted) {
        log('Notification permissions not granted');
        return false;
      }

      await _setupLocalNotifications();
      await _createNotificationChannels();
      await _setupMessagingListeners();

      // Get and store FCM token
      final token = await _firebase.getToken();
      if (token != null) {
        await _storeFCMToken(token);
        await _firebase.subscribeToTopic('benji-vendor');
        log('Subscribed to notifications with token: $token');
      }

      // Set enabled in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, true);

      return true;
    } catch (e) {
      log('Error enabling notifications: $e');
      return false;
    }
  }

  /// Disable notifications
  Future<void> disableNotifications() async {
    try {
      // Unsubscribe from topics
      await _firebase.unsubscribeFromTopic('benji-vendor');

      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, false);
      await prefs.remove(_fcmTokenKey);

      log('Notifications disabled');
    } catch (e) {
      log('Error disabling notifications: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    if (await areNotificationsEnabled()) {
      return await _firebase.getToken();
    }
    return null;
  }

  /// Initialize notification services (called once at app start)
  Future<void> initialize({
    required Function(String) onTokenRefresh,
    required String userId,
    required Future<void> Function(String token) updateTokenCallback,
  }) async {
    try {
      // Check if user has enabled notifications
      if (await areNotificationsEnabled()) {
        await enableNotifications();
        _setupTokenRefreshListener(onTokenRefresh, updateTokenCallback);
      }
    } catch (e) {
      log('Error initializing push notifications: $e');
    }
  }

  /// Store FCM token locally and send to server
  Future<void> _storeFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);

    // TODO: Send token to your backend server
    await _sendTokenToServer(token);
  }

  Future<void> _sendTokenToServer(String token) async {
    const fullUrl = baseUrl;

    final url = Uri.parse('$fullUrl/notifications/fcm/register/token/');

    final headers = await AuthService.instance.getAuthHeaders();

    final body = json.encode({'token': token});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      print('FCM token registered successfully on backend');
    } else {
      print(
          'Failed to register FCM token: ${response.statusCode} - ${response.body}');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      final settings = await _firebase.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (isGranted && Platform.isIOS) {
        await _firebase.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      log('Notification permission status: ${settings.authorizationStatus}');
      return isGranted;
    } catch (e) {
      log('Error requesting permissions: $e');
      return false;
    }
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _localNotifications.initialize(
        const InitializationSettings(
            android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      log('Local notifications initialized');
    } catch (e) {
      log('Error setting up local notifications: $e');
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      try {
        const AndroidNotificationChannel highImportanceChannel =
            AndroidNotificationChannel(
          _highImportanceChannelId,
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(_androidSoundFile),
        );

        const AndroidNotificationChannel generalChannel =
            AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'This channel is used for general notifications.',
          importance: Importance.defaultImportance,
        );

        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(highImportanceChannel);

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(generalChannel);

        log('Notification channels created');
      } catch (e) {
        log('Error creating notification channels: $e');
      }
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener(
      Function(String) onTokenRefresh, Function(String) updateTokenCallback) {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        if (await areNotificationsEnabled()) {
          log('FCM Token refreshed: $token');
          await _storeFCMToken(token);
          await updateTokenCallback(token);
          onTokenRefresh(token);
        }
      });
    } catch (e) {
      log('Error setting up token refresh listener: $e');
    }
  }

  /// Setup message listeners for different app states
  Future<void> _setupMessagingListeners() async {
    try {
      // Terminated state
      final initialMessage = await _firebase.getInitialMessage();
      if (initialMessage != null) {
        log('App opened from terminated state via notification');
        await _handleMessage(initialMessage);
      }

      // Foreground state
      FirebaseMessaging.onMessage.listen((message) async {
        if (await areNotificationsEnabled()) {
          log('Received message in foreground: ${message.notification?.title}');
          _handleMessage(message);
        }
      });

      // Background state
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (await areNotificationsEnabled()) {
          log('App opened from background via notification');
          _handleMessage(message);
        }
      });

      log('Message listeners setup complete');
    } catch (e) {
      log('Error setting up messaging listeners: $e');
    }
  }

  /// Handle incoming messages
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (!await areNotificationsEnabled()) return;

      log('Handling message: ${message.notification?.title}');

      if (message.notification != null) {
        await showNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          imageAndroid: message.notification?.android?.imageUrl,
          imageIOS: message.notification?.apple?.imageUrl,
          data: message.data,
        );
      }
    } catch (e) {
      log('Error handling message: $e');
    }
  }

  /// Handle notification taps
  void _handleNotificationTap(NotificationResponse response) {
    try {
      log('Notification tapped: ${response.payload}');
      // Add your notification tap handling logic here
      // For example, navigate to a specific screen based on the payload
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? imageAndroid,
    String? imageIOS,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await areNotificationsEnabled()) return;

      BigPictureStyleInformation? bigPictureStyleInformation;

      // Handle Android image
      if (imageAndroid != null && Platform.isAndroid) {
        try {
          final bytes = await _getImageBytes(imageAndroid);
          final filePath = await _saveImageToFile(bytes);
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            contentTitle: title,
            summaryText: body,
          );
        } catch (e) {
          log('Error loading Android image: $e');
        }
      }

      final androidDetails = AndroidNotificationDetails(
        _highImportanceChannelId,
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
        sound: const RawResourceAndroidNotificationSound(_androidSoundFile),
        icon: 'notificationicon',
      );

      List<DarwinNotificationAttachment>? iosAttachments;
      if (imageIOS != null && Platform.isIOS) {
        try {
          iosAttachments = [DarwinNotificationAttachment(imageIOS)];
        } catch (e) {
          log('Error creating iOS attachment: $e');
        }
      }

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _iosSoundFile,
        attachments: iosAttachments,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: data?.toString(),
      );

      log('Notification shown: $title');
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  /// Get image bytes from URL
  Future<Uint8List> _getImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception('Failed to load image: ${response.statusCode}');
    } catch (e) {
      log('Error downloading image: $e');
      rethrow;
    }
  }

  /// Save image to local storage
  Future<String> _saveImageToFile(Uint8List bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$fileName';

      await File(filePath).writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      log('Error saving image: $e');
      rethrow;
    }
  }
}
