import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        centerTitle: true,
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/300", // Replace with user's image
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.brown,
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Esther Howard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildListTile(Icons.person_outline, "Your profile"),
            _buildListTile(Icons.credit_card, "Payment Methods"),
            _buildListTile(Icons.shopping_bag_outlined, "My Orders"),
            _buildListTile(Icons.settings_outlined, "Settings"),
            _buildListTile(Icons.help_outline, "Help Center"),
            _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy"),
            _buildListTile(Icons.group_outlined, "Invites Friends"),
            _buildListTile(Icons.logout, "Log out"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icon, color: Colors.brown),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle navigation
      },
    );
  }
}
