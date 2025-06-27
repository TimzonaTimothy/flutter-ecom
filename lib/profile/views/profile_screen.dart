import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../home/views/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Profile", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
           onPressed: () {
            Get.to(
              const HomeScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/300",
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppStyles.primaryColor,
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Esther Howard",
              style: AppStyles.headLineStyle2,
            ),
            const SizedBox(height: 30),
            _buildListTile(Icons.person_outline, "Your profile", (){}),
            // _buildListTile(Icons.credit_card, "Payment Methods", (){}),
            _buildListTile(Icons.shopping_bag_outlined, "My Orders", (){}),
            _buildListTile(Icons.settings_outlined, "Settings", (){}),
             _buildListTile(Icons.notifications, "Notification", (){}),
              _buildListTile(Icons.password, "Password Manager", (){}),
            _buildListTile(Icons.help_outline, "Help Center", (){}),
            _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy", (){}),
            _buildListTile(Icons.group_outlined, "Invites Friends", (){}),
            _buildListTile(Icons.logout, "Log out", (){}),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 2),
            leading: Icon(icon, color: AppStyles.primaryColor),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle navigation
            },
          ),
          Divider(height: 0, color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}
