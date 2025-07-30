import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../base/widgets/primary_button.dart';
import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';
import '../../order/views/payment_methods_screen.dart';
import 'shipping_address_screen.dart';
import 'shipping_type_screen.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late AddressController addressController;
  late CartController cartController;

  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController());
    cartController = Get.find<CartController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Checkout", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: PrimaryButton(
          verticalPadding: 10,
          horizontalPadding: 100,
          text: 'Continue',
          onTap: () {
            if (addressController.selectedAddress.value != null) {
              Get.to(
                const PaymentMethodsScreen(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500),
              );
            } else {
              showFailureSnackbar("Please select a shipping address");
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Text("Shipping Address", style: AppStyles.headLineStyle3),
          const SizedBox(height: 8),

          Obx(() {
            if (addressController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (addressController.addresses.isEmpty) {
              return _buildNoAddressWidget();
            }

            final selectedAddress = addressController.selectedAddress.value;
            if (selectedAddress == null) {
              return _buildNoAddressWidget();
            }

            return _buildAddressSection(selectedAddress);
          }),
          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          Text("Choose Shipping Type", style: AppStyles.headLineStyle3),
          const SizedBox(height: 8),
          _buildShippingTypeSection(),

          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          const Text("Order List",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // ..._buildOrderItems(),
          Obx(() => Column(
                children: _buildOrderItems(),
              )),
        ],
      ),
    );
  }

  Widget _buildAddressSection(AddressModel address) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: AppStyles.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    address.displayAddressType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Default",
                        style: AppStyles.textStyle.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                address.address,
                style: AppStyles.textStyle,
              ),
              Text(
                "Phone: ${address.phone}",
                style: AppStyles.textStyle.copyWith(
                  fontSize: 12,
                  color: AppStyles.whiteSmokeColor,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            final result = await Get.to(
              const ShippingAddressScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );

            // Refresh if address was changed
            if (result == true) {
              await addressController.fetchAddresses();
            }
          },
          child: Text(
            "CHANGE",
            style: AppStyles.headLineStyle4
                .copyWith(color: AppStyles.primaryColor),
          ),
        )
      ],
    );
  }

  Widget _buildNoAddressWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppStyles.whiteSmokeColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppStyles.whiteSmokeColor,
          ),
          const SizedBox(height: 8),
          Text(
            "No shipping address found",
            style: AppStyles.textStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Please add a shipping address to continue",
            style: AppStyles.textStyle.copyWith(
              color: AppStyles.whiteSmokeColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              final result = await Get.to(
                const ShippingAddressScreen(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500),
              );

              if (result == true) {
                await addressController.fetchAddresses();
              }
            },
            child: Text(
              "ADD ADDRESS",
              style: AppStyles.headLineStyle4
                  .copyWith(color: AppStyles.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTypeSection() {
    return Row(
      children: [
        Icon(Icons.local_shipping_outlined, color: AppStyles.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Economy",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text("Estimated Arrival  25 August 2023",
                  style: AppStyles.textStyle),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Get.to(
              const ShippingType(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
          child: Text(
            "CHANGE",
            style: AppStyles.headLineStyle4
                .copyWith(color: AppStyles.primaryColor),
          ),
        )
      ],
    );
  }

  List<Widget> _buildOrderItems() {
    return cartController.cartItems.map((item) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _getImageUrl(item),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppStyles.whiteSmokeColor,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppStyles.textColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product?.title ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.size != null) Text("Size: ${item.size}"),
                  if (item.color != null) Text("Color: ${item.color}"),
                  Text("Qty: ${item.quantity ?? 0}"),
                  const SizedBox(height: 4),
                  Text(
                    "\$${_getItemPrice(item).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getImageUrl(CartModel item) {
    if (item.product?.imageUrls != null &&
        item.product!.imageUrls!.isNotEmpty) {
      return item.product!.imageUrls!.first;
    }
    return '';
  }

  double _getItemPrice(CartModel item) {
    if (item.product?.discountPrice != null) {
      return double.tryParse(item.product!.discountPrice!) ?? 0.0;
    } else if (item.product?.originalPrice != null) {
      return double.tryParse(item.product!.originalPrice!) ?? 0.0;
    }
    return 0.0;
  }
}
