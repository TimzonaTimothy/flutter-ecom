import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import 'product_list_by_filters.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final brands = ['All', 'Nike', 'Adidas', 'Puma', 'Reebok'];
  final gender = ['All', 'Men', 'Women'];
  final sortBy = ['Most Recent', 'Popular', 'Price High'];

  int selectedBrand = 0;
  int selectedGender = 0;
  int selectedSort = 1;

  RangeValues priceRange = const RangeValues(7, 100);

  int selectedRating = 0;
  final ratings = [
    '4.5 and above',
    '4.0 - 4.5',
    '3.5 - 4.0',
    '3.0 - 3.5',
    '2.5 - 3.0'
  ];

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        shrinkWrap: true,
        children: [
          _buildSection('Brands', brands, selectedBrand,
              (i) => setState(() => selectedBrand = i)),
          _buildSection('Gender', gender, selectedGender,
              (i) => setState(() => selectedGender = i)),
          _buildSection('Sort by', sortBy, selectedSort,
              (i) => setState(() => selectedSort = i)),
          const SizedBox(height: 20),
          const Text('Pricing Range',
              style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: priceRange,
            min: 2,
            max: 150,
            divisions: 10,
            labels: RangeLabels(
              priceRange.start.round().toString(),
              priceRange.end.round().toString(),
            ),
            activeColor: AppStyles.primaryColor,
            onChanged: (values) {
              setState(() {
                priceRange = values;
              });
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2'),
              Text('7'),
              Text('22'),
              Text('50'),
              Text('100'),
              Text('150+'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
          ...List.generate(ratings.length, (i) {
            return RadioListTile(
              value: i,
              groupValue: selectedRating,
              onChanged: (val) => setState(() => selectedRating = val!),
              title: Row(
                children: [
                  Row(
                    children: List.generate(
                        5,
                        (_) => const Icon(Icons.star,
                            color: Colors.amber, size: 20)),
                  ),
                  const SizedBox(width: 10),
                  Text(ratings[i]),
                ],
              ),
              activeColor: AppStyles.primaryColor,
            );
          }),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                  backgroundColor: WidgetStateProperty.all(
                      AppStyles.primaryColor.withOpacity(0.1)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // ✅ Rounded corners
                    ),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: AppStyles.primaryColor, // ✅ Border color
                      width: 0.5,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedBrand = 0;
                    selectedGender = 0;
                    selectedSort = 1;
                    priceRange = const RangeValues(7, 100);
                    selectedRating = 0;
                  });
                },
                child: Text(
                  'Reset Filter',
                  style: AppStyles.headLineStyle3
                      .copyWith(color: AppStyles.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const ProductListByFilters(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500));
                },
                label: Text(
                  "Apply",
                  style: AppStyles.headLineStyle3
                      .copyWith(color: AppStyles.whiteColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, int selected,
      Function(int) onSelected) {
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
