import 'dart:convert';

import 'package:get/get.dart';

import '../../base/res/base_url.dart';
import '../../base/utils/my_request.dart';
import '../../base/utils/snackbar.dart';
import '../../base/utils/token.dart';
import '../models/wishlist_model.dart';
import 'package:http/http.dart' as http;

class WishlistController extends GetxController {
  final RxSet<int> favoriteProductIds = <int>{}.obs;
  final RxList<WishlistModel> wishlistItems = <WishlistModel>[].obs;
  final RxBool isLoading = false.obs;
  final String fullUrl = baseUrl;

  int get wishlistCount => wishlistItems.length;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;

    String? authToken = getToken();
    try {
      final response = await http.get(
        Uri.parse('$fullUrl/wishlist/me/'), 
        headers: {
          "Authorization": 'Bearer $authToken',
        },
      );
      await Future.delayed(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle both paginated and direct array responses
        List<dynamic> data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('results')) {
          data = responseData['results'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          print("Unexpected wishlist response format: ${responseData.runtimeType}");
          return;
        }

        wishlistItems.value = data.map((item) => WishlistModel.fromJson(item)).toList();
        favoriteProductIds.value = wishlistItems.map((e) => e.id!).toSet();
      } else {
        print("Error fetching wishlist: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error loading wishlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWishlist() async {
    await fetchWishlist();
  }
  final Map<String, String> filterMap = {
  'Man': 'men',
  'Woman': 'women',
  'Unisex': 'unisex',
};

  List<WishlistModel> getFilteredWishlistItems(String filter) {
  if (filter == 'All') return wishlistItems;

  final mappedFilter = filterMap[filter]?.toLowerCase() ?? filter.toLowerCase();

  return wishlistItems.where((item) {
    final type = item.productType?.toLowerCase() ?? '';
    return type.contains(mappedFilter);
  }).toList();
}

  bool isFavorite(int productId) => favoriteProductIds.contains(productId);

  void toggleWishlist(int productId) async {
    // Use the same endpoint structure that works
    final url = Uri.parse('$fullUrl/wishlist/toggle/?id=$productId');
    String? authToken = getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": 'Bearer $authToken',
        },
      );

      if (response.statusCode == 201) {
        // Product added to wishlist
        favoriteProductIds.add(productId);
        await fetchWishlist(); 
        // showSuccessSnackbar('Product added to wishlist');
      } else if (response.statusCode == 204) {
        // Product removed from wishlist
        favoriteProductIds.remove(productId);
        wishlistItems.removeWhere((item) => item.id == productId);
        // showSuccessSnackbar('Product removed from wishlist');
      } else {
        // Handle error responses
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? 'Failed to update wishlist';
          showFailureSnackbar(errorMessage);
        } catch (e) {
          showFailureSnackbar('Failed to update wishlist');
        }
        print("Wishlist toggle error: ${response.statusCode} - ${response.body}");
      }
      update();
    } catch (e) {
      print("Error toggling wishlist: $e");
      showFailureSnackbar('Network error. Please try again.');
    }
  }

  // Method to clear wishlist (useful for logout)
  void clearWishlist() {
    favoriteProductIds.clear();
    wishlistItems.clear();
    update();
  }

  // Method to get wishlist item by product ID
  WishlistModel? getWishlistItemByProductId(int productId) {
    try {
      return wishlistItems.firstWhere((item) => item.id == productId);
    } catch (e) {
      return null;
    }
  }
}