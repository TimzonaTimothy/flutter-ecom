import 'package:ecom_app/base/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_input.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Password Manager", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AppDoubleText(
                bigText: 'Current Password',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                controller: currentPasswordController,
                obscureText: true,
                hintText: "Password",
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Forgot Password?",
                    style: AppStyles.textStyle.copyWith(
                        color: AppStyles.primaryColor,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'New Password',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                controller: newPasswordController,
                obscureText: true,
                hintText: "Password",
              ),
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'Confrim New Password',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                controller: confirmNewPasswordController,
                obscureText: true,
                hintText: "Password",
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: PrimaryButton(
          text: "Change Password",
          onTap: () {},
          horizontalPadding: 10,
        ),
      ),
    );
  }
}
