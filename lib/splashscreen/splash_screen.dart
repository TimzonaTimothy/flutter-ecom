import 'package:ecom_app/onboarding/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/service/auth_service.dart';
import '../base/bottom_nav_bar.dart';
import '../base/res/media.dart';
import '../base/res/styles/app_styles.dart';
import '../base/utils/app_routes.dart';
import '../base/utils/push_notification_service.dart';
import '../base/utils/token.dart';
import '../base/utils/wrapper.dart';

// import '../onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Show splash for minimum 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Retrieve user ID from AuthService
      final userId = await AuthService.instance.getUserId();
      print('Retrieved user ID: $userId');

      // Initialize push notifications if user ID is available
      if (userId != null) {
        await PushNotificationService.instance.initialize(
          userId: userId,
          updateTokenCallback: (String token) async {
            print('FCM Token updated: $token');
          },
          onTokenRefresh: (String token) {
            print('FCM Token refreshed: $token');
          },
        );
      } else {
        print('No user ID found, skipping push notification initialization');
      }

      // Check if user has completed onboarding
      final hasSeenOnboarding = await _hasSeenOnboarding();

      if (!hasSeenOnboarding) {
        // First-time user - show onboarding
        Get.offAll(
          () => const OnboardingScreen(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        // User has seen onboarding - go to main app
        Get.offAll(
          () => const AppWrapper(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Fallback navigation to onboarding screen
      Get.offAll(
        () => const OnboardingScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 500),
      );
    }
  }
  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: ClipRRect(
        child: Center(
          // child: SvgPicture.asset(AppMedia.logo),
          child: Container(
            height: 100,
            width: 100,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(AppMedia.logo))),
          ),
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.toNamed(RouteNames.onboardingPage);
  }
}
