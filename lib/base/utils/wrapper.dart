import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/service/auth_service.dart';
import '../../auth/views/sign_in.dart';
import '../../onboarding/views/welcome_screen.dart';
import '../bottom_nav_bar.dart';
import '../res/styles/app_styles.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Give AuthService time to initialize if needed
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Force a check of authentication status
    await AuthService.instance.checkAuthenticationStatus();
    
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppStyles.bgColor,
        body: Center(
          child: CircularProgressIndicator(color: AppStyles.primaryColor,),
        ),
      );
    }

    return GetBuilder<AuthService>(
      builder: (authService) {
        if (authService.isAuthenticated) {
          return const BottomNavBar();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}