import 'package:ecom_app/auth/views/sign_in.dart';
import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import '../service/forgot_password_service.dart';


class ResetPasswordScreen extends StatefulWidget {
  final String email;
  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    setState(() => isLoading = true);
    final result = await PasswordResetService.confirmPasswordReset(
      email: widget.email,
      otp: otpController.text,
      newPassword: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    setState(() => isLoading = false);

    if (result["status"] == 200) {
      String msg = result["data"]["detail"] ?? "Password reset successful";
      showSuccessSnackbar(msg);
      
      Get.offAll(
          () => const SignInScreen(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
    } else {
      String msgEr = result["data"]["detail"] ?? "Error occurred";
      showFailureSnackbar(msgEr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: AppStyles.headLineStyle2,
        ),
        centerTitle: true,
        backgroundColor: AppStyles.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            const AppDoubleText(
                  bigText: 'OTP',
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your otp code';
                    }
                    if (!RegExp(r'^[0-9\s]+$').hasMatch(value.trim())) {
  return 'Field must contain only numbers and spaces';
}

                    return null;
                  },
                  controller: otpController,
                  hintText: "1234",
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
                  validator: (value) => value == null || value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  controller: confirmPasswordController,
                  hintText: "Password",
                  obscureText: true,
                ),
            
            SizedBox(height: 25),
            isLoading
                ? CircularProgressIndicator()
                : PrimaryButton(
                    verticalPadding: 10,
                    horizontalPadding: 10,
                    text: 'Reset Password',
                    
                    onTap: _resetPassword),
                
                
          ],
        ),
      ),
    );
  }
}
