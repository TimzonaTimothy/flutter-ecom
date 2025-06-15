import 'package:flutter/material.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    @override
    void dispose() {
      passwordController.dispose(); // Always dispose controllers
      super.dispose();
    }

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Center(
                child: Text(
                  'Welcome Back',
                  style: AppStyles.headLineStyle1.copyWith(
                    color: AppStyles.primaryColor,
                    fontSize: screenWidth * 0.07,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'Use your credentials below and login to your account',
                  style: AppStyles.textStyle.copyWith(
                      // color: AppStyles.whiteSmokeColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'Email',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
                controller: emailController,
                hintText: "Email",
              ),
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'Password',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                controller: passwordController,
                hintText: "Password",
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      Text(
                        "Remember me?",
                        style: AppStyles.textStyle,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: AppStyles.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 130,
                text: 'Sign In',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
