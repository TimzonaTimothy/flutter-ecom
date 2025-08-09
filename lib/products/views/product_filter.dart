import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../controllers/search_and_filter_controller.dart';
import 'product_list_by_filters.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.put(FilterController());

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Filter", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            shrinkWrap: true,
            children: [
              _buildSection(
                'Brands',
                controller.brands,
                controller.selectedBrand.value,
                (i) => controller.updateBrand(i),
              ),
              _buildSection(
                'Gender',
                controller.gender,
                controller.selectedGender.value,
                (i) => controller.updateGender(i),
              ),
              _buildSection(
                'Sort by',
                controller.sortBy,
                controller.selectedSort.value,
                (i) => controller.updateSort(i),
              ),
              const SizedBox(height: 20),
              const Text('Pricing Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
  values: controller.priceRange.value,
  min: controller.filterOptions.value!.priceRange['min'] ?? 150.0,
        max: controller.filterOptions.value!.priceRange['max'] ?? 1000.0,
  divisions: 10,
  labels: RangeLabels(
    controller.priceRange.value.start.round().toString(),
    controller.priceRange.value.end.round().toString(),
  ),
  activeColor: AppStyles.primaryColor,
  onChanged: (values) => controller.updatePriceRange(values),
),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('150'),
                  Text('200'),
                  Text('500'),
                  Text('900'),
                  
                  Text('1000+'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Reviews',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(controller.ratings.length, (i) {
                return RadioListTile(
                  value: i,
                  groupValue: controller.selectedRating.value,
                  onChanged: (val) => controller.updateRating(val!),
                  title: Row(
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (_) => const Icon(Icons.star,
                                color: Colors.amber, size: 20)),
                      ),
                      const SizedBox(width: 10),
                      Text(controller.ratings[i]),
                    ],
                  ),
                  activeColor: AppStyles.primaryColor,
                );
              }),
            ],
          )),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 360;
          final horizontalPadding = screenWidth * 0.05;
          final verticalPadding = screenWidth * 0.025;
          final buttonPadding = EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenWidth * 0.035,
          );
          final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: isSmallScreen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(buttonPadding),
                          backgroundColor: WidgetStateProperty.all(
                            AppStyles.primaryColor.withOpacity(0.1),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          side: WidgetStateProperty.all(
                            BorderSide(
                              color: AppStyles.primaryColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        onPressed: () {
                          controller.resetFilters();
                        },
                        child: Text(
                          'Reset',
                          textScaler: TextScaler.linear(textScaleFactor),
                          style: AppStyles.headLineStyle3.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.applyFilters();
                          Get.to(() => const ProductListByFilters(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500));
                        },
                        icon: Icon(
                          Icons.local_shipping_outlined,
                          color: AppStyles.whiteColor,
                        ),
                        label: Text(
                          'Apply',
                          textScaler: TextScaler.linear(textScaleFactor),
                          style: AppStyles.headLineStyle3.copyWith(
                            color: AppStyles.whiteColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: buttonPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(buttonPadding),
                            backgroundColor: WidgetStateProperty.all(
                              AppStyles.primaryColor.withOpacity(0.1),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            side: WidgetStateProperty.all(
                              BorderSide(
                                color: AppStyles.primaryColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          onPressed: () {
                            controller.resetFilters();
                          },
                          child: Text(
                            'Reset',
                            textScaler: TextScaler.linear(textScaleFactor),
                            style: AppStyles.headLineStyle3.copyWith(
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalPadding),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.applyFilters();
                            Get.to(() => const ProductListByFilters(),
                                transition: Transition.rightToLeftWithFade,
                                duration: const Duration(milliseconds: 500));
                          },
                          icon: Icon(
                            Icons.local_shipping_outlined,
                            color: AppStyles.whiteColor,
                          ),
                          label: Text(
                            'Apply',
                            textScaler: TextScaler.linear(textScaleFactor),
                            style: AppStyles.headLineStyle3.copyWith(
                              color: AppStyles.whiteColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            padding: buttonPadding,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> items, int selected, Function(int) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(items.length, (i) {
            return ChoiceChip(
              label: Text(items[i]),
              selected: selected == i,
              onSelected: (_) => onSelected(i),
              selectedColor: AppStyles.primaryColor,
              backgroundColor: Colors.grey.shade200,
              labelStyle:
                  TextStyle(color: selected == i ? Colors.white : Colors.black),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: selected == i
                      ? AppStyles.primaryColor
                      : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}