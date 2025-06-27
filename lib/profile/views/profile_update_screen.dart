import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final TextEditingController nameController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
 
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Password Manager", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AppDoubleText(
                bigText: 'Name',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name must contain only letters';
                    }
                    return null;
                  },
                  controller: nameController,
                  hintText: "John",
                ),
             
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'Phone Number',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                validator: (value) => value == null || value.length < 6
                    ? 'Phone number must be at least 11 characters'
                    : null,
                controller: nameController,
                obscureText: true,
                hintText: "Password",
              ),
              const SizedBox(
                height: 20,
              ),
              const AppDoubleText(
                bigText: 'Gender',
              ),
              const SizedBox(
                height: 10,
              ),
              PrimaryInput(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                      return 'Name must contain only letters';
                    }
                    return null;
                  },
                  controller: nameController,
                  hintText: "John",
                ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: PrimaryButton(
          text: "Update Profile",
          onTap: () {},
          horizontalPadding: 10,
        ),
      ),
    );
  }
}