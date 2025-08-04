import 'package:ecom_app/base/res/media.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../base/res/styles/app_styles.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';
import 'review_screen.dart';

// class TrackOrderPage extends StatelessWidget {
//   const TrackOrderPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Track Order", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//       ),
//       backgroundColor: AppStyles.bgColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Product Card
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Image.asset(
//                   AppMedia.welcomeImage,
//                   height: 100,
//                   width: 100,
//                   fit: BoxFit.cover,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Brown Suite",
//                           style: AppStyles.headLineStyle3
//                               .copyWith(fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Size: XL | Qty: 10pcs",
//                         style: AppStyles.textStyle
//                             .copyWith(color: AppStyles.greColor),
//                       ),
//                       const SizedBox(height: 4),
//                       Text("\$120",
//                           style: AppStyles.headLineStyle4.copyWith(
//                               color: AppStyles.blackColor,
//                               fontWeight: FontWeight.w600)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             Divider(
//                 color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
//             const SizedBox(height: 20),

//             // Order Details
//             Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Order Details",
//                   style: AppStyles.headLineStyle3,
//                 )),
//             const SizedBox(
//               height: 15,
//             ),
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Expected Delivery Date"),
//                 Text("03 Sep 2023",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 10),
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Tracking ID"),
//                 Text("TRK452126542",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(
//               height: 15,
//             ),

//             Divider(
//                 color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),

//             // Order Status
//             Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Order Status",
//                   style: AppStyles.headLineStyle3,
//                 )),
//             const SizedBox(
//               height: 15,
//             ),
//             Column(
//               children: [
//                 _buildTimelineTile(
//                   isFirst: true,
//                   isLast: false,
//                   title: "Order Placed",
//                   date: "23 Aug 2023, 04:25 PM",
//                   isActive: true,
//                   icon: Icons.receipt_long,
//                 ),
//                 _buildTimelineTile(
//                   isFirst: false,
//                   isLast: false,
//                   title: "In Progress",
//                   date: "23 Aug 2023, 03:54 PM",
//                   isActive: true,
//                   icon: Icons.local_shipping_outlined,
//                 ),
//                 _buildTimelineTile(
//                   isFirst: false,
//                   isLast: false,
//                   title: "Shipped",
//                   date: "Expected 02 Sep 2023",
//                   isActive: false,
//                   icon: Icons.local_shipping,
//                 ),
//                 _buildTimelineTile(
//                   isFirst: false,
//                   isLast: true,
//                   title: "Delivered",
//                   date: "23 Aug 2023, 2023",
//                   isActive: false,
//                   icon: Icons.inventory,
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimelineTile({
//     required bool isFirst,
//     required bool isLast,
//     required String title,
//     required String date,
//     required bool isActive,
//     required IconData icon,
//   }) {
//     return TimelineTile(
//       isFirst: isFirst,
//       isLast: isLast,
//       indicatorStyle: IndicatorStyle(
//         width: 30,
//         color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
//         iconStyle: IconStyle(
//           iconData: isActive ? Icons.check : Icons.circle_outlined,
//           color: Colors.white,
//         ),
//       ),
//       beforeLineStyle: LineStyle(
//         color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
//         thickness: 2,
//       ),
//       endChild: ListTile(
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(date),
//         trailing:
//             Icon(icon, color: isActive ? AppStyles.primaryColor : Colors.grey),
//       ),
//     );
//   }
// }


class TrackOrderPage extends StatelessWidget {
  final int? orderId;

  const TrackOrderPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Track Order #${orderId ?? 'N/A'}", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      body: FutureBuilder<OrderModel?>(
        future: OrderService.getOrderDetails(orderId ?? 0), // Fetch order details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError
                        ? 'Error loading order details: ${snapshot.error}'
                        : 'Order not found',
                    style: AppStyles.textStyle.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Go Back',
                      style: AppStyles.textStyle.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          final firstProduct = order.orderProducts.isNotEmpty ? order.orderProducts.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Product Card
                if (firstProduct != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      firstProduct.imageUrls.isNotEmpty
                          ? Image.network(
                              firstProduct.imageUrls.first,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                AppMedia.welcomeImage,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              AppMedia.welcomeImage,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstProduct.title ?? 'Unknown Product',
                              style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Size: ${firstProduct.sizes ?? 'N/A'} | Qty: ${firstProduct.quantity ?? 0}pcs",
                              style: AppStyles.textStyle.copyWith(color: AppStyles.greColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${order.total?.toStringAsFixed(2) ?? '0.00'}",
                              style: AppStyles.headLineStyle4.copyWith(
                                color: AppStyles.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Divider(
                  color: AppStyles.whiteSmokeColor.withOpacity(0.2),
                  height: 32,
                ),
                const SizedBox(height: 20),

                // Order Details
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Order Details",
                    style: AppStyles.headLineStyle3,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Expected Delivery Date"),
                    Text(
                      _formatDate(order.createdDate != null
                          ? order.createdDate!.add(const Duration(days: 7))
                          : DateTime.now()),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tracking ID"),
                    Text(
                      "TRK${order.id ?? 'N/A'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Divider(
                  color: AppStyles.whiteSmokeColor.withOpacity(0.2),
                  height: 32,
                ),

                // Order Status
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Order Status",
                    style: AppStyles.headLineStyle3,
                  ),
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    _buildTimelineTile(
                      isFirst: true,
                      isLast: false,
                      title: "Order Placed",
                      date: _formatDateTime(order.createdDate ?? DateTime.now()),
                      isActive: true,
                      icon: Icons.receipt_long,
                    ),
                    _buildTimelineTile(
                      isFirst: false,
                      isLast: false,
                      title: "In Progress",
                      date: _formatDateTime(
                          order.createdDate != null ? order.createdDate!.add(const Duration(hours: 1)) : DateTime.now()),
                      isActive: order.deliveryStatus == 'Pending' || order.deliveryStatus == 'Shipped' || order.deliveryStatus == 'Delivered',
                      icon: Icons.local_shipping_outlined,
                    ),
                    _buildTimelineTile(
                      isFirst: false,
                      isLast: false,
                      title: "Shipped",
                      date: "Expected ${_formatDate(order.createdDate != null ? order.createdDate!.add(const Duration(days: 5)) : DateTime.now())}",
                      isActive: order.deliveryStatus == 'Shipped' || order.deliveryStatus == 'Delivered',
                      icon: Icons.local_shipping,
                    ),
                    _buildTimelineTile(
                      isFirst: false,
                      isLast: true,
                      title: "Delivered",
                      date: order.deliveryStatus == 'Delivered'
                          ? _formatDateTime(order.modifiedDate ?? DateTime.now())
                          : "Expected ${_formatDate(order.createdDate != null ? order.createdDate!.add(const Duration(days: 7)) : DateTime.now())}",
                      isActive: order.deliveryStatus == 'Delivered',
                      icon: Icons.inventory,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(
                const TrackOrderPage(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 500),
              );
            },
            label: Text(
              "Leave A Review",
              style: AppStyles.headLineStyle3
                  .copyWith(color: AppStyles.whiteColor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required bool isFirst,
    required bool isLast,
    required String title,
    required String date,
    required bool isActive,
    required IconData icon,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
        iconStyle: IconStyle(
          iconData: isActive ? Icons.check : Icons.circle_outlined,
          color: Colors.white,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
        thickness: 2,
      ),
      endChild: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Icon(icon, color: isActive ? AppStyles.primaryColor : Colors.grey),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}