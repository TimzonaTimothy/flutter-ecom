import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Payment", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppStyles.primaryColor,
              child: const Icon(
                Icons.check,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Thank you for your purchase.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              verticalPadding: 10,
              horizontalPadding: 100,
              text: 'View Order',
              onTap: () {
                Get.to(
                  const (),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              isBorder: true,
              verticalPadding: 10,
              horizontalPadding: 80,
              hasBackground: false,
              text: 'View E-Receipt',
              onTap: () {
                Get.to(
                  const (),
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
