import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';
import 'payment_success_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int selectedPaymentTypeIndex = 0;

  final List<Map<String, dynamic>> paymentTypes = [
    {
      "label": "PayStack",
      "icon": Icons.payment,
    },
    {
      "label": "PayPal",
      "icon": Icons.account_balance_wallet,
    },
    {
      "label": "Apple Pay",
      "icon": Icons.phone_iphone,
    },
    {
      "label": "Google Pay",
      "icon": Icons.android,
    },
    {
      "label": "Stripe",
      "icon": Icons.credit_card,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Shipping Type", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              itemCount: paymentTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return PaymentTypeCard(
                  label: paymentTypes[index]['label']!,
                  icon: paymentTypes[index]['icon'] as IconData,
                  isSelected: selectedPaymentTypeIndex == index,
                  onTap: () {
                    setState(() {
                      selectedPaymentTypeIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: PrimaryButton(
              verticalPadding: 10,
              horizontalPadding: 100,
              text: 'Confirm Payment',
              onTap: () {
                  Get.to(
                  const PaymentSuccessScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentTypeCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppStyles.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppStyles.headLineStyle3),
                    const SizedBox(height: 4),
                    // Text(estimated,
                    //     style: AppStyles.textStyle.copyWith(color: AppStyles.whiteSmokeColor)),
                  ],
                ),
              ),
              Radio(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppStyles.primaryColor,
              ),
              Divider(color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
            ],
          ),
          Divider(color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}
