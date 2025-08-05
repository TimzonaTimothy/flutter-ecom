import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';

import '../../base/utils/my_request.dart';
import '../models/cart_model.dart';
import '../models/create_cart_model.dart';



class CartController extends GetxController {
  static CartController get to => Get.find();

  var cartItems = <CartModel>[].obs;
  bool _isLoading = false;
  String? _errorMessage;

  var isLoading = false.obs;
  String? get errorMessage => _errorMessage;
  int get cartItemCount => cartItems.length;

  int get totalQuantity => cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 0));

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      if (item.product != null) {
        double price = 0.0;
        if (item.product!.discountPrice != null) {
          price = double.tryParse(item.product!.discountPrice!) ?? 0.0;
        } else if (item.product!.originalPrice != null) {
          price = double.tryParse(item.product!.originalPrice!) ?? 0.0;
        }
        return sum + (price * (item.quantity ?? 0));
      }
      return sum;
    });
  }

  /// Fetch cart items from the API
  Future<bool> fetchCartItems() async {
    try {
      isLoading.value = true;
      _errorMessage = null;
      
      log('Fetching cart items...');
      
      final response = await MyRequest(
        'cart/me/',
        {},
        true, // auth required
        200, // success code
      ).getApi();

      await Future.delayed(const Duration(seconds: 2));

      if (response != null) {
        
        final List<dynamic> jsonList = jsonDecode(response);
        cartItems.value = jsonList.map((json) => CartModel.fromJson(json)).toList();
        
        log('Successfully fetched ${cartItems.length} cart items');
        isLoading.value = false;
        return true;
      } else {
        _errorMessage = 'Failed to fetch cart items';
        log('Failed to fetch cart items: response is null');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching cart items: $e';
      log('Error fetching cart items: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Add item to cart
  Future<bool> addToCart(CreateCartModel cartItem) async {
    try {
      isLoading.value = true;
      _errorMessage = null;
      
      log('Adding item to cart: ${cartItem.toJson()}');
      
      final response = await MyRequest(
        'cart/add/',
        cartItem.toJson(),
        true, // auth required
        201, // created status code
      ).postApi();

      if (response != null) {
        log('Item added to cart successfully');
        // Refresh cart items after adding
        await fetchCartItems();
        return true;
      } else {
        _errorMessage = 'Failed to add item to cart';
        log('Failed to add item to cart: response is null');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding item to cart: $e';
      log('Error adding item to cart: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Update cart item quantity with optimistic updates
  Future<bool> updateCartItem(int cartId, int quantity) async {
    try {
      // Find the cart item index
      final itemIndex = cartItems.indexWhere((item) => item.id == cartId);
      if (itemIndex == -1) {
        _errorMessage = 'Cart item not found';
        return false;
      }

      // Store the original quantity for rollback
      final originalQuantity = cartItems[itemIndex].quantity;
      
      // Update locally first (optimistic update)
      cartItems[itemIndex] = cartItems[itemIndex].copyWith(quantity: quantity);
      cartItems.refresh(); // Trigger UI update
      
      log('Updating cart item $cartId with quantity $quantity');
      
      // Update on server in background
      final response = await MyRequest(
        'cart/update/$cartId/',
        {'quantity': quantity},
        true, // auth required
        200, // success code
      ).patchApi();

      if (response != null) {
        log('Cart item updated successfully');
        return true;
      } else {
        // Rollback on failure
        cartItems[itemIndex] = cartItems[itemIndex].copyWith(quantity: originalQuantity);
        cartItems.refresh();
        _errorMessage = 'Failed to update cart item';
        log('Failed to update cart item: response is null');
        return false;
      }
    } catch (e) {
      // Rollback on error
      final itemIndex = cartItems.indexWhere((item) => item.id == cartId);
      if (itemIndex != -1) {
        // You'd need to store the original quantity before the try block
        // For now, we'll just refresh from server
        fetchCartItems();
      }
      _errorMessage = 'Error updating cart item: $e';
      log('Error updating cart item: $e');
      return false;
    }
  }

  /// Remove item from cart with optimistic updates
  Future<bool> removeFromCart(int cartId) async {
    try {
      // Find the cart item index
      final itemIndex = cartItems.indexWhere((item) => item.id == cartId);
      if (itemIndex == -1) {
        _errorMessage = 'Cart item not found';
        return false;
      }

      // Store the item for rollback
      final removedItem = cartItems[itemIndex];
      
      // Remove locally first (optimistic update)
      cartItems.removeAt(itemIndex);
      
      log('Removing cart item $cartId');
      
      // Remove on server in background
      final response = await MyRequest(
        'cart/delete/$cartId/',
        {'id': cartId},
        true, // auth required
        204, // no content status code for delete
      ).deleteApi();

      if (response != null) {
        log('Cart item removed successfully');
        return true;
      } else {
        // Rollback on failure
        cartItems.insert(itemIndex, removedItem);
        _errorMessage = 'Failed to remove cart item';
        log('Failed to remove cart item: response is null');
        return false;
      }
    } catch (e) {
      // Refresh from server on error
      fetchCartItems();
      _errorMessage = 'Error removing cart item: $e';
      log('Error removing cart item: $e');
      return false;
    }
  }

  /// Clear all cart items
  Future<bool> clearCart() async {
    try {
      isLoading.value = true;
      _errorMessage = null;
      
      log('Clearing cart...');
      
      final response = await MyRequest(
        'cart/clear/',
        {},
        true, // auth required
        200, // success code
      ).deleteApi();

      if (response != null) {
        log('Cart cleared successfully');
        cartItems.clear();
        isLoading.value = false;
        return true;
      } else {
        _errorMessage = 'Failed to clear cart';
        log('Failed to clear cart: response is null');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error clearing cart: $e';
      log('Error clearing cart: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Get cart item by product ID
  CartModel? getCartItemByProductId(int productId) {
    try {
      return cartItems.firstWhere(
        (item) => item.product?.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool isProductInCart(int productId) {
    return cartItems.any((item) => item.product?.id == productId);
  }

  /// Get quantity of specific product in cart
  int getProductQuantityInCart(int productId) {
    final cartItem = getCartItemByProductId(productId);
    return cartItem?.quantity ?? 0;
  }

  /// Clear local cart data (useful for logout)
  void clearLocalCart() {
    cartItems.clear();
    _errorMessage = null;
    isLoading.value = false;
  }
}