import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/res/styles/app_styles.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import 'track_order_screen.dart';
import 'payment_methods_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrderController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<OrderController>()) {
      controller = Get.find<OrderController>();
      controller.loadAllOrders();
    } else {
      controller = Get.put(OrderController());
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppStyles.bgColor,
          appBar: AppBar(
            backgroundColor: AppStyles.bgColor,
            title: Text('My Orders', style: AppStyles.headLineStyle2),
            centerTitle: true,
            bottom: TabBar(
              labelColor: AppStyles.primaryColor,
              indicatorColor: AppStyles.primaryColor,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled')
              ],
            ),
          ),
          body: const TabBarView(children: [
            OrdersList(status: 'Pending'),
            OrdersList(status: 'Delivered'),
            OrdersList(status: 'Cancelled'),
          ]),
        ),
      );
}

class OrdersList extends StatelessWidget {
  final String status;
  const OrdersList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    return Obx(() {
      final loading = controller.isLoadingByStatus(status);
      final error = controller.getErrorByStatus(status);
      final orders = controller.getOrdersByStatus(status);
      final label = status == 'Pending'
          ? 'active'
          : status == 'Delivered'
              ? 'completed'
              : 'cancelled';
      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(status),
        child: CustomScrollView(
          key: PageStorageKey(status),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (loading)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            if (error.isNotEmpty)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text(error, textAlign: TextAlign.center),
                  TextButton(
                      onPressed: loading
                          ? null
                          : () => controller.refreshOrders(status),
                      child: const Text('Retry')),
                ]),
              )),
            if (orders.isEmpty && !loading && error.isEmpty)
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No $label orders yet'),
                      const Text('Pull down to refresh.'),
                    ],
                  ))),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    OrderItemWidget(order: orders[index], status: status),
                childCount: orders.length,
              )),
            ),
          ],
        ),
      );
    });
  }
}

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final String status;
  const OrderItemWidget({super.key, required this.order, required this.status});

  void _open() {
    if (order.id != null) Get.to(() => TrackOrderPage(orderId: order.id));
  }

  Future<void> _resumePayment() async {
    final controller = Get.find<OrderController>();
    await Get.to(() => PaymentMethodsScreen(existingOrder: order));
    await controller.fetchOrder(order.id!);
  }

  @override
  Widget build(BuildContext context) {
    final product = order.orderProducts.firstOrNull;
    final completed = order.deliveryStatus == 'Delivered';
    final cancelled = order.deliveryStatus == 'Cancelled';
    final color = cancelled
        ? Colors.red
        : completed
            ? Colors.green
            : AppStyles.primaryColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: order.id == null ? null : _open,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('Order #${order.id ?? '—'}',
                      style: AppStyles.headLineStyle4)),
              Text(order.deliveryStatus ?? 'Unknown',
                  style: TextStyle(color: color)),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 64,
                  height: 64,
                  child: product?.imageUrls.isNotEmpty == true
                      ? Image.network(product!.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) =>
                              const Icon(Icons.image_not_supported_outlined))
                      : const Icon(Icons.shopping_bag_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(product?.title ?? 'Order items',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (order.orderProducts.length > 1)
                      Text('+${order.orderProducts.length - 1} more items'),
                    Text(
                        '${order.totalQuantity ?? order.orderProducts.fold<int>(0, (sum, item) => sum + (item.quantity ?? 1))} items'),
                    Text(
                        order.total == null
                            ? 'Total unavailable'
                            : order.formatAmount(order.total),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
            ]),
            const SizedBox(height: 12),
            Text('Payment: ${order.paymentStatus ?? 'Unknown'}'),
            if (order.createdDate != null)
              Text('Ordered ${_date(order.createdDate!)}'),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 8, children: [
              OutlinedButton(
                  onPressed: order.id == null ? null : _open,
                  child: Text(
                      completed || cancelled ? 'View Order' : 'Track Order')),
              if (order.canResumePayment)
                ElevatedButton(
                  onPressed: _resumePayment,
                  child: const Text('Resume payment'),
                ),
              if (completed || cancelled)
                Obx(() {
                  final controller = Get.find<OrderController>();
                  final busy = controller.reorderingIds.contains(order.id);
                  return ElevatedButton.icon(
                    onPressed: busy || order.id == null
                        ? null
                        : () => controller.buyAgain(order.id!),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text(busy ? 'Adding…' : 'Buy Again'),
                  );
                }),
            ]),
          ]),
        ),
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
