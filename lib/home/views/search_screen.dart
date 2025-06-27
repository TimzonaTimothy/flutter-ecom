import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
    );
  }
}