import 'package:ecom_app/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import '../../products/models/product_model.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';
import 'review_screen.dart';
import 'track_order_screen.dart';


class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
    Get.put(OrderController(), permanent: true);
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
        children: const [
          OrdersList(status: 'Pending'),
          OrdersList(status: 'Delivered'),
          OrdersList(status: 'Cancelled'),
        ],
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return Obx(() {
      final isLoading = controller.isLoadingByStatus(status);
      final error = controller.getErrorByStatus(status);
      final orders = controller.getOrdersByStatus(status);

      if (isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (error.isNotEmpty) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error,
                  style: AppStyles.textStyle.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => controller.refreshOrders(status),
                child: Text(
                  'Retry',
                  style: AppStyles.textStyle.copyWith(
                    color: AppStyles.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppStyles.greColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No ${status.toLowerCase()} orders found',
                style: AppStyles.headLineStyle3.copyWith(color: AppStyles.greColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ${status.toLowerCase()} orders will appear here',
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.greColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(status),
        child: ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderItemWidget(
              order: order,
              status: status,
            );
          },
        ),
      );
    });
  }
}

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final String status;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.status,
  });

  String getButtonText() {
    switch (status) {
      case 'Pending':
      case 'Shipped':
        return 'Track Order';
      case 'Delivered':
        return 'View Order';
      case 'Cancelled':
        return 'Re-Order';
      default:
        return 'View Order';
    }
  }

  void onButtonPressed() {
    switch (status) {
      case 'Pending':
      case 'Shipped':
        Get.to(
          () => TrackOrderPage(orderId: order.id),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        break;
      case 'Delivered':
       
         Get.to(
          () => TrackOrderPage(orderId: order.id),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        break;
      case 'Cancelled':
        
           Get.to(
          () => BottomNavBar(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 500),
        );
        break;
    }
  }

  void _showOrderDetails() {
    Get.bottomSheet(
      OrderDetailsBottomSheet(order: order),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display the first product from the order
    final firstProduct = order.orderProducts.isNotEmpty ? order.orderProducts.first : null;
    final additionalItemsCount = order.orderProducts.length - 1;

    return Column(
      children: [
        GestureDetector(
          onTap: _showOrderDetails,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: AppStyles.headLineStyle4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.deliveryStatus!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.deliveryStatus!,
                        style: AppStyles.textStyle.copyWith(
                          color: _getStatusColor(order.deliveryStatus!),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Product info
                if (firstProduct != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: firstProduct.imageUrls?.isNotEmpty ?? false
                            ? Image.network(
                                firstProduct.imageUrls!.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppStyles.greColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppStyles.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppStyles.greColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppStyles.greColor,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppStyles.greColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: AppStyles.greColor,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              firstProduct.title!,
                              style: AppStyles.headLineStyle3.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Items: ${order.totalQuantity}",
                              style: AppStyles.textStyle.copyWith(
                                color: AppStyles.greColor,
                              ),
                            ),
                            if (additionalItemsCount > 0)
                              Text(
                                "+$additionalItemsCount more items",
                                style: AppStyles.textStyle.copyWith(
                                  color: AppStyles.greColor,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${order.total!.toStringAsFixed(2)}",
                              style: AppStyles.headLineStyle4.copyWith(
                                color: AppStyles.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: onButtonPressed,
                        child: Text(
                          getButtonText(),
                          style: AppStyles.textStyle.copyWith(
                            color: AppStyles.whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Order date and payment status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ordered: ${_formatDate(order.createdDate!)}',
                      style: AppStyles.textStyle.copyWith(
                        color: AppStyles.greColor,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          _getPaymentStatusIcon(order.paymentStatus!),
                          size: 14,
                          color: _getPaymentStatusColor(order.paymentStatus!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.paymentStatus!,
                          style: AppStyles.textStyle.copyWith(
                            color: _getPaymentStatusColor(order.paymentStatus!),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'Shipped':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppStyles.greColor;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'unpaid':
        return Colors.orange;
      default:
        return AppStyles.greColor;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'unpaid':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Optional: Order Details Bottom Sheet
class OrderDetailsBottomSheet extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsBottomSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppStyles.greColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: AppStyles.headLineStyle2,
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Order details content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info
                  _buildInfoRow('Order ID', '#${order.id}'),
                  _buildInfoRow('Status', order.deliveryStatus!),
                  _buildInfoRow('Payment', order.paymentStatus!),
                  _buildInfoRow('Total', '\$${order.total!.toStringAsFixed(2)}'),
                  _buildInfoRow('Date', _formatDate(order.createdDate!)),
                  
                  const SizedBox(height: 20),
                  
                  // Products
                  Text(
                    'Products (${order.orderProducts.length})',
                    style: AppStyles.headLineStyle3,
                  ),
                  const SizedBox(height: 12),
                  
                  ...order.orderProducts.map((product) => 
                    _buildProductItem(product)).toList(),
                  
                  const SizedBox(height: 20),
                  
                  // Address
                  Text(
                    'Delivery Address',
                    style: AppStyles.headLineStyle3,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppStyles.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.address.address,
                      style: AppStyles.textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.textStyle.copyWith(color: AppStyles.greColor)),
          Text(value, style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppStyles.greColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrls?.isNotEmpty ?? false
                ? Image.network(
                    product.imageUrls!.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppStyles.greColor.withOpacity(0.2),
                    child: Icon(Icons.image, color: AppStyles.greColor),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title!,
                  style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${product.discountPrice}',
                  style: AppStyles.textStyle.copyWith(color: AppStyles.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}