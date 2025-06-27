import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';

class ShippingType extends StatefulWidget {
  const ShippingType({super.key});

  @override
  State<ShippingType> createState() => _ShippingTypeState();
}

class _ShippingTypeState extends State<ShippingType> {
  int selectedSippmentTypeIndex = 0;

  final List<Map<String, String>> shippingTypes = [
    {
      "label": "Economy",
      "estimated": "Estimated Arrival 25 August 2025",
    },
    {
      "label": "Regular",
      "estimated": "Estimated Arrival 24 August 2025",
    },
    {
      "label": "Cargo",
      "estimated": "Estimated Arrival 22 August 2025",
    },
   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Shipping Type", style: AppStyles.headLineStyle2),
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
              itemCount: shippingTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ShippingTypeCard(
                  label: shippingTypes[index]['label']!,
                  estimated: shippingTypes[index]['estimated']!,
                  isSelected: selectedSippmentTypeIndex == index,
                  onTap: () {
                    setState(() {
                      selectedSippmentTypeIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          
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

class ShippingTypeCard extends StatelessWidget {
  final String label;
  final String estimated;
  final bool isSelected;
  final VoidCallback onTap;

  const ShippingTypeCard({
    super.key,
    required this.label,
    required this.estimated,
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
              Icon(Icons.flight, color: AppStyles.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppStyles.headLineStyle3),
                    const SizedBox(height: 4),
                    Text(estimated,
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
              Divider(
                              color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
            ],
          ),
          Divider(
                          color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}
