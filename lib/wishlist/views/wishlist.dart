import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../base/widgets/filter_card.dart';
import '../../base/widgets/product_card.dart';
import '../../products/views/product_detail.dart';
import '../controllers/wishlist_controller.dart';
import '../models/wishlist_model.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  int selectedFilterIndex = 0;
  late WishlistController wishlistController;

  final List<String> filters = ['All', 'Man', 'Woman', 'Unisex'];

  @override
  void initState() {
    super.initState();
    wishlistController = Get.find<WishlistController>();
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("My Wishlist", style: AppStyles.headLineStyle2),
        centerTitle: true,
        actions: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${wishlistController.wishlistCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: GetBuilder<WishlistController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppStyles.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: AppStyles.headLineStyle2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to your wishlist',
                    style: AppStyles.headLineStyle4,
                  ),
                //   const SizedBox(height: 24),
                // ElevatedButton(
                //   onPressed: () {
                //     // Navigate back to home/products screen
                //     Get.back();
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppStyles.primaryColor,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                //   ),
                //   child: const Text('Continue Shopping'),
                // ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshWishlist,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: FilterChipsRow(
                    filters: filters,
                    selectedIndex: selectedFilterIndex,
                    onSelected: (index) {
                      setState(() {
                        selectedFilterIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildProductGrid(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final String selectedFilter = filters[selectedFilterIndex];
    final List<WishlistModel> filteredProducts =
        wishlistController.getFilteredWishlistItems(selectedFilter);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.filter_alt_off,
              size: 48,
              color: AppStyles.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No products match this filter',
              style: AppStyles.headLineStyle3,
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter',
              style: AppStyles.headLineStyle4.copyWith(
                color: AppStyles.whiteSmokeColor,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      key: ValueKey<int>(selectedFilterIndex),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.76,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        final imageUrl = (product.imageUrls != null &&
                product.imageUrls!.isNotEmpty)
            ? product.imageUrls!.first
            : 'https://via.placeholder.com/200';

        return ProductCard(
          productId: product.id ?? 0,
          imagePath: imageUrl,
          title: product.title ?? 'Unknown Product',
          price: product.discountPrice ?? '0',
          rating: product.rating ?? 4.0,
          oldPrice: product.originalPrice ?? '0',
          onTap: () {
            if (product.id != null) {
              Get.to(
                () => ProductDetail(productId: product.id!),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500),
              );
            } else {
              showFailureSnackbar('Invalid product ID');
            }
          },
        );
      },
    );
  }
}