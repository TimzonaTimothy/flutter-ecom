import 'package:ecom_app/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/views/sign_in.dart';
import '../base/bottom_nav_bar.dart';
import '../base/res/media.dart';
import '../base/utils/app_routes.dart';
import '../base/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.06,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                   Get.to(() => const BottomNavBar());
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.black38, Colors.black87],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                blendMode: BlendMode.darken,
                child: Container(
                  height: screenHeight * 0.55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(AppMedia.welcomeImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: screenHeight * 0.008),
              Text(
                'Start Your Shopping Journey Now',
                style: AppStyles.headLineStyle1.copyWith(
                  color: AppStyles.whiteColor,
                  fontSize: screenWidth * 0.07,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.025),
              Text(
                'Start Your Shopping Journey Now Start Your Shopping Journey Now',
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.whiteColor,
                  fontSize: screenWidth * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              PrimaryButton(
                isBorder: true,
                verticalPadding: 10,
                horizontalPadding: 130,
                hasBackground: false,
                text: 'Sign In',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                  // Get.toNamed(RouteNames.signInPage);
                },
              ),
              SizedBox(height: screenHeight * 0.025),
              PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 130,
                text: 'Sign Up',
                onTap: () {
                  Get.toNamed(RouteNames.signUpPage);
                },
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
