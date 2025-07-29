import 'package:ecom_app/auth/controllers/register.dart';
import 'package:ecom_app/auth/views/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import 'sign_up_otp_code.dart';

class SignUpSreen extends StatefulWidget {
  const SignUpSreen({super.key});

  @override
  State<SignUpSreen> createState() => _SignUpSreenState();
}

class _SignUpSreenState extends State<SignUpSreen> {
  bool isChecked = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(RegisterController());
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                    'Create Account',
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
                    'Use your credentials below and register your account',
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
                  bigText: 'First Name',
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name must contain only letters';
                    }
                    return null;
                  },
                  controller: firstNameController,
                  hintText: "John",
                ),
                const SizedBox(
                  height: 20,
                ),
                const AppDoubleText(
                  bigText: 'Last Name',
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name must contain only letters';
                    }
                    return null;
                  },
                  controller: lastNameController,
                  hintText: "Doe",
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
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                const AppDoubleText(
                  bigText: 'Confirm Password',
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryInput(
                  validator: (value) => value != passwordController.text
                      ? 'Password must be same'
                      : null,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppStyles.primaryColor,
                          checkColor: AppStyles.whiteColor,
                          
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "Agree with ",
                          style: AppStyles.textStyle,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                            const SignUpOtpCode(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                          );
                      },
                      child: Text(
                        "Terms & Condition",
                        style: AppStyles.textStyle.copyWith(
                            color: AppStyles.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppStyles.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                GetBuilder<RegisterController>(
                  builder: (registerController) {
                    return PrimaryButton(
                      verticalPadding: 10,
                      horizontalPadding: 130,
                      text: 'Sign Up',
                      isLoading: registerController.isLoad.value,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          registerController.registerUser(
                            firstNameController.text.trim(),
                            lastNameController.text.trim(),
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            confirmPasswordController.text.trim(),
                          );
                        }
                      },
                    );
                  },
                ),
                // PrimaryButton(
                //   verticalPadding: 10,
                //   horizontalPadding: 130,
                //   text: 'Sign Up',
                //   onTap: () {
                //     if (_formKey.currentState!.validate()) {
                //       if (!isChecked) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //               content: Text(
                //                   "You must agree to the Terms & Conditions")),
                //         );
                //         return;
                //       }
                //     }
                //   },
                // ),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppStyles.textStyle.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            const SignInScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (_) => const SignInScreen()),
                          // );
                        },
                        child: Text(
                          "Sign In",
                          style: AppStyles.textStyle.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
