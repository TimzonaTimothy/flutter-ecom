import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/category_scroller.dart';
import '../../base/widgets/category_shimmer.dart';
import '../../base/widgets/filter_card.dart';
import '../../base/widgets/image_sliders.dart';
import '../../base/widgets/product_card.dart';
import '../../base/widgets/product_shimmer.dart';
import '../../cart/controllers/address_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../notification/views/notification_screen.dart';
import '../../products/controllers/category_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../products/models/product_model.dart';
import '../../products/views/category_list.dart';
import '../../products/views/product_detail.dart';
import '../../products/views/product_filter.dart';
import '../../products/views/product_list_by_category.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import 'location_screen.dart';
import '../../products/views/product_search_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool isLoading = true;
//   late final CategoryController categoryController;
//   late final ProductsController productsController;
//   late WishlistController wishlistController;
//   late final NotificationController notificationController;
//   late final AddressController addressController;

//   int selectedFilterIndex = 0;

//   final List<String> filters = [
//     'All',
//     'Newest',
//     'Popular',
//     'Man',
//     'Woman',
//     'unisex'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (!Get.isRegistered<CategoryController>()) {
//       Get.put(CategoryController());
//     }
//     if (!Get.isRegistered<ProductsController>()) {
//       Get.put(ProductsController());
//     }
//     if (!Get.isRegistered<WishlistController>()) {
//       Get.put(WishlistController());
//     }

//     if (!Get.isRegistered<NotificationController>()) {
//       Get.put(NotificationController(),
//           permanent: true); 
//     }
//     if (!Get.isRegistered<AddressController>()) {
//       Get.put(AddressController(),
//           permanent: true); 
//     }
//     wishlistController = Get.find<WishlistController>();

//     categoryController = Get.find<CategoryController>();
//     productsController = Get.find<ProductsController>();
//     notificationController = Get.find<NotificationController>();

//     addressController = Get.find<AddressController>();



//     // Simulate a delay like fetching from API
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         backgroundColor: AppStyles.bgColor,
//         title: Container(
//           padding: const EdgeInsets.only(left: 10),
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(left: 5.0),
//                 child: Text("Location",
//                     style: TextStyle(
//                       fontSize: 14,
//                     )),
//               ),
//               const SizedBox(height: 4),
//               GestureDetector(
//                 onTap: () {
//                   Get.to(
//                     const LocationScreen(),
//                     transition: Transition.rightToLeftWithFade,
//                     duration: const Duration(milliseconds: 500),
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       color: AppStyles.primaryColor,
//                     ),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.5,
//                       child: GetX<AddressController>(
//   init: AddressController.to,
//   builder: (controller) {
//     final address = controller.selectedAddress.value?.address;

//     return Text(
//       address ?? "Please select a location",
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//       style: TextStyle(
//         fontWeight: FontWeight.w500,
//         fontSize: 16,
//         color: AppStyles.primaryColor,
//       ),
//     );
//   },
// ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           GestureDetector(
//             onTap: () {
//               Get.to(const NotificationScreen());
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(50),
//                   color: AppStyles.whiteSmokeColor),
//               child: Obx(() {
//                 final notificationController =
//                     Get.find<NotificationController>();
//                 return Badge.count(
//                   count: notificationController.unreadCount.value,
//                   child: Icon(
//                     Icons.notifications,
//                     color: AppStyles.textColor,
//                   ),
//                 );
//               }),
//             ),
//           ),
//           const SizedBox(
//             width: 20,
//           )
//         ],
//       ),
//       backgroundColor: AppStyles.bgColor,
//       body: ListView(
//         padding: const EdgeInsets.only(bottom: 20),
//         shrinkWrap: true,
//         children: [
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Get.to(
//                         SearchScreen(),
//                         transition: Transition.rightToLeftWithFade,
//                         duration: const Duration(milliseconds: 500),
//                       );
//                     },
//                     child: Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                           color: AppStyles.whiteColor,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                               width: 1, color: AppStyles.whiteColor)),
//                       child: Row(
//                         children: [
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Icon(
//                             Icons.search,
//                             color: AppStyles.whiteSmokeColor,
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Text(
//                             'Search',
//                             style: AppStyles.textStyle
//                                 .copyWith(color: AppStyles.whiteSmokeColor),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(
//                       const FilterScreen(),
//                       transition: Transition.rightToLeftWithFade,
//                       duration: const Duration(milliseconds: 500),
//                     );
//                   },
//                   child: Container(
//                     height: 40,
//                     width: 40,
//                     padding: const EdgeInsets.all(5),
//                     decoration: BoxDecoration(
//                         color: AppStyles.blackColor,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Icon(
//                       FluentSystemIcons.ic_fluent_filter_filled,
//                       color: AppStyles.whiteColor,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: ImageSliders(),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: AppDoubleText(
//               bigText: 'Categories',
//               smallText: 'View all',
//               func: () {
//                 Get.to(
//                   () => const CategoryList(),
//                   transition: Transition.rightToLeftWithFade,
//                   duration: const Duration(milliseconds: 500),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Obx(() {
//               if (categoryController.isLoading.value) {
//                 return const CategoryShimmer();
//               }

//               final items = categoryController.categories.map((category) {
//                 return {
//                   'label': category.title,
//                   'image': category.image,
//                 };
//               }).toList();

//               return CategoryScroller(
//                 items: items,
//                 onTap: (label) {
//                   final tappedCategory =
//                       categoryController.categories.firstWhere(
//                     (category) => category.title == label,
//                     orElse: () => throw Exception('Category not found'),
//                   );
//                   final categoryProduct = CategoryProductModel(
//                     id: tappedCategory.id,
//                     title: tappedCategory.title,
//                   );
//                   Get.to(
//                     () => ProductListByCategory(category: categoryProduct),
//                     transition: Transition.rightToLeftWithFade,
//                     duration: const Duration(milliseconds: 500),
//                   );
//                 },
//               );
//             }),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Obx(() => FilterChipsRow(
//                   filters: filters,
//                   selectedIndex: productsController.selectedFilterIndex.value,
//                   onSelected: (index) {
//                     productsController.applyFilter(index);
//                   },
//                 )),
//           ),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             // child: isLoading ? const ProductCardShimmer() : _buildProductGrid(),
//             child: _buildProductGrid(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductGrid() {
//     return Obx(() {
//       if (productsController.isLoad.value) {
//         return const ProductCardShimmer();
//       }

//       final filteredProducts = productsController.filteredProducts;

//       if (filteredProducts.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.shopping_bag_outlined,
//                 size: 64,
//                 color: AppStyles.whiteSmokeColor,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'No products found',
//                 style: AppStyles.textStyle.copyWith(
//                   color: AppStyles.whiteSmokeColor,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 productsController.getFilterDescription(),
//                 style: AppStyles.textStyle.copyWith(
//                   color: AppStyles.whiteSmokeColor,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }

//       return GridView.count(
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         crossAxisCount: 2,
//         crossAxisSpacing: 15,
//         mainAxisSpacing: 20,
//         childAspectRatio: 0.76,
//         children: filteredProducts.map((product) {
//           final imageUrl =
//               (product.imageUrls != null && product.imageUrls!.isNotEmpty)
//                   ? product.imageUrls!.first
//                   : AppMedia.welcomeImage;
//           return ProductCard(
//             productId: product.id,
//             imagePath: imageUrl,
//             title: product.title,
//             price: product.discountPrice ?? '0',
//             rating: product.rating,
//             oldPrice: product.originalPrice ?? '0',
//             onTap: () {
//               Get.to(
//                 () => ProductDetail(productId: product.id),
//                 transition: Transition.rightToLeftWithFade,
//                 duration: const Duration(milliseconds: 800),
//               );
//             },
//           );
//         }).toList(),
//       );
//     });
//   }
// }



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  late final CategoryController categoryController;
  late final ProductsController productsController;
  late final WishlistController wishlistController;
  late final NotificationController notificationController;
  late final AddressController addressController;

  final List<String> filters = [
    'All',
    'Newest',
    'Popular',
    'Man',
    'Woman',
    'unisex'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    if (!Get.isRegistered<CategoryController>()) {
      Get.put(CategoryController());
    }
    if (!Get.isRegistered<ProductsController>()) {
      Get.put(ProductsController());
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController(), permanent: true);
    }
    categoryController = Get.find<CategoryController>();
    productsController = Get.find<ProductsController>();
    wishlistController = Get.find<WishlistController>();
    notificationController = Get.find<NotificationController>();
    addressController = Get.find<AddressController>();

    // Simulate initial loading
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    try {
      // Reset loading state
      setState(() {
        isLoading = true;
      });

      // Refresh all controllers' data
      await Future.wait([
        categoryController.fetchCategories(),
        productsController.getProduct(),
        wishlistController.fetchWishlist(),
        notificationController.fetchNotifications(),
        addressController.fetchAddresses(),
      ]);

      // Update UI after refresh
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh data: $e',
          backgroundColor: Colors.red, colorText: AppStyles.whiteColor);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppStyles.bgColor,
        title: Container(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text("Location",
                    style: TextStyle(
                      fontSize: 14,
                    )),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Get.to(
                    const LocationScreen(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppStyles.primaryColor,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: GetX<AddressController>(
                        init: AddressController.to,
                        builder: (controller) {
                          final address = controller.selectedAddress.value?.address;
                          return Text(
                            address ?? "Please select a location",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppStyles.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(const NotificationScreen());
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppStyles.whiteSmokeColor),
              child: Obx(() {
                final notificationController = Get.find<NotificationController>();
                return Badge.count(
                  count: notificationController.unreadCount.value,
                  child: Icon(
                    Icons.notifications,
                    color: AppStyles.textColor,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor: AppStyles.bgColor,
      body: RefreshIndicator(
        color: AppStyles.primaryColor,
        backgroundColor: AppStyles.bgColor,
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          SearchScreen(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppStyles.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1, color: AppStyles.whiteColor)),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Icons.search,
                              color: AppStyles.whiteSmokeColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Search',
                              style: AppStyles.textStyle
                                  .copyWith(color: AppStyles.whiteSmokeColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        const FilterScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: AppStyles.blackColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        FluentSystemIcons.ic_fluent_filter_filled,
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ImageSliders(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppDoubleText(
                bigText: 'Categories',
                smallText: 'View all',
                func: () {
                  Get.to(
                    () => const CategoryList(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Obx(() {
                if (categoryController.isLoading.value) {
                  return const CategoryShimmer();
                }

                final items = categoryController.categories.map((category) {
                  return {
                    'label': category.title,
                    'image': category.image,
                  };
                }).toList();

                return CategoryScroller(
                  items: items,
                  onTap: (label) {
                    final tappedCategory = categoryController.categories.firstWhere(
                      (category) => category.title == label,
                      orElse: () => throw Exception('Category not found'),
                    );
                    final categoryProduct = CategoryProductModel(
                      id: tappedCategory.id,
                      title: tappedCategory.title,
                    );
                    Get.to(
                      () => ProductListByCategory(category: categoryProduct),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Obx(() => FilterChipsRow(
                    filters: filters,
                    selectedIndex: productsController.selectedFilterIndex.value,
                    onSelected: (index) {
                      productsController.applyFilter(index);
                    },
                  )),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading ? const ProductCardShimmer() : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (productsController.isLoad.value) {
        return const ProductCardShimmer();
      }

      final filteredProducts = productsController.filteredProducts;

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
                'No products found',
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
          final imageUrl =
              (product.imageUrls != null && product.imageUrls!.isNotEmpty)
                  ? product.imageUrls!.first
                  : AppMedia.welcomeImage;
          return ProductCard(
            productId: product.id,
            imagePath: imageUrl,
            title: product.title,
            price: product.discountPrice ?? '0',
            rating: product.rating,
            oldPrice: product.originalPrice ?? '0',
            onTap: () {
              Get.to(
                () => ProductDetail(productId: product.id),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 800),
              );
            },
          );
        }).toList(),
      );
    });
  }
}