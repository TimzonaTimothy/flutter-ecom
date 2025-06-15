import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../base/res/media.dart';
import '../base/res/styles/app_styles.dart';
import '../base/utils/app_routes.dart';

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
    redirect();
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
