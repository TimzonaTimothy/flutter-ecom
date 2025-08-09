import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import '../controllers/profile_controller.dart';

// class ProfileUpdateScreen extends StatefulWidget {
//   const ProfileUpdateScreen({super.key});

//   @override
//   State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
// }

// class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     phoneNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Update Profile", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//       ),
//       body: ListView(
//           padding: const EdgeInsets.all(20),
//           shrinkWrap: true,
//           children: [
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 24),
//                   Text(
//                     "Complete your profile",
//                     style: AppStyles.headLineStyle1,
//                   ),
//                   const SizedBox(height: 15),
//                   Text(
//                     "Don't worry, only you can see your personal data. No one else will be able to see it",
//                     style: AppStyles.textStyle,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       const CircleAvatar(
//                         radius: 80,
//                         backgroundImage: NetworkImage(
//                           "https://i.pravatar.cc/300",
//                         ),
//                       ),
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundColor: AppStyles.primaryColor,
//                         child: Icon(Icons.edit,
//                             size: 16, color: AppStyles.whiteColor),
//                       ),
//                     ],
//                   ),
//                   const AppDoubleText(
//                     bigText: 'First Name',
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   PrimaryInput(
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your first name';
//                       }
//                       if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
//                         return 'Name must contain only letters';
//                       }
//                       return null;
//                     },
//                     controller: firstNameController,
//                     hintText: "John",
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const AppDoubleText(
//                     bigText: 'Last Name',
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   PrimaryInput(
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter your last name';
//                       }
//                       if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
//                         return 'Name must contain only letters';
//                       }
//                       return null;
//                     },
//                     controller: lastNameController,
//                     hintText: "Doe",
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const AppDoubleText(
//                     bigText: 'Phone Number',
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   PrimaryInput(
//                     validator: (value) => value == null || value.length < 6
//                         ? 'Phone number must be at least 11 characters'
//                         : null,
//                     controller: phoneNumberController,
//                     keyboardType: TextInputType.phone,
//                     hintText: "123456",
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const AppDoubleText(
//                     bigText: 'Gender',
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   ButtonTheme(
//                     alignedDropdown: true,
//                     child: DropdownButtonFormField<String>(
//                       isExpanded: true,
//                       decoration: InputDecoration(
//                         // labelText: 'Gender',
//                         labelStyle: const TextStyle(
//                             fontFamily: 'Roboto',
//                             fontSize: 16,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w600),
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: AppStyles.primaryColor, width: 0.5)),
//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: AppStyles.primaryColor, width: 0.5)),
//                         disabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: AppStyles.primaryColor, width: 0.5)),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: AppStyles.primaryColor, width: 0.5)),
//                         focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                                 color: AppStyles.primaryColor, width: 0.5)),
//                         filled: true,
//                         fillColor: AppStyles.bgColor,
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 15, horizontal: 10),
//                       ),
//                       style: AppStyles.textStyle,
//                       dropdownColor: AppStyles.bgColor,
//                       icon: Icon(
//                         Icons.arrow_drop_down,
//                         color: AppStyles
//                             .primaryColor, // Changes the color of the dropdown icon
//                         size: 28, // Changes the size of the dropdown icon
//                       ),
//                       iconSize: 28, // Further controls the size of the icon

//                       items: [
//                         DropdownMenuItem(
//                           value: 'Male',
//                           child: Text(
//                             'Male',
//                             style: AppStyles.textStyle,
//                           ),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Female',
//                           child: Text(
//                             'Female',
//                             style: AppStyles.textStyle,
//                           ),
//                         ),
//                       ],
//                       onChanged: (String? value) {
//                         // Handle gender selection
//                       },
//                     ),
//                   ),
//                   //
//                   const SizedBox(
//                     height: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ]),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(20),
//         child: PrimaryButton(
//           text: "Update Profile",
//           onTap: () {},
//           horizontalPadding: 10,
//         ),
//       ),
//     );
//   }
// }


class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController profilePictureController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    // Populate fields with current user data
    final user = controller.userProfile.value;
    if (user != null) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      phoneController.text = user.phone ?? '';
      cityController.text = user.city ?? '';
      stateController.text = user.state ?? '';
      countryController.text = user.country ?? '';
      profilePictureController.text = user.profilePicture ?? '';
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    profilePictureController.dispose();
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppStyles.primaryColor));
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text("Complete your profile", style: AppStyles.headLineStyle1),
                  const SizedBox(height: 15),
                  Text(
                    "Don't worry, only you can see your personal data. No one else will be able to see it",
                    style: AppStyles.textStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: controller.userProfile.value?.profilePicture != null
                            ? NetworkImage(controller.userProfile.value!.profilePicture!)
                            : NetworkImage("https://i.pravatar.cc/300"),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppStyles.primaryColor,
                        child: Icon(Icons.edit, size: 16, color: AppStyles.whiteColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'First Name'),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'Last Name'),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'Phone Number'),
                  const SizedBox(height: 10),
                  PrimaryInput(
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                        return 'Enter a valid phone number (10-15 digits)';
                      }
                      return null;
                    },
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    hintText: "+1234567890",
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'City'),
                  const SizedBox(height: 10),
                  PrimaryInput(
                    controller: cityController,
                    hintText: "San Francisco",
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'State'),
                  const SizedBox(height: 10),
                  PrimaryInput(
                    controller: stateController,
                    hintText: "CA",
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'Country'),
                  const SizedBox(height: 10),
                  PrimaryInput(
                    controller: countryController,
                    hintText: "USA",
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'Profile Picture URL'),
                  const SizedBox(height: 10),
                  PrimaryInput(
                    controller: profilePictureController,
                    hintText: "https://example.com/profile.jpg",
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 20),
                  const AppDoubleText(bigText: 'Gender'),
                  const SizedBox(height: 10),

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
                      dropdownColor: AppStyles.bgColor,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppStyles
                            .primaryColor, // Changes the color of the dropdown icon
                        size: 28, // Changes the size of the dropdown icon
                      ),
                      iconSize: 28, // Further controls the size of the icon
value: selectedGender,
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
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    ),
                  ),
                 
                  if (controller.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      controller.errorMessage.value,
                      style: AppStyles.textStyle.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: PrimaryButton(
          isLoading: controller.isLoading.value,
          text: "Update Profile",
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              final success = await controller.updateUserProfile(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phone: phoneController.text,
                city: cityController.text,
                state: stateController.text,
                gender: selectedGender,
                country: countryController.text,
                profilePicture: profilePictureController.text,
              );
              if (success) {
                Get.snackbar('Success', 'Profile updated successfully',
                    backgroundColor: AppStyles.primaryColor, colorText: AppStyles.whiteColor);
                Get.back();
              } else {
                Get.snackbar('Error', controller.errorMessage.value,
                    backgroundColor: Colors.red, colorText: AppStyles.whiteColor);
              }
            }
          },
          horizontalPadding: 10,
        ),
      ),
    );
  }
}