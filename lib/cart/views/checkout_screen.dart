import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';
import 'shipping_address_screen.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          horizontalPadding: 130,
          text: 'Continue',
          onTap: () {
              Get.to(
              const ShippingAddressScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Text("Shipping Address", style: AppStyles.headLineStyle3),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppStyles.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Home",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      "1901 Thornridge Cir. Shiloh, Hawaii 81063",
                      style: AppStyles.textStyle,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text("CHANGE",
                    style: AppStyles.headLineStyle4
                        .copyWith(color: AppStyles.primaryColor)),
              )
            ],
          ),
          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          Text("Choose Shipping Type", style: AppStyles.headLineStyle3),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  color: AppStyles.primaryColor),
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
                onPressed: () {},
                child: Text(
                  "CHANGE",
                  style: AppStyles.headLineStyle4
                      .copyWith(color: AppStyles.primaryColor),
                ),
              )
            ],
          ),
          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          const Text("Order List",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._buildOrderItems(),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems() {
    final orders = [
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
      {
        "title": "Brown Suite",
        "size": "XL",
        "price": "\$120",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
      {
        "title": "Brown Suite",
        "size": "XL",
        "price": "\$120",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image":
            "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
      },
    ];

    return orders
        .map(
          (item) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['image']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("Size: ${item['size']}"),
                      const SizedBox(height: 4),
                      Text(item['price']!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
