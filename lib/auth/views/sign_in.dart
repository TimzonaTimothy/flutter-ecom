import 'package:ecom_app/auth/views/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import '../controllers/login.dart';
import 'forgot_password.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late LoginController loginController;

  @override
  void initState() {
    loginController = Get.put(LoginController());
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
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
                  keyboardType: TextInputType.emailAddress,
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
                  obscureText: true,
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
                        GetBuilder<LoginController>(
                          builder: (controller) {
                            return Checkbox(
                              activeColor: AppStyles.primaryColor,
                              checkColor: AppStyles.whiteColor,
                              value: controller.rememberMe.value,
                              onChanged: (bool? value) {
                                controller.toggleRememberMe(value ?? false);
                              },
                            );
                          },
                        ),
                        Text(
                          "Remember me",
                          style: AppStyles.textStyle,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ForgotPasswordScreen(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: AppStyles.textStyle
                            .copyWith(color: AppStyles.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                GetBuilder<LoginController>(
                  builder: (controller) {
                    return PrimaryButton(
                      verticalPadding: 10,
                      horizontalPadding: 10,
                      text: 'Sign In',
                      isLoading: controller.isLoad.value,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          loginController.loginUser(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            controller.rememberMe.value,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppStyles.textStyle.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            const SignUpSreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (_) => const SignUpSreen()),
                          // );
                        },
                        child: Text(
                          "Sign Up",
                          style: AppStyles.textStyle.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
