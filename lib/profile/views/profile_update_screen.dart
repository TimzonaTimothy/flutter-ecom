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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Update Profile", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Complete your profile",
                    style: AppStyles.headLineStyle1,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Don't worry, only you can see your personal data. No one else will be able to see it",
                    style: AppStyles.textStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/300",
                        ),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppStyles.primaryColor,
                        child: Icon(Icons.edit,
                            size: 16, color: AppStyles.whiteColor),
                      ),
                    ],
                  ),
                  const AppDoubleText(
                    bigText: 'First Name',
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
                    controller: firstNameController,
                    hintText: "John",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const AppDoubleText(
                    bigText: 'Last Name',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  PrimaryInput(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                        return 'Name must contain only letters';
                      }
                      return null;
                    },
                    controller: lastNameController,
                    hintText: "Doe",
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
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    hintText: "123456",
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
                  ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        // labelText: 'Gender',
                        labelStyle: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: AppStyles.primaryColor, width: 0.5)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: AppStyles.primaryColor, width: 0.5)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: AppStyles.primaryColor, width: 0.5)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: AppStyles.primaryColor, width: 0.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: AppStyles.primaryColor, width: 0.5)),
                        filled: true,
                        fillColor: AppStyles.bgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                      style: AppStyles.textStyle,
                      dropdownColor: Colors
                          .white, // Changes the dropdown's background color
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppStyles
                            .primaryColor, // Changes the color of the dropdown icon
                        size: 28, // Changes the size of the dropdown icon
                      ),
                      iconSize: 28, // Further controls the size of the icon

                      items: [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text(
                            'Male',
                            style: AppStyles.textStyle,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text(
                            'Female',
                            style: AppStyles.textStyle,
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        // Handle gender selection
                      },
                    ),
                  ),
                  //
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ]),
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
