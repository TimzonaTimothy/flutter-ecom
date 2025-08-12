import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import '../service/forgot_password_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendOtp() async {
    setState(() => isLoading = true);
    final result =
        await PasswordResetService.requestPasswordReset(emailController.text);
    setState(() => isLoading = false);

    if (result["status"] == 200) {
      String msg = result["data"]["detail"] ?? "OTP sent";
      showSuccessSnackbar(msg);

      Get.to(
        () => ResetPasswordScreen(email: emailController.text),
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        title: Text(
          'Forgot Password',
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
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
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
              height: 25,
            ),
            isLoading
                ? CircularProgressIndicator(
                    color: AppStyles.primaryColor,
                  )
                : PrimaryButton(
                    verticalPadding: 10,
                    horizontalPadding: 10,
                    text: 'Send OTP',
                    onTap: _sendOtp),
          ],
        ),
      ),
    );
  }
}
