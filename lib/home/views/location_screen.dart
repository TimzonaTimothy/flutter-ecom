import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/location.dart';
import '../../base/widgets/primary_button.dart';
import '../../cart/controllers/address_controller.dart';
import '../../cart/models/address_model.dart';
import '../../cart/views/shipping_address_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late AddressController addressController;

  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController());
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Location", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: AppStyles.primaryColor,
                child: const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
               Text(
                "What is your location?",
                style: AppStyles.headLineStyle1,
              ),
              const SizedBox(height: 24),
              Text(
                "We need to know your location in order to suggest nearby services",
                style: AppStyles.textStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 10,
                text: 'Allow Location Access',
                // onTap: () {
                //     Get.to(
                //     const ShippingAddressScreen(),
                //     transition: Transition.rightToLeftWithFade,
                //     duration: const Duration(milliseconds: 500),
                //   );
                // },
               onTap: () async {
                  final locationData = await getCurrentLocationData();
                  if (locationData != null) {
                    final addressModel = CreateAddressModel(
                      lat: locationData['lat'],
                      lng: locationData['lng'],
                      isDefault: true,
                      address: locationData['address'],
                      phone: '0000000000', // Replace with user phone
                      addressType: 'home',
                    );

                    bool success = await addressController.addAddress(addressModel);

                    if (success) {
                      Get.to(
                        const ShippingAddressScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                      );
                    } else {
                      Get.snackbar("Failed", "Could not add address");
                    }
                  } else {
                    Get.snackbar("Location Error", "Could not get current location");
                  }
                },

              ),
             const SizedBox(height: 24),
              PrimaryButton(
                isBorder: true,
                verticalPadding: 10,
                horizontalPadding: 10,
                backgroundColor: AppStyles.bgColor,
              textColor: AppStyles.primaryColor ,
                text: 'Enter Location Manually',
                onTap: () {
                  Get.to(
                    const ShippingAddressScreen(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}
