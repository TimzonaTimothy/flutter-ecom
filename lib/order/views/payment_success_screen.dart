import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';
import 'track_order_screen.dart';
import 'reciept_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final String reference;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
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
            Get.to(() => const BottomNavBar(), transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),);
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
            // Text(
            //   "Order #$orderId paid via $paymentMethod",
            //   style: TextStyle(color: Colors.grey.shade600),
            // ),
            // Text(
            //   "Amount: \$${amount.toStringAsFixed(2)}",
            //   style: TextStyle(color: Colors.grey.shade600),
            // ),
            const SizedBox(height: 16),
            
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
                   TrackOrderPage(),
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
              
              backgroundColor: AppStyles.bgColor,
              textColor: AppStyles.primaryColor ,
              text: 'View E-Receipt',
              onTap: () {
                Get.to(
                   EReceiptScreen(),
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
