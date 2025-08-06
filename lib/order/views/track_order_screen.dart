import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';
import 'review_screen.dart';

class TrackOrderPage extends StatelessWidget {
  final int? orderId;

  const TrackOrderPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    late final OrderController orderController;
    try {
      orderController = Get.find<OrderController>();
    } catch (e) {
      orderController = Get.put(OrderController());
    }

    if (orderId == null) {
      return _buildErrorScaffold("Invalid order ID");
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Track Order #${orderId ?? 'N/A'}",
            style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            try {
              Get.back();
            } catch (e) {
              print('Error navigating back: $e');
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      body: FutureBuilder<OrderModel?>(
        future: _getOrderDetails(orderController, orderId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppStyles.primaryColor),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState(
              context,
              orderController,
              snapshot.error?.toString() ?? 'Order not found',
            );
          }

          final order = snapshot.data!;
          return _buildOrderContent(order);
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(orderController),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Track Order", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            try {
              Get.back();
            } catch (e) {
              Navigator.of(Get.context!).pop();
            }
          },
        ),
      ),
      body: _buildErrorState(Get.context!, null, message),
    );
  }

  Widget _buildErrorState(
      BuildContext context, OrderController? controller, String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth < 400 ? 0.9 : 1.0;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Order Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppStyles.textStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    try {
                      Get.back();
                    } catch (e) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                      AppStyles.whiteSmokeColor.withOpacity(0.1),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: AppStyles.primaryColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: AppStyles.headLineStyle3.copyWith(
                      color: AppStyles.primaryColor,
                    ),
                    textScaler: TextScaler.linear(textScaleFactor),
                  ),
                ),
                if (controller != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final order =
                          await _getOrderDetails(controller, orderId!);
                      if (order != null && context.mounted) {
                        // Force rebuild to update UI
                        (context as Element).markNeedsBuild();
                      } else {
                        showFailureSnackbar('Failed to reload order details');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: AppStyles.headLineStyle3.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                      textScaler: TextScaler.linear(textScaleFactor),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderContent(OrderModel order) {
    final firstProduct =
        order.orderProducts.isNotEmpty ? order.orderProducts.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (firstProduct != null) _buildProductCard(firstProduct, order),
          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          const SizedBox(height: 20),
          _buildOrderDetails(order),
          const SizedBox(height: 15),
          Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
          _buildOrderStatus(order),
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderProduct product, OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        product.imageUrls.isNotEmpty
            ? Image.network(
                product.imageUrls.first,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
              )
            : Container(
                height: 100,
                width: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title ?? 'Unknown Product',
                style: AppStyles.headLineStyle3
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Size: ${product.sizes.isNotEmpty ? product.sizes.first : 'N/A'} | Qty: ${product.quantity ?? 0}pcs",
                style: AppStyles.textStyle.copyWith(color: Colors.grey[600]),
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
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Order Details", style: AppStyles.headLineStyle3),
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
              "${order.id ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderStatus(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Order Status", style: AppStyles.headLineStyle3),
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
              date: _formatDateTime(order.createdDate != null
                  ? order.createdDate!.add(const Duration(hours: 1))
                  : DateTime.now()),
              isActive: order.deliveryStatus == 'Pending' ||
                  order.deliveryStatus == 'Shipped' ||
                  order.deliveryStatus == 'Delivered',
              icon: Icons.local_shipping_outlined,
            ),
            _buildTimelineTile(
              isFirst: false,
              isLast: false,
              title: "Shipped",
              date:
                  "Expected ${_formatDate(order.createdDate != null ? order.createdDate!.add(const Duration(days: 5)) : DateTime.now())}",
              isActive: order.deliveryStatus == 'Shipped' ||
                  order.deliveryStatus == 'Delivered',
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
    );
  }

  Widget _buildBottomNavBar(OrderController orderController) {
    return GetX<OrderController>(
      init: orderController,
      builder: (controller) {
        final order = controller.getOrderById(orderId!);
        if (order != null && order.deliveryStatus == 'Delivered') {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                final firstProduct = order.orderProducts.isNotEmpty
                    ? order.orderProducts.first
                    : null;
                if (firstProduct != null) {
                  try {
                    Get.to(
                      () => LeaveReviewPage(
                        orderId: orderId!,
                        product: firstProduct,
                        onReviewSubmitted: () {
                          // Refresh order details after review submission
                          controller.getOrderById(
                              orderId!); // Optional: Refresh cache
                        },
                      ),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                    showFailureSnackbar('Failed to open review page');
                  }
                } else {
                  showFailureSnackbar('Product information not available');
                }
              },
              icon: Icon(Icons.rate_review, color: AppStyles.whiteColor),
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<OrderModel?> _getOrderDetails(
      OrderController controller, int orderId) async {
    try {
      OrderModel? cachedOrder = controller.getOrderById(orderId);
      if (cachedOrder != null) {
        return cachedOrder;
      }

      OrderModel? order = await OrderService.getOrderDetails(orderId);
      if (order != null) {
        _addOrderToControllerCache(controller, order);
      }
      return order;
    } catch (e) {
      print('Error getting order details: $e');
      return null;
    }
  }

  void _addOrderToControllerCache(
      OrderController controller, OrderModel order) {
    try {
      switch (order.deliveryStatus) {
        case 'Pending':
        case 'Shipped':
          if (!controller.pendingOrders.any((o) => o.id == order.id)) {
            controller.pendingOrders.add(order);
          }
          break;
        case 'Delivered':
          if (!controller.deliveredOrders.any((o) => o.id == order.id)) {
            controller.deliveredOrders.add(order);
          }
          break;
        case 'Cancelled':
          if (!controller.cancelledOrders.any((o) => o.id == order.id)) {
            controller.cancelledOrders.add(order);
          }
          break;
      }
    } catch (e) {
      print('Error adding order to controller cache: $e');
    }
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
        trailing:
            Icon(icon, color: isActive ? AppStyles.primaryColor : Colors.grey),
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
