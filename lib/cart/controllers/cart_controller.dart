import 'dart:convert';
import 'dart:developer';

import '../../base/utils/my_request.dart';
import '../models/cart_model.dart';
import '../models/create_cart_model.dart';

class CartController {
  static final CartController _instance = CartController._internal();
  factory CartController() => _instance;
  CartController._internal();

  static CartController get instance => _instance;

  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cartItemCount => _cartItems.length;
  
  // Calculate total quantity of all items
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  
  // Calculate total price (using discount price if available, otherwise original price)
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
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
      _isLoading = true;
      _errorMessage = null;
      
      log('Fetching cart items...');
      
      final response = await MyRequest(
        'cart/me/',
        {},
        true, // auth required
        200, // success code
      ).getApi();

      if (response != null) {
        log('Cart response: $response');
        
        final List<dynamic> jsonList = jsonDecode(response);
        _cartItems = jsonList.map((json) => CartModel.fromJson(json)).toList();
        
        log('Successfully fetched ${_cartItems.length} cart items');
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'Failed to fetch cart items';
        log('Failed to fetch cart items: response is null');
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching cart items: $e';
      log('Error fetching cart items: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Add item to cart
  Future<bool> addToCart(CreateCartModel cartItem) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      
      log('Adding item to cart: ${cartItem.toJson()}');
      
      final response = await MyRequest(
        'cart/',
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
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding item to cart: $e';
      log('Error adding item to cart: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItem(int cartId, int quantity) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      
      log('Updating cart item $cartId with quantity $quantity');
      
      final response = await MyRequest(
        'cart/$cartId/',
        {'quantity': quantity},
        true, // auth required
        200, // success code
      ).patchApi();

      if (response != null) {
        log('Cart item updated successfully');
        // Refresh cart items after updating
        await fetchCartItems();
        return true;
      } else {
        _errorMessage = 'Failed to update cart item';
        log('Failed to update cart item: response is null');
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating cart item: $e';
      log('Error updating cart item: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int cartId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      
      log('Removing cart item $cartId');
      
      final response = await MyRequest(
        'cart/$cartId/',
        {},
        true, // auth required
        204, // no content status code for delete
      ).deleteApi();

      if (response != null) {
        log('Cart item removed successfully');
        // Refresh cart items after removing
        await fetchCartItems();
        return true;
      } else {
        _errorMessage = 'Failed to remove cart item';
        log('Failed to remove cart item: response is null');
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error removing cart item: $e';
      log('Error removing cart item: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Clear all cart items
  Future<bool> clearCart() async {
    try {
      _isLoading = true;
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
        _cartItems.clear();
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'Failed to clear cart';
        log('Failed to clear cart: response is null');
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error clearing cart: $e';
      log('Error clearing cart: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Get cart item by product ID
  CartModel? getCartItemByProductId(int productId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.product?.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool isProductInCart(int productId) {
    return _cartItems.any((item) => item.product?.id == productId);
  }

  /// Get quantity of specific product in cart
  int getProductQuantityInCart(int productId) {
    final cartItem = getCartItemByProductId(productId);
    return cartItem?.quantity ?? 0;
  }

  /// Clear local cart data (useful for logout)
  void clearLocalCart() {
    _cartItems.clear();
    _errorMessage = null;
    _isLoading = false;
  }
}