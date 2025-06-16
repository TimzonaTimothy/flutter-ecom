import 'package:ecom_app/auth/views/sign_in.dart';
import 'package:flutter/material.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';

class SignUpSreen extends StatefulWidget {
  const SignUpSreen({super.key});

  @override
  State<SignUpSreen> createState() => _SignUpSreenState();
}

class _SignUpSreenState extends State<SignUpSreen> {
  bool isChecked = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
                  bigText: 'Name',
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name must contain only letters';
                    }
                    return null;
                  },
                  controller: nameController,
                  hintText: "John Doe",
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
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Checkbox(
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
                      onTap: () {},
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
                PrimaryButton(
                  verticalPadding: 10,
                  horizontalPadding: 130,
                  text: 'Sign Up',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      if (!isChecked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "You must agree to the Terms & Conditions")),
                        );
                        return;
                      }
                    }
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
                        "Already have an account? ",
                        style: AppStyles.textStyle.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()),
                          );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
