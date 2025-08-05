import 'package:ecom_app/onboarding/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base/bottom_nav_bar.dart';
import '../base/res/media.dart';
import '../base/res/styles/app_styles.dart';
import '../base/utils/app_routes.dart';
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
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user has completed onboarding
    final hasSeenOnboarding = await _hasSeenOnboarding();
    
    if (!hasSeenOnboarding) {
      // First time user - show onboarding
      Get.offAll(
        () => const OnboardingScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      // User has seen onboarding - check authentication
      Get.offAll(
        () =>  AppWrapper(),
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
