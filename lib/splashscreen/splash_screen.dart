import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../base/bottom_nav_bar.dart';
import '../base/res/media.dart';
import '../base/res/styles/app_styles.dart';
import '../base/utils/app_routes.dart';
import '../base/utils/token.dart';

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
    Future.delayed(const Duration(seconds: 2), () async {
      await verifyTokenAndNavigate();
    });
    // redirect();
  }


Future<void> verifyTokenAndNavigate() async {
    final token = getToken();

    if (token == null) {
      // Get.offAll(() => const SignInScreen()); 
       Get.toNamed(RouteNames.onboardingPage);
      return;
    }

    final isValid = await verifyTokenOnly(); // separated validation logic
    if (isValid) {
      Get.offAll(() => const BottomNavBar());
    } else {
      await removeToken();
      // Get.offAll(() => const SignInScreen()); 
       Get.toNamed(RouteNames.onboardingPage);
    }
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
