import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Search", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppStyles.primaryColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              validator: (value) =>
                  value == null ? 'please enter your query' : null,
              controller: searchController,
              keyboardType: TextInputType.text,
              style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
              decoration: InputDecoration(
                hintText: "Search",
                alignLabelWithHint: true,
                hintTextDirection: TextDirection.ltr,
                hintStyle: AppStyles.textStyle.copyWith(
                  color: AppStyles.textColor.withOpacity(0.6),
                ),
                border: InputBorder.none,
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: AppStyles.primaryColor,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const AppDoubleText(
            bigText: "Recent",
            smallText: "Clear All",
          )
        ],
      ),
    );
  }
}
