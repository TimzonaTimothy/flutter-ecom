import 'package:ecom_app/base/res/styles/app_styles.dart';
import 'package:ecom_app/onboarding/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/utils/wrapper.dart';
import '../../base/widgets/primary_button.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    // auth check
    Get.offAll(
      () => const AppWrapper(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var content in contents) {
      precacheImage(AssetImage(content.image), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.black38, Colors.black87],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter)
                .createShader(bounds),
            blendMode: BlendMode.darken,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      // image: const AssetImage(AppMedia.onborading1),
                      image: AssetImage(contents[currentIndex].image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.red.withOpacity(0.2), BlendMode.darken))),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // SvgPicture.asset(
                          //   contents[i].image,
                          //   height: screenHeight * 0.4,
                          // ),
                          // SizedBox(height: screenHeight * 0.05),
                          Text(
                            contents[i].title,
                            style: AppStyles.headLineStyle1
                                .copyWith(color: AppStyles.whiteColor),
                            // overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            contents[i].discription,
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyle
                                .copyWith(color: AppStyles.whiteColor),
                            // overflow: TextOverflow.ellipsis,
                            maxLines: null,
                            softWrap: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                      // horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.04),
                  child: Column(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          contents.length,
                          (index) => buildDot(index, context),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: PrimaryButton(
                          verticalPadding: 10,
                          horizontalPadding: 130,
                          text: 'Next',
                          onTap: () {
                            if (currentIndex == contents.length - 1) {
                              _completeOnboarding();
                              Get.to(
                                const WelcomeScreen(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 500),
                              );
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.08),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? AppStyles.primaryColor
            : AppStyles.whiteColor,
      ),
    );
  }
}
