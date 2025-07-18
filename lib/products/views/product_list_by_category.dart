import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/product_card.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import 'product_detail.dart';

class ProductListByCategory extends StatelessWidget {
  final CategoryProductModel category;

  const ProductListByCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text(category.title, style: AppStyles.headLineStyle2),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          GetBuilder<ProductsController>(
            builder: (productsController) {
              final filteredProducts = productsController.products
                  .where((product) => product.category.id == category.id)
                  .toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppStyles.whiteSmokeColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products in this category',
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productsController.getFilterDescription(),
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.76,
                children: filteredProducts.map((product) {
                  final imageUrl = (product.imageUrls != null &&
                          product.imageUrls!.isNotEmpty)
                      ? product.imageUrls!.first
                      : AppMedia.welcomeImage;

                  return ProductCard(
                    productId: product.id,
                    imagePath: imageUrl,
                    title: product.title,
                    price: product.originalPrice ?? '0',
                    rating: product.rating,
                    oldPrice: product.discountPrice ?? '0',
                    
                    onTap: () {
                      Get.to(() => ProductDetail(productId: product.id),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500));
                    },
                   
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
