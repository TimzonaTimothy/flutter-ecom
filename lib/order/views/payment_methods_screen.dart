import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../base/widgets/primary_button.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/payment_controller.dart';
import 'payment_success_screen.dart';


class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int selectedPaymentTypeIndex = 0;
  late PaystackPaymentController paystackController;
  late FlutterwavePaymentController flutterwaveController;
  late StripePaymentController stripeController;

  final List<Map<String, dynamic>> paymentTypes = [
    {
      "label": "PayStack",
      "icon": Icons.payment,
      "description": "Pay with your card via PayStack",
    },
    {
      "label": "Flutterwave",
      "icon": Icons.account_balance_wallet,
      "description": "Pay with Flutterwave gateway",
    },
    {
      "label": "Stripe",
      "icon": Icons.credit_card,
      "description": "Pay with Stripe checkout",
    },
  ];

  @override
  void initState() {
    super.initState();
    paystackController = Get.put(PaystackPaymentController());
    flutterwaveController = Get.put(FlutterwavePaymentController());
    stripeController = Get.put(StripePaymentController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Payment Methods", style: AppStyles.headLineStyle2),
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
          // Payment Summary Section
          _buildPaymentSummary(),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: paymentTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return PaymentTypeCard(
                  label: paymentTypes[index]['label']!,
                  description: paymentTypes[index]['description']!,
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
          
          // Payment Button
          Obx(() {
            final isLoading = paystackController.isLoading.value ||
                flutterwaveController.isLoading.value ||
                stripeController.isLoading.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 80,
                text: isLoading ? 'Processing...' : 'Pay Now',
                isLoading: isLoading,
                onTap: isLoading ? null : _handlePaymentConfirmation,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final cartController = Get.find<CartController>();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Summary",
            style: AppStyles.headLineStyle3,
          ),
          const SizedBox(height: 12),
          
          Obx(() => Column(
            children: [
              _buildSummaryRow(
                "Items (${cartController.totalQuantity})",
                "\$${cartController.totalPrice.toStringAsFixed(2)}",
              ),
              const SizedBox(height: 8),
              _buildSummaryRow("Shipping", "\$5.00"),
              const SizedBox(height: 8),
              _buildSummaryRow("Tax", "\$2.50"),
              const Divider(),
              _buildSummaryRow(
                "Total",
                "\$${(cartController.totalPrice + 7.50).toStringAsFixed(2)}",
                isTotal: true,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppStyles.primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePaymentConfirmation() async {
    final cartController = Get.find<CartController>();
    try {
      // Show loading dialog
      _showLoadingDialog();

      // Create order
      final orderId = await paystackController.createOrder();
      if (orderId == null) {
        Get.back();
        String errorText = 'Error: ${paystackController.errorMessage.value}';
        showFailureSnackbar(errorText);
        
        return;
      }

      final selectedMethod = paymentTypes[selectedPaymentTypeIndex]['label'];
      bool success = false;

      // Select the appropriate controller
      switch (selectedMethod) {
        case 'PayStack':
          success = await paystackController.initiatePayment(
            amount: cartController.totalPrice + 7.50,
            orderId: orderId,
          );
          break;
        case 'Flutterwave':
          success = await flutterwaveController.initiatePayment(
            amount: cartController.totalPrice + 7.50,
            orderId: orderId,
          );
          break;
        case 'Stripe':
          success = await stripeController.initiatePayment(
            amount: cartController.totalPrice + 7.50,
            orderId: orderId,
          );
          break;
      }

      // Hide loading dialog
      Get.back();

      if (success) {
        await cartController.clearCart();
        showSuccessSnackbar('Your order has been placed successfully!',title: 'Payment Successful');
        
      } else {
        final errorMessage = selectedMethod == 'PayStack'
            ? paystackController.errorMessage.value
            : selectedMethod == 'Flutterwave'
                ? flutterwaveController.errorMessage.value
                : stripeController.errorMessage.value;
                String errorText = errorMessage.isNotEmpty ? errorMessage : 'Payment was cancelled or failed';
        showFailureSnackbar(errorText,title: 'Payment Failed');
        
      }
    } catch (e) {
      Get.back();
      String errorText = 'An unexpected error occurred: $e';
      showFailureSnackbar(errorText);
      
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
              ),
              const SizedBox(height: 16),
              const Text(
                'Processing Payment...',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please don\'t close the app',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    paystackController.clearPaymentData();
    flutterwaveController.clearPaymentData();
    stripeController.clearPaymentData();
    super.dispose();
  }
}

class PaymentTypeCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentTypeCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppStyles.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppStyles.primaryColor : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppStyles.primaryColor : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppStyles.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}