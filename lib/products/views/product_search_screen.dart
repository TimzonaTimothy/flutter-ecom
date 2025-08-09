import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/product_card.dart';
import '../controllers/search_and_filter_controller.dart';
import 'product_detail.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchProductController searchController =
        Get.put(SearchProductController());
    final ScrollController scrollController = ScrollController();

    // Setup pagination listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        if (searchController.canLoadMore) {
          searchController.loadMoreResults();
        }
      }
    });

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
            searchController.clearResults();
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input - Fixed to avoid unnecessary Obx
            Container(
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   border: Border.all(color: AppStyles.primaryColor, width: 1.0),
              //   borderRadius: BorderRadius.circular(12),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.grey.withOpacity(0.1),
              //       spreadRadius: 1,
              //       blurRadius: 3,
              //       offset: const Offset(0, 2),
              //     ),
              //   ],
              // ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppStyles.primaryColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                controller: searchController.searchController,
                focusNode: searchController.searchFocusNode,
                validator: (value) =>
                    value == null ? 'please enter your query' : null,
                style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
                decoration: InputDecoration(
                  hintText: "Search products, brands, categories...",
                  alignLabelWithHint: true,
                  hintTextDirection: TextDirection.ltr,
                  hintStyle: AppStyles.textStyle.copyWith(
                    color: AppStyles.textColor.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search, color: AppStyles.primaryColor),
                  suffixIcon: GetBuilder<SearchProductController>(
                    builder: (controller) =>
                        controller.searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: AppStyles.primaryColor),
                                onPressed: () => controller.clearSearchField(),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    searchController.performSearch(value);
                  }
                },
                onChanged: (value) {
                  searchController.update(); // Trigger rebuild for clear button
                },
              ),
            ),
            const SizedBox(height: 20),

            // Header section - Fixed Obx
            GetBuilder<SearchProductController>(
              builder: (controller) {
                if (!controller.hasSearched.value) {
                  return AppDoubleText(
                    bigText: "Recent",
                    smallText:
                        controller.recentSearches.isEmpty ? "" : "Clear All",
                    func: controller.recentSearches.isEmpty
                        ? null
                        : controller.clearSearches,
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Search Results", style: AppStyles.headLineStyle3),
                      Obx(() => controller.searchResults.isNotEmpty
                          ? Text(
                              "${controller.searchResults.length} found",
                              style: AppStyles.textStyle.copyWith(
                                color: AppStyles.textColor.withOpacity(0.7),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Main content area - Fixed Obx usage
            Expanded(
              child: GetBuilder<SearchProductController>(
                builder: (controller) {
                  // Loading state
                  if (controller.isLoading.value &&
                      controller.searchResults.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error state
                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState(controller);
                  }

                  // Show suggestions
                  if (controller.showSuggestions.value &&
                      controller.suggestions.isNotEmpty &&
                      !controller.hasSearched.value) {
                    return _buildSuggestionsList(controller);
                  }

                  // Show search results
                  if (controller.hasSearched.value) {
                    return _buildSearchResults(controller, scrollController);
                  }

                  // Show recent searches
                  return _buildRecentSearches(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SearchProductController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Colors.red.withOpacity(0.5)),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.errorMessage.value,
                style: AppStyles.textStyle
                    .copyWith(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (controller.searchController.text.isNotEmpty) {
                controller.performSearch(controller.searchController.text);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor),
            child: Text('Retry', style: TextStyle(color: AppStyles.whiteColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(SearchProductController controller) {
    return Obx(() => ListView.builder(
          itemCount: controller.suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.search, color: AppStyles.primaryColor),
              title: Text(controller.suggestions[index],
                  style: AppStyles.textStyle),
              onTap: () =>
                  controller.selectSuggestion(controller.suggestions[index]),
            );
          },
        ));
  }

  Widget _buildSearchResults(
      SearchProductController controller, ScrollController scrollController) {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  size: 64, color: AppStyles.textColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: AppStyles.headLineStyle3.copyWith(
                  color: AppStyles.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.76,
              ),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final product = controller.searchResults[index];
                final imageUrl =
                    product.image ?? 'assets/images/default_product.png';

                return ProductCard(
                  productId: product.id,
                  imagePath: imageUrl,
                  title: product.title,
                  price: product.originalPrice.toString(),
                  rating: product.rating,
                  oldPrice: product.discountPrice?.toString() ?? '',
                  onTap: () {
                    Get.to(
                      () => ProductDetail(productId: product.id),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                );
              },
            ),
          ),
          // Loading more indicator
          Obx(() => controller.isLoadingMore.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink()),
        ],
      );
    });
  }

  Widget _buildRecentSearches(SearchProductController controller) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history,
                  size: 64, color: AppStyles.textColor.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'No recent searches',
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.recentSearches.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history, color: AppStyles.primaryColor),
            title: Text(controller.recentSearches[index],
                style: AppStyles.textStyle),
            trailing: IconButton(
              icon: Icon(Icons.close,
                  color: AppStyles.textColor.withOpacity(0.5)),
              onPressed: () => controller.removeSearch(index),
            ),
            onTap: () =>
                controller.selectRecentSearch(controller.recentSearches[index]),
          );
        },
      );
    });
  }
}
