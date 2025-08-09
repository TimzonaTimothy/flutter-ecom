import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/product_card.dart';
import '../controllers/search_and_filter_controller.dart';
import 'product_detail.dart';
import 'product_filter.dart';

class ProductListByFilters extends StatelessWidget {
  const ProductListByFilters({super.key});

  @override
  Widget build(BuildContext context) {
    // final filterController = Get.find<FilterController>();
    final FilterController filterController = Get.put(FilterController());
    final ScrollController scrollController = ScrollController();
    int currentPage = 1;
    bool isLoadingMore = false;
    
    // Apply filters when screen is opened
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   filterController.applyFilters();
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (filterController.filterOptions.value != null) {
        filterController.applyFilters();
      } else {
        filterController.loadFilterOptions().then((_) {
          if (filterController.filterOptions.value != null) {
            filterController.applyFilters();
          }
        });
      }
    });


    // Pagination logic
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoadingMore) {
        isLoadingMore = true;
        currentPage++;
        filterController.applyFilters(page: currentPage).then((_) {
          isLoadingMore = false;
        });
      }
    });

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Obx(() => Text(
          filterController.hasActiveFilters 
              ? "Filtered Products" 
              : "All Products", 
          style: AppStyles.headLineStyle2
        )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        // actions: [
        //   Obx(() => filterController.hasActiveFilters
        //       ? IconButton(
        //           icon: Icon(Icons.clear_all, color: AppStyles.primaryColor),
        //           onPressed: () {
        //             filterController.resetFilters();
        //           },
        //         )
        //       : const SizedBox.shrink()),
        // ],
      ),
      body: Column(
        children: [
          // Filter description
          Obx(() => filterController.hasActiveFilters
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppStyles.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Filters:',
                        style: AppStyles.textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filterController.getFilterDescription(),
                        style: AppStyles.textStyle.copyWith(
                          fontSize: 12,
                          color: AppStyles.textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          
          // Products list
          Expanded(
            child: Obx(() {
              if (filterController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (filterController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        filterController.errorMessage.value,
                        style: AppStyles.textStyle.copyWith(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          filterController.loadFilterOptions();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: AppStyles.whiteColor),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (filterController.filteredProducts.isEmpty) {
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
                        'No products found',
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        filterController.hasActiveFilters
                            ? 'Try adjusting your filters to see more results'
                            : 'No products available at the moment',
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (filterController.hasActiveFilters) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            filterController.resetFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppStyles.primaryColor),
                          ),
                          child: Text(
                            'Clear Filters',
                            style: TextStyle(color: AppStyles.primaryColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await filterController.applyFilters();
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    // Results count
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${filterController.filteredProducts.length} products found',
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Products grid
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.76,
                      children: filterController.filteredProducts.map((product) {
                        final imageUrl = product.image ?? 'assets/images/default_product.png';

                        return ProductCard(

                          productId: product.id,
                    imagePath: imageUrl,
                    title: product.title,
                    price: product.originalPrice?.toString() ?? '0',
                    rating: product.rating,
                    oldPrice: product.discountPrice?.toString() ?? '0',
                    
                    onTap: () {
                      Get.to(() => ProductDetail(productId: product.id),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500));
                    },

                          
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      
      // Floating action button to open filters
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.to(
      //       () => const FilterScreen(),
      //       transition: Transition.rightToLeftWithFade,
      //       duration: const Duration(milliseconds: 500),
      //     );
      //   },
      //   backgroundColor: AppStyles.primaryColor,
      //   child: Icon(
      //     Icons.filter_list,
      //     color: AppStyles.whiteColor,
      //   ),
      // ),
    );
  }
}


