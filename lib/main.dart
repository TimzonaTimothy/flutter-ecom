import 'package:ecom_app/base/res/styles/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/service/auth_service.dart';
import 'base/utils/app_routes.dart';
import 'splashscreen/splash_screen.dart';
late SharedPreferences prefs;

// Add this background handler function BEFORE main()
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.notification?.title}');
  print('Background message data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restrict the app to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  print('Firebase initialized successfully');

  // Register the background message handler - ADD THIS LINE
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  prefs = await SharedPreferences.getInstance();

  Get.put(AuthService());

  runApp(const MyApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Restrict the app to portrait mode only
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     // Initialize Firebase first
//     await Firebase.initializeApp();
//     print('Firebase initialized successfully');

//     // Initialize SharedPreferences
//     prefs = await SharedPreferences.getInstance();

//     // Initialize push notifications after Firebase is ready
//     await PushNotificationService.instance.initialize(
//       userId: '0',
//       updateTokenCallback: (String token) async {
//         print('FCM Token updated: $token');
//         // Store token in SharedPreferences or send to your server
//         await prefs.setString('fcm_token', token);
//       },
//       onTokenRefresh: (String token) {
//         print('FCM Token refreshed: $token');
//         // Handle token refresh
//       },
//     );

//     runApp(MyApp());
//   } catch (e) {
//     print('Error during app initialization: $e');
//     // You might want to show an error screen or retry logic here
//     // runApp(ErrorApp(error: e.toString()));
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ecommerce',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.bgColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // initialRoute: SplashScreen(),
      home: const SplashScreen(),
      getPages: RouteNames.routes,
    );
  }
}
