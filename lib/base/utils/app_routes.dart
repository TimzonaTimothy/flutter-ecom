import 'package:get/get.dart';

import '../../auth/views/sign_in.dart';
import '../../auth/views/sign_up.dart';
import '../../home/views/home_screen.dart';
import '../../onboarding/views/onboarding_screen.dart';
import '../../onboarding/views/welcome_screen.dart';
import '../../splashscreen/splash_screen.dart';

class RouteNames {
  static const String initial = "/";
  static const String splashPage = "/splash-page";
  static const String homePage = "/home-page";
  static const String onboardingPage = "/onboarding-Page";
  static const String welcomePage = "/welcome-page";
  static const String signInPage = "/sign-in-screen-page";
  static const String signUpPage = "/sign-up-screen-page";


  String getInitial() => initial;
  String getsplashPage() => splashPage;
  String gethomePage() => homePage;
  String getOnboardingPage() => onboardingPage;
  String getWelcomePage() => welcomePage;
  String getsignInPage() => signInPage;
  String getsignUpPage() => signUpPage;

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: splashPage, page: () => const SplashScreen()),
    GetPage(name: homePage, page: () => const HomeScreen()),
    GetPage(name: onboardingPage, page: () => const OnboardingScreen()),
    GetPage(name: welcomePage, page: () =>const WelcomeScreen()),
    GetPage(name: signInPage, page: () => const SignInScreen()),
    GetPage(name: signUpPage, page: () => const SignUpSreen()),
  ];
}
