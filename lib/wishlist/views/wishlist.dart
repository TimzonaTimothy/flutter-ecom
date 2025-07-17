import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/filter_card.dart';
import '../../base/widgets/product_card.dart';
import '../../products/views/product_detail.dart';
import '../controllers/wishlist_controller.dart';

// class WishListScreen extends StatefulWidget {
//   const WishListScreen({super.key});

//   @override
//   State<WishListScreen> createState() => _WishListScreenState();
// }

// class _WishListScreenState extends State<WishListScreen> {
//   int selectedFilterIndex = 0;

//   final List<String> filters = ['All', 'Newest', 'Popular', 'Man', 'Woman','unisex'];

//   final List<Map<String, String>> allProducts = [
//     {'title': 'Summer Jacket', 'price': '100'},
//     {'title': 'Winter Hoodie', 'price': '120'},
//     {'title': 'Sneakers', 'price': '90'},
//     {'title': 'Raincoat', 'price': '80'},
//     // Add category key if you want to filter by category
//   ];

//   List<Map<String, String>> get filteredProducts {
//     // Replace with real filter logic
//     if (selectedFilterIndex == 0) return allProducts; // "All"
//     return allProducts.reversed.toList(); // For demo
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("My Wishlist", style: AppStyles.headLineStyle2),
//         centerTitle: true,
       
//       ),
//       body: ListView(
//         shrinkWrap: true,
//         padding: const EdgeInsets.only(bottom: 20, top: 20),
//         children: [
          

//           Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: FilterChipsRow(
//               filters: filters,
//               selectedIndex: selectedFilterIndex,
//               onSelected: (index) {
//                 setState(() {
//                   selectedFilterIndex = index;
//                 });
//               },
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
         

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: _buildProductGrid(filteredProducts), ),
//             ]),
//           );
     
//   }


//   Widget _buildProductGrid() {
//   return GetBuilder<WishlistController>(
//     builder: (wishlistController) {
//       final items = wishlistController.getFilteredWishlistItems(filters[selectedFilterIndex]);

//       if (items.isEmpty) {
//         return const Center(child: Text("No items in your wishlist."));
//       }

//       return GridView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         itemCount: items.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 15,
//           mainAxisSpacing: 20,
//           childAspectRatio: 0.76,
//         ),
//         itemBuilder: (context, index) {
//           final product = items[index];

//           return ProductCard(
//             productId: product['id'],
//             imagePath: product['imageUrl'],
//             title: product['title'],
//             price: product['price'].toString(),
//             rating: product['rating']?.toDouble() ?? 4.0,
//             oldPrice: product['oldPrice'].toString(),
//             onTap: () {},
//             onTapWishlist: () {
//               Get.find<WishlistController>().toggleWishlist(product['id']);
//             },
//             isFavorite: wishlistController.isFavorite(product['id']),
//           );
//         },
//       );
//     },
//   );
// }


// //   Widget _buildProductGrid(List<Map<String, String>> products) {
// //     final products = [
// //       {'id':'1','title': 'Summer Jacket', 'price': '100'},
// //       {'id':'2','title': 'Winter Hoodie', 'price': '120'},
// //       {'id':'3','title': 'Sneakers', 'price': '90'},
// //       {'id':'4','title': 'Raincoat', 'price': '80'},
// //       {'id':'5','title': 'Summer Jacket', 'price': '100'},
// //       {'id':'6','title': 'Winter Hoodie', 'price': '120'},
// //       {'id':'7','title': 'Sneakers', 'price': '90'},
// //     ];

// //     return GridView.count(
// //       key: ValueKey<int>(selectedFilterIndex),
// //       physics: const NeverScrollableScrollPhysics(),
// //       shrinkWrap: true,
// //       crossAxisCount: 2,
// //       crossAxisSpacing: 15,
// //       mainAxisSpacing: 20,
// //       childAspectRatio: 0.76,
// //       children: products.map((product) {
// //         return Container();
// // //         ProductCard(
// // //           productId: int.parse(product['id'].toString()),
// // //           imagePath:
// // //               "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
// // //           title: product['title']!,
// // //           price: product['price']!,
// // //           rating: double.parse(product['rating'] ?? '4'),
// // //           oldPrice: product['price']!,
// // //           onTap: () {},
// // //          onTapWishlist: () {
// // //   Get.find<WishlistController>().toggleWishlist(product.id);
// // // },
// // // isFavorite: Get.find<WishlistController>().isFavorite(int.parse(product.id)),

// // //         );
// //       }).toList(),
// //     );
// //   }
// }


class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  int selectedFilterIndex = 0;
  late WishlistController wishlistController;

  final List<String> filters = ['All', 'Newest', 'Popular', 'Man', 'Woman', 'Unisex'];

  @override
  void initState() {
    super.initState();
    wishlistController = Get.find<WishlistController>();
    // Load wishlist when screen opens
    wishlistController.loadWishlist();
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
          // Add wishlist count badge
          GetBuilder<WishlistController>(
            builder: (controller) {
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
                      '${controller.wishlistCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
                  child: _buildProductGrid(controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(WishlistController controller) {
    final String selectedFilter = filters[selectedFilterIndex];
    final List<Map<String, dynamic>> filteredProducts = 
        controller.getFilteredWishlistItems(selectedFilter);

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
          ],
        ),
      );
    }

    return GridView.builder(
      key: selectedFilterIndex == null ? null : ValueKey<int>(selectedFilterIndex),
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
        final imageUrl = (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
    ? product['imageUrls'][0]
    : 'https://via.placeholder.com/200';
        
        return ProductCard(
          productId: product['id'],
          imagePath: imageUrl,
          title: product['title'] ?? 'Unknown Product',
          price: product['price']?.toString() ?? '0',
          rating: (product['rating'] ?? 4.0).toDouble(),
          oldPrice: product['oldPrice']?.toString() ?? '0',
          onTap: () {
            Get.to(() => ProductDetail(product: product['id']),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 500));
          },
        );
      },
    );
  }
}