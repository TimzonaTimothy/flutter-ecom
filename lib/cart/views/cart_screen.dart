import 'package:ecom_app/base/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../home/views/home_screen.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import 'checkout_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
   late CartController cartController;

  final TextEditingController promoCodeController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    cartController = Get.put(CartController());
    // Fetch cart items when screen loads
    _loadCartItems();
  }

  // Future<void> _loadCartItems() async {
  //   await cartController.fetchCartItems();
  //   setState(() {});
  // }



 Future<void> _updateQuantity(int cartId, int newQuantity) async {
  if (newQuantity < 1) return;

  final success = await cartController.updateCartItem(cartId, newQuantity);
  if (!success) {
    showFailureSnackbar(cartController.errorMessage ?? "Failed to update quantity");
  }
  // No need for setState() - GetX will handle UI updates automatically
}

Future<void> _removeItem(CartModel item) async {
  if (item.id == null) return;
  
  final success = await cartController.removeFromCart(item.id!);
  if (success) {
    showSuccessSnackbar("${item.product?.title ?? 'Item'} removed from cart");
  } else {
    showFailureSnackbar(cartController.errorMessage ?? "Failed to remove item");
  }
  // No need for setState() - GetX will handle UI updates automatically
}

Future<void> _loadCartItems() async {
  await cartController.fetchCartItems();
  // No need for setState() - GetX will handle UI updates automatically
}

  double getCartSubTotal() => cartController.totalPrice;

  String getImageUrl(CartModel item) {
    // Try to get image from imageUrls first, then from images
    if (item.product?.imageUrls != null && item.product!.imageUrls!.isNotEmpty) {
      return item.product!.imageUrls!.first;
    } else if (item.product?.imageUrls != null && item.product!.imageUrls!.isNotEmpty) {
      return item.product!.imageUrls!.first ?? '';
    }
    return '';
  }

  double parsePrice(String priceString) {
  // Remove currency symbols and commas
  final cleaned = priceString.replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned) ?? 0.0;
}

double getItemPrice(CartModel item) {
  if (item.product?.discountPrice != null) {
    return parsePrice(item.product!.discountPrice!);
  } else if (item.product?.originalPrice != null) {
    return parsePrice(item.product!.originalPrice!);
  }
  return 0.0;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("My Cart", style: AppStyles.headLineStyle2),
        centerTitle: true,
        actions: [
          if (cartController.cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCartItems,
            ),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
    return  Center(child: CircularProgressIndicator(color: AppStyles.primaryColor,));
  }

  if (cartController.cartItems.isEmpty) {
    return _buildEmptyCart();
  
        } return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppStyles.primaryColor,
                        onRefresh: _loadCartItems,
                        child: ListView.builder(
                          itemCount: cartController.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartController.cartItems[index];
                            return Dismissible(
                              key: ValueKey(item.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                return await _showDeleteConfirmation(item);
                              },
                              child: _buildCartItem(item, index),
                            );
                          },
                        ),
                      ),
                    ),
                    _buildCartSummary(),
                  ],
                );
  }),);
  }

  Widget _buildEmptyCart() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: AppStyles.whiteSmokeColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: AppStyles.headLineStyle3,
            ),
            const SizedBox(height: 8),
            Text(
              "Add items to get started",
              style: AppStyles.textStyle.copyWith(
                color: AppStyles.whiteSmokeColor,
              ),
            ),
            const SizedBox(height: 20),
            // PrimaryButton(
            //   horizontalPadding: 10,
            //   text: "Continue Shopping",
            //   onTap: (){
            //     Get.to(
            //       const BottomNavBar(),
            //       transition: Transition.rightToLeftWithFade,
            //       duration: const Duration(milliseconds: 500),
            //     );
            //   }
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartModel item, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  getImageUrl(item),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: AppStyles.whiteSmokeColor,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppStyles.textColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product?.title ?? 'Unknown Product',
                      style: AppStyles.textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (item.size != null)
                      Text(
                        "Size: ${item.size}",
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 12,
                        ),
                      ),
                    if (item.color != null)
                      Text(
                        "Color: ${item.color}",
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.product?.discountPrice != null && 
                            item.product?.originalPrice != null)
                          Text(
                            "\$${item.product!.originalPrice}",
                            style: AppStyles.textStyle.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppStyles.whiteSmokeColor,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          "\$${getItemPrice(item).toStringAsFixed(2)}",
                          style: AppStyles.textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.product?.discountPrice != null 
                                ? AppStyles.primaryColor 
                                : AppStyles.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildQuantityControls(item),
            ],
          ),
        ),
        Divider(color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildQuantityControls(CartModel item) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (item.quantity != null && item.quantity! > 1 && item.id != null) {
              _updateQuantity(item.id!, item.quantity! - 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppStyles.whiteSmokeColor,
            ),
            child: Icon(
              Icons.remove,
              size: 18,
              color: AppStyles.textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            item.quantity?.toString() ?? '0',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (item.quantity != null && item.id != null) {
              _updateQuantity(item.id!, item.quantity! + 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppStyles.primaryColor,
            ),
            child: Icon(
              Icons.add,
              size: 18,
              color: AppStyles.whiteColor,
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyles.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppStyles.whiteSmokeColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoCodeController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Promo Code",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle promo code application
                      final promoCode = promoCodeController.text.trim();
                      if (promoCode.isNotEmpty) {
                        // Implement promo code logic here
                        showSuccessSnackbar("Promo code applied!");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Apply",
                      style: AppStyles.textStyle.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceRow(
            "Sub-Total",
            "\$${getCartSubTotal().toStringAsFixed(2)}",
          ),
          const SizedBox(height: 8),
          const Text('Shipping and tax are shown at checkout.'),
          const SizedBox(height: 20),
          PrimaryButton(
            verticalPadding: 10,
            horizontalPadding: 10,
            text: 'Proceed to checkout',
            onTap: () {
              if (cartController.cartItems.isNotEmpty) {
                Get.to(
                  const CheckoutPage(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                );
              } else {
                showFailureSnackbar("Your cart is empty");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.textStyle.copyWith(color: AppStyles.greColor),
          ),
          Text(
            value,
            style: AppStyles.textStyle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(CartModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppStyles.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Confirm Delete"),
          content: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  getImageUrl(item),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: AppStyles.whiteSmokeColor,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppStyles.textColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product?.title ?? 'Unknown Product',
                      style: AppStyles.textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.size != null)
                      Text(
                        "Size: ${item.size}",
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      "Price: \$${getItemPrice(item).toStringAsFixed(2)}",
                      style: AppStyles.textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Delete",
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.whiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _removeItem(item);
    }
    return false; // Always return false to prevent automatic dismissal
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }
}