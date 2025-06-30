import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import 'track_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> cancelledOrders = [
    {
      "title": "Brown Jacket",
      "image": AppMedia.onborading2,
      "size": "XL",
      "qty": 10,
      "price": 83.97,
    },
    {
      "title": "Brown Suite",
      "image": AppMedia.onborading1,
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
    {
      "title": "Brown Suite",
      "image": AppMedia.welcomeImage,
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
    {
      "title": "Brown Suite",
      "image": AppMedia.onborading3,
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
    {
      "title": "Brown Suite",
      "image": AppMedia.welcomeImage,
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
    {
      "title": "Brown Suite",
      "image": AppMedia.welcomeImage,
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("My Orders", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppStyles.primaryColor,
          unselectedLabelColor: AppStyles.greColor,
          indicatorColor: AppStyles.primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      body: TabBarView(
        controller: _tabController,
        children: [
          ActiveOrdersList(cancelledOrders: cancelledOrders,),
          CompletedOrdersList(cancelledOrders: cancelledOrders,),
          CancelledOrdersList(cancelledOrders: cancelledOrders),
        ],
      ),
    );
  }
}



class ActiveOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> cancelledOrders;

  const ActiveOrdersList({super.key, required this.cancelledOrders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cancelledOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = cancelledOrders[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      order['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(order['title'],
                            style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            "Size: ${order['size']}  |  Qty : ${order['qty']}pcs",
                            style: AppStyles.textStyle
                                .copyWith(color: AppStyles.greColor)),
                        const SizedBox(height: 4),
                        Text("\$${order['price']}",
                            style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor,fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      
                      Get.to(
               TrackOrderPage(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
                    },
                    child: Text('Track Order',
                        style: AppStyles.textStyle
                            .copyWith(color: AppStyles.whiteColor)),
                  ),
                ],
              ),
            ),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          ],
        );
      },
    );
  }
}



class CompletedOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> cancelledOrders;

  const CompletedOrdersList({super.key, required this.cancelledOrders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cancelledOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = cancelledOrders[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      order['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(order['title'],
                            style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            "Size: ${order['size']}  |  Qty : ${order['qty']}pcs",
                            style: AppStyles.textStyle
                                .copyWith(color: AppStyles.greColor)),
                        const SizedBox(height: 4),
                        Text("\$${order['price']}",
                            style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor,fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {},
                    child: Text('Leave Review',
                        style: AppStyles.textStyle
                            .copyWith(color: AppStyles.whiteColor)),
                  ),
                ],
              ),
            ),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          ],
        );
      },
    );
  }
}




class CancelledOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> cancelledOrders;

  const CancelledOrdersList({super.key, required this.cancelledOrders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cancelledOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = cancelledOrders[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      order['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(order['title'],
                            style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            "Size: ${order['size']}  |  Qty : ${order['qty']}pcs",
                            style: AppStyles.textStyle
                                .copyWith(color: AppStyles.greColor)),
                        const SizedBox(height: 4),
                        Text("\$${order['price']}",
                            style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor,fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {},
                    child: Text('Re-Order',
                        style: AppStyles.textStyle
                            .copyWith(color: AppStyles.whiteColor)),
                  ),
                ],
              ),
            ),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          ],
        );
      },
    );
  }
}
