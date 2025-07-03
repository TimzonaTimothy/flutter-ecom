import 'package:ecom_app/auth/views/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';

class SignUpOtpCode extends StatelessWidget {
  const SignUpOtpCode({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Verify Code', style: AppStyles.headLineStyle1),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text('Please enter the code we just sent to email',
                  style: AppStyles.textStyle),
            ),
            Center(
              child: Text(
                'example@gmail.com',
                style: AppStyles.headLineStyle4
                    .copyWith(color: AppStyles.blackColor),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < 4; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: size.width * 0.15,
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                          ),
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
                child: Text("Didn't receive OTP?",
                    style: AppStyles.headLineStyle4)),
            const SizedBox(width: 4),
            Center(
                child: Text("Resend code",
                    style: AppStyles.headLineStyle4.copyWith(
                        color: AppStyles.primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppStyles.primaryColor))),
            SizedBox(height: size.height * 0.06),
            PrimaryButton(
              verticalPadding: 10,
              horizontalPadding: 100,
              hasBackground: true,
              text: 'Verify',
              onTap: () {
                Get.to(
                  const SignInScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
