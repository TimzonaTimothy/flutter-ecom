import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';
import '../../cart/views/shipping_address_screen.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

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
                onTap: () {
                    Get.to(
                    const ShippingAddressScreen(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
             const SizedBox(height: 24),
              PrimaryButton(
                isBorder: true,
                verticalPadding: 10,
                horizontalPadding: 10,
                hasBackground: false,
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
