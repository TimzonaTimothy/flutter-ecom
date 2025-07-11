import 'dart:convert';

import 'package:get/get.dart';

import '../../base/utils/my_request.dart';

class WishlistController extends GetxController {
  final RxSet<int> favoriteProductIds = <int>{}.obs;
  final RxList<Map<String, dynamic>> wishlistItems =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    // loadWishlist();
    super.onInit();
  }

  Future<void> toggleWishlist(int productId) async {
    try {
      final request = MyRequest('wishlist/toggle/?id=$productId', {}, true);
      final data = await request.postApi();

      final response = request.returnResponse();
      if (response == null) {
        update();
        return;
      }

      if (response.statusCode == 201) {
        favoriteProductIds.add(productId);
        // await loadWishlist(); // Reload
      } else if (response.statusCode == 204) {
        favoriteProductIds.remove(productId);
        wishlistItems.removeWhere((item) => item['id'] == productId);
      }

      update(); // Update UI
    } catch (e) {
      print("Error toggling wishlist: $e");
    }
  }

  // Future<void> loadWishlist() async {
  //   try {
  //     isLoading.value = true;
  //     final data = await MyRequest('wishlist/me/', {}, true).getApi();

  //     if (data != null) {
  //       final List<dynamic> wishlistData = jsonDecode(data);

  //       // Clear existing data
  //       favoriteProductIds.clear();
  //       wishlistItems.clear();

  //       // Process wishlist items
  //       for (var item in wishlistData) {
  //         Map<String, dynamic> processedItem = {};

  //         // Extract product data based on your API response structure
  //         if (item['product'] != null) {
  //           // If the API returns wishlist items with product nested inside
  //           processedItem = {
  //             'id': item['product']['id'],
  //             'wishlistId': item['id'], // The wishlist item ID
  //             'title': item['product']['title'] ?? 'Unknown Product',
  //             'price': item['product']['price'] ??
  //                 item['product']['originalPrice'] ??
  //                 '0',
  //             'oldPrice': item['product']['oldPrice'] ??
  //                 item['product']['discountPrice'] ??
  //                 '0',
  //             'rating': item['product']['rating'] ?? 4.0,
  //             'imageUrl': item['product']['imageUrl'] ??
  //                 (item['product']['imageUrls'] != null &&
  //                         item['product']['imageUrls'].isNotEmpty
  //                     ? item['product']['imageUrls'][0]
  //                     : 'https://via.placeholder.com/200'),
  //             'category': item['product']['category'] ?? 'unisex',
  //             'description': item['product']['description'] ?? '',
  //             'createdAt':
  //                 item['created_at'] ?? DateTime.now().toIso8601String(),
  //           };

  //           favoriteProductIds.add(item['product']['id']);
  //         } else {
  //           // If the API returns different structure
  //           processedItem = {
  //             'id': item['productId'] ?? item['product_id'] ?? item['id'],
  //             'wishlistId': item['id'],
  //             'title': item['title'] ?? 'Unknown Product',
  //             'price': item['price'] ?? '0',
  //             'oldPrice': item['oldPrice'] ?? '0',
  //             'rating': item['rating'] ?? 4.0,
  //             'imageUrl': item['imageUrl'] ?? 'https://via.placeholder.com/200',
  //             'category': item['category'] ?? 'unisex',
  //             'description': item['description'] ?? '',
  //             'createdAt':
  //                 item['created_at'] ?? DateTime.now().toIso8601String(),
  //           };

  //           favoriteProductIds.add(processedItem['id']);
  //         }

  //         wishlistItems.add(processedItem);
  //       }

  //       update();
  //     }
  //   } catch (e) {
  //     print("Error loading wishlist: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  bool isFavorite(int productId) => favoriteProductIds.contains(productId);

  // Helper method to get wishlist count
  int get wishlistCount => favoriteProductIds.length;

  // Helper method to get wishlist items
  List<Map<String, dynamic>> get allWishlistItems => wishlistItems.toList();

  // Helper method to get filtered wishlist items
  List<Map<String, dynamic>> getFilteredWishlistItems(String? filter) {
    if (filter == null || filter.isEmpty || filter.toLowerCase() == 'all') {
      return wishlistItems.toList();
    }

    return wishlistItems.where((item) {
      switch (filter.toLowerCase()) {
        case 'newest':
          return true; // You can sort by createdAt if needed
        case 'popular':
          return (item['rating'] ?? 0) >= 4.0;
        case 'man':
        case 'men':
          return (item['category'] ?? '').toLowerCase().contains('man') ||
              (item['category'] ?? '').toLowerCase().contains('men');
        case 'woman':
        case 'women':
          return (item['category'] ?? '').toLowerCase().contains('woman') ||
              (item['category'] ?? '').toLowerCase().contains('women');
        case 'unisex':
          return (item['category'] ?? '').toLowerCase().contains('unisex');
        default:
          return true;
      }
    }).toList();
  }

  // Helper method to clear all wishlist items
  void clearWishlist() {
    favoriteProductIds.clear();
    wishlistItems.clear();
    update();
  }

  // Helper method to remove specific item from wishlist
  Future<void> removeFromWishlist(int productId) async {
    await toggleWishlist(productId);
  }

  // Helper method to refresh wishlist
  // Future<void> refreshWishlist() async {
  //   await loadWishlist();
  // }
}
