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
            backgroundColor: AppStyles.whiteColor,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppStyles.blackColor,
            title: Text('My Orders', style: AppStyles.headLineStyle2),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppStyles.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(4),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    labelColor: AppStyles.blackColor,
                    unselectedLabelColor: AppStyles.greColor,
                    labelStyle: AppStyles.textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppStyles.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(height: 40, text: 'Active'),
                      Tab(height: 40, text: 'Completed'),
                      Tab(height: 40, text: 'Cancelled'),
                    ],
                  ),
                ),
              ),
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
        color: AppStyles.primaryColor,
        backgroundColor: AppStyles.whiteColor,
        onRefresh: () => controller.refreshOrders(status),
        child: CustomScrollView(
          key: PageStorageKey(status),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (loading)
              SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  color: AppStyles.primaryColor,
                  backgroundColor:
                      AppStyles.primaryColor.withValues(alpha: .15),
                ),
              ),
            if (error.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppStyles.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(error,
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyle
                                  .copyWith(color: AppStyles.greColor)),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppStyles.blackColor,
                                backgroundColor: AppStyles.primaryColor
                                    .withValues(alpha: .18)),
                            onPressed: loading
                                ? null
                                : () => controller.refreshOrders(status),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (orders.isEmpty && !loading && error.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color:
                                AppStyles.primaryColor.withValues(alpha: .18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 36, color: AppStyles.blackColor),
                        ),
                        const SizedBox(height: 16),
                        Text('No $label orders yet',
                            style: AppStyles.headLineStyle3
                                .copyWith(color: AppStyles.blackColor)),
                        const SizedBox(height: 4),
                        Text('Pull down to refresh.',
                            style: AppStyles.textStyle),
                      ],
                    ),
                  ),
                ),
              ),
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
    final quantity = order.totalQuantity ??
        order.orderProducts
            .fold<int>(0, (sum, item) => sum + (item.quantity ?? 1));
    final statusIcon = switch (order.deliveryStatus) {
      'Delivered' => Icons.check_circle_outline,
      'Cancelled' => Icons.cancel_outlined,
      'Shipped' => Icons.local_shipping_outlined,
      _ => Icons.schedule,
    };
    final actionStyle = FilledButton.styleFrom(
      backgroundColor: AppStyles.primaryColor,
      foregroundColor: AppStyles.blackColor,
    );
    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: AppStyles.blackColor,
      side: BorderSide(color: AppStyles.primaryColor),
    );
    final captionStyle =
        AppStyles.textStyle.copyWith(color: AppStyles.greColor);
    final titleStyle = AppStyles.headLineStyle4.copyWith(
      color: AppStyles.blackColor,
      fontWeight: FontWeight.w600,
    );
    final placeholder = Center(
      child: Icon(Icons.shopping_bag_outlined, color: AppStyles.greColor),
    );

    return Card(
      color: AppStyles.whiteColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: order.id == null ? null : _open,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text('Order #${order.id ?? '—'}', style: titleStyle),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: cancelled
                            ? AppStyles.bgColor
                            : AppStyles.primaryColor.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon,
                              size: 14, color: AppStyles.blackColor),
                          const SizedBox(width: 4),
                          Text(order.deliveryStatus ?? 'Unknown',
                              style: captionStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (order.createdDate case final date?)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Ordered ${_date(date)}', style: captionStyle),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: AppStyles.bgColor,
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: product?.imageUrls.isNotEmpty == true
                            ? Image.network(product!.imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stackTrace) =>
                                    placeholder)
                            : placeholder,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product?.title ?? 'Order items',
                            style: titleStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (order.orderProducts.length > 1)
                          Text('+${order.orderProducts.length - 1} more items',
                              style: captionStyle),
                        Text('$quantity ${quantity == 1 ? 'item' : 'items'}',
                            style: captionStyle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppStyles.bgColor),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                      order.total == null
                          ? 'Total unavailable'
                          : order.formatAmount(order.total),
                      style: titleStyle),
                  Text('Payment: ${order.paymentStatus ?? 'Unknown'}',
                      style: captionStyle),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton(
                    style: outlineStyle,
                    onPressed: order.id == null ? null : _open,
                    child: Text(
                        completed || cancelled ? 'View Order' : 'Track Order'),
                  ),
                  if (order.canResumePayment)
                    FilledButton(
                      style: actionStyle,
                      onPressed: _resumePayment,
                      child: const Text('Resume payment'),
                    ),
                  if (completed || cancelled)
                    Obx(() {
                      final controller = Get.find<OrderController>();
                      final busy = controller.reorderingIds.contains(order.id);
                      return FilledButton.icon(
                        style: actionStyle,
                        onPressed: busy || order.id == null
                            ? null
                            : () => controller.buyAgain(order.id!),
                        icon:
                            const Icon(Icons.shopping_cart_outlined, size: 18),
                        label: Text(busy ? 'Adding…' : 'Buy Again'),
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
