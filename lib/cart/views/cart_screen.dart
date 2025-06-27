import 'package:ecom_app/base/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../home/views/home_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {
      "title": "Men Blue Dial Analogue Watch - FCN00046H",
      "price": 83.97,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Suite",
      "price": 120.00,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Jacket",
      "price": 83.97,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Suite",
      "price": 120.00,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Jacket",
      "price": 83.97,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Suite",
      "price": 120.00,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
    {
      "title": "Brown Jacket",
      "price": 83.97,
      "size": "XL",
      "image":
          "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      "quantity": 1,
    },
  ];

  final double deliveryFee = 25.00;
  final double discount = 35.00;

  double getCartSubTotal() {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.to(
              const HomeScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: ValueKey(item['title']),
                  background: Container(
                    color: Colors.redAccent.shade100,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: AppStyles.bgColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          title: const Text("Confirm Delete"),
                          content: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['image']?.toString() ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'] ?? '',
                                        style: AppStyles.textStyle.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Size: ${item['size']}",
                                      style: AppStyles.textStyle.copyWith(
                                          color: AppStyles.whiteSmokeColor,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      "Price: \$${item['price']}",
                                      style: AppStyles.textStyle.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancel",
                                  style: AppStyles.textStyle
                                      .copyWith(color: AppStyles.primaryColor)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("Delete",
                                  style: AppStyles.textStyle
                                      .copyWith(color: AppStyles.whiteColor)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm != true) {
                      setState(() {});
                    } else {
                      setState(() {
                        cartItems.removeAt(index);
                      });

                      showSuccessSnackbar("${item['title']} removed from cart");
                    }
                    return null;
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item['image']?.toString() ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']?.toString() ?? '',
                                    style: AppStyles.textStyle
                                        .copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text("Size: ${item['size']}",
                                      style: AppStyles.textStyle.copyWith(
                                          color: AppStyles.whiteSmokeColor,
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text("\$${item['price']}",
                                      style: AppStyles.textStyle.copyWith(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (cartItems[index]['quantity'] > 1) {
                                        cartItems[index]['quantity']--;
                                      }
                                    });
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                      cartItems[index]['quantity'].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cartItems[index]['quantity']++;
                                    });
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
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(
                          color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
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
                      border: Border.all(color: AppStyles.whiteSmokeColor)),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Promo Code",
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Apply",
                              style: AppStyles.textStyle
                                  .copyWith(color: AppStyles.whiteColor)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildPriceRow(
                  "Sub-Total",
                  // "\$407.94",
                  "\$${getCartSubTotal().toStringAsFixed(2)}",
                ),
                _buildPriceRow("Delivery Fee", "\$$deliveryFee"),
                _buildPriceRow("Discount", "\$$discount"),
                Divider(color: AppStyles.whiteSmokeColor.withOpacity(0.2)),
                _buildPriceRow("Total Cost",
                    "\$${(getCartSubTotal() + deliveryFee - discount).toStringAsFixed(2)}",
                    // "\$397.94",
                    isBold: true),
                const SizedBox(height: 20),
                PrimaryButton(
                  verticalPadding: 10,
                  horizontalPadding: 10,
                  text: 'Proceed to checkout',
                  onTap: () {
                    
                    Get.to(
                    const CheckoutPage(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                  );
                  },
                ),
              ],
            ),
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
          Text(label,
              style: AppStyles.textStyle.copyWith(color: AppStyles.greColor)),
          Text(value,
              style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
