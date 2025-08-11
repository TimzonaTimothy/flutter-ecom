import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/service/logout_helper.dart';
import '../../base/res/styles/app_styles.dart';
import '../../order/views/my_orders_screen.dart';
import '../controllers/profile_controller.dart';
import 'help_center_screen.dart';
import 'password_manager_screen.dart';
import 'privacy_screen.dart';
import 'profile_update_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Profile", style: AppStyles.headLineStyle2),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppStyles.primaryColor));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, style: AppStyles.headLineStyle4.copyWith(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchUserProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryColor),
                  child: Text('Retry', style: AppStyles.headLineStyle4.copyWith(color: AppStyles.whiteColor)),
                ),
              ],
            ),
          );
        }
        final user = controller.userProfile.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : NetworkImage("https://i.pravatar.cc/300"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                user != null ? "${user.firstName ?? ''} ${user.lastName ?? ''}".trim() : "User",
                style: AppStyles.headLineStyle2,
              ),
              Text(
                user?.email ?? '',
                style: AppStyles.textStyle.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              _buildListTile(Icons.person_outline, "Your profile", () {
                Get.to(
                  const ProfileUpdateScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              }),
              _buildListTile(Icons.shopping_bag_outlined, "My Orders", () {
                Get.to(
                  const OrdersScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              }),
              _buildListTile(Icons.settings_outlined, "Settings", () {}),
              _buildListTile(Icons.notifications, "Notification", () {}),
              _buildListTile(Icons.password, "Password Manager", () {
                Get.to(
                  const PasswordManagerScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              }),
              _buildListTile(Icons.help_outline, "Help Center", () {
                Get.to(
                  const HelpCenterScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              }),
              _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
                Get.to(
                  const PrivacyScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              }),
              _buildListTile(Icons.group_outlined, "Invite Friends", () {}),
              _buildListTile(Icons.logout, "Log out", () {
                showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppStyles.bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      actionsPadding: const EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 5),
                      alignment: Alignment.center,
                      title: const Center(child: Text("Logout?")),
                      titleTextStyle: AppStyles.headLineStyle2,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
                          Text(
                            "Are you sure you want to log out?",
                            style: AppStyles.headLineStyle4.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      actions: [
                        Expanded(
                          child: OutlinedButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                              backgroundColor: WidgetStateProperty.all(AppStyles.primaryColor.withOpacity(0.1)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              side: WidgetStateProperty.all(
                                BorderSide(color: AppStyles.primaryColor, width: 0.5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              'Cancel',
                              style: AppStyles.headLineStyle3.copyWith(color: AppStyles.primaryColor),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop(true);
                              await AuthHelpers.logout();
                            },
                            label: Text(
                              "Yes, Logout",
                              style: AppStyles.headLineStyle3.copyWith(color: AppStyles.whiteColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          leading: Icon(icon, color: AppStyles.primaryColor),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        Divider(height: 0, color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
      ],
    );
  }
}
