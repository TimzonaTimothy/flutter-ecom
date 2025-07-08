import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'product_list_by_category.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late CategoryController categoryController;

  @override
  void initState() {
    super.initState();
    categoryController = Get.put(CategoryController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Categories", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryController.categories.isEmpty) {
          return const Center(child: Text("No categories found."));
        }

        return ListView.builder(
          itemCount: categoryController.categories.length,
          itemBuilder: (context, index) {
            final CategoryModel category = categoryController.categories[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onTap: () {
                final categoryProduct = CategoryProductModel(
                  id: category.id,
                  title: category.title,
                );
                Get.to(
                  () => ProductListByCategory(category: categoryProduct),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              },
              leading: CircleAvatar(
                backgroundColor: AppStyles.primaryColor,
                backgroundImage: NetworkImage(category.image),
                radius: 26,
              ),
              title: Text(category.title),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        );
      }),
    );
  }
}
