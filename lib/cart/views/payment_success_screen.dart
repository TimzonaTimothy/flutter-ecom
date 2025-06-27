import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF7B4F27), // Match your theme color
            child: Icon(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to order details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B4F27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("View Order", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // View E-Receipt logic
              },
              child: const Text(
                "View E-Receipt",
                style: TextStyle(color: Color(0xFF7B4F27)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
