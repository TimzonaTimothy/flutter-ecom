import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  int selectedAddressIndex = 0;

  final List<Map<String, String>> addresses = [
    {
      "label": "Home",
      "address": "1901 Thornridge Cir. Shiloh, Hawaii 81063",
    },
    {
      "label": "Office",
      "address": "4517 Washington Ave. Manchester, Kentucky 39495",
    },
    {
      "label": "Parent’s House",
      "address": "8502 Preston Rd. Inglewood, Maine 98380",
    },
    {
      "label": "Friend’s House",
      "address": "2464 Royal Ln. Mesa, New Jersey 45463",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Shipping Address", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return AddressCard(
                  label: addresses[index]['label']!,
                  address: addresses[index]['address']!,
                  isSelected: selectedAddressIndex == index,
                  onTap: () {
                    setState(() {
                      selectedAddressIndex = index;
                    });
                  },
                );
                
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DottedBorder(
                color: AppStyles.primaryColor,
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [6, 3], // [dash width, gap]
                strokeWidth: 1.5,
                child: OutlinedButton.icon(
                  onPressed: () {
                   
                  },
                  icon: Icon(Icons.add, color: AppStyles.primaryColor),
                  label: Text(
                    "Add New Shipping Address",
                    style: TextStyle(color: AppStyles.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none, 
                    padding: const EdgeInsets.symmetric(
                         horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: PrimaryButton(
              verticalPadding: 10,
              horizontalPadding: 100,
              text: 'Apply',
              onTap: () {
                //   Get.to(
                //   const (),
                //   transition: Transition.rightToLeftWithFade,
                //   duration: const Duration(milliseconds: 500),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String label;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.label,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_pin, color: AppStyles.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppStyles.headLineStyle3),
                    const SizedBox(height: 4),
                    Text(address,
                        style: AppStyles.textStyle.copyWith(color: AppStyles.whiteSmokeColor)),
                        
                  ],
                ),
              ),
              Radio(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppStyles.primaryColor,
              ),
              
            ],
          ),
          Divider(
                          color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}
