import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Privacy Policy", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          Text(
            "Privacy Policy",
            style: AppStyles.headLineStyle2
                .copyWith(color: AppStyles.primaryColor),
          ),
          const SizedBox(height: 10),
          const Text(
            "Effective Date: June 26, 2025\n",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            "At [Your App Name], your privacy is important to us. This Privacy Policy explains how we collect, use, and safeguard your data.",
            style: AppStyles.textStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("1. Information We Collect"),
          _buildBulletPoint("Personal info like name, email, and phone."),
          _buildBulletPoint("Device and usage data."),
          _buildBulletPoint("Location data, with your permission."),
          const SizedBox(height: 20),
          _buildSectionTitle("2. How We Use Your Information"),
          _buildBulletPoint("To personalize your experience."),
          _buildBulletPoint("To improve app performance."),
          _buildBulletPoint("To send notifications and updates."),
          const SizedBox(height: 20),
          _buildSectionTitle("3. Sharing Your Information"),
          _buildBulletPoint("We do not sell your data."),
          _buildBulletPoint("We may share with trusted third-party services."),
          const SizedBox(height: 20),
          _buildSectionTitle("4. Your Rights"),
          _buildBulletPoint("You can request access, correction, or deletion."),
          _buildBulletPoint("You may opt out of marketing communications."),
          const SizedBox(height: 20),
          _buildSectionTitle("5. Contact Us"),
          const Text(
            "If you have any questions, contact us at support@example.com.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "© 2025 Ecom App Name",
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppStyles.headLineStyle2.copyWith(color: AppStyles.primaryColor),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(
              child: Text(
            text,
            style: AppStyles.textStyle.copyWith(fontSize: 16),
          )),
        ],
      ),
    );
  }
}
