import 'order_help_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/res/styles/app_styles.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import 'review_screen.dart';

class TrackOrderPage extends StatefulWidget {
  final int? orderId;
  final bool isReceipt;
  const TrackOrderPage({super.key, this.orderId, this.isReceipt = false});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  late final OrderController controller;
  OrderModel? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    _load();
  }

  Future<void> _load() async {
    if (widget.orderId == null || widget.orderId! <= 0) {
      setState(() {
        _loading = false;
        _error = 'Invalid order ID.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await controller.fetchOrder(widget.orderId!);
      if (!mounted) return;
      setState(() {
        _order = order;
        if (order == null)
          _error = 'Could not load this order. Please try again.';
      });
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Could not load this order. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(OrderProduct product) async {
    final submitted = await Get.to<bool>(() => LeaveReviewPage(
          orderId: widget.orderId,
          product: product,
        ));
    if (submitted == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          title: Text(widget.orderId == null
              ? 'Order Details'
              : '${widget.isReceipt ? 'Receipt' : 'Order'} #${widget.orderId}'),
          actions: [
            IconButton(
                tooltip: 'Refresh order',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      if (widget.orderId != null && widget.orderId! > 0)
                        TextButton(
                            onPressed: _load, child: const Text('Retry')),
                    ]),
                  ))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        _status(_order!),
                        const SizedBox(height: 20),
                        Text('Items (${_order!.orderProducts.length})',
                            style: AppStyles.headLineStyle3),
                        const SizedBox(height: 12),
                        for (final product in _order!.orderProducts)
                          _product(product, _order!),
                        const Divider(height: 32),
                        Text('Payment summary',
                            style: AppStyles.headLineStyle3),
                        _row('Payment status',
                            _order!.paymentStatus ?? 'Unknown'),
                        if (_order!.subtotal != null)
                          _row('Subtotal', _money(_order!.subtotal)),
                        if (_order!.shipping != null)
                          _row('Shipping', _money(_order!.shipping)),
                        if (_order!.tax != null)
                          _row('Tax', _money(_order!.tax)),
                        _row('Order total', _money(_order!.total)),
                        if (_order!.createdDate != null)
                          _row('Ordered', _date(_order!.createdDate!)),
                        const Divider(height: 32),
                        Text('Delivery address',
                            style: AppStyles.headLineStyle3),
                        const SizedBox(height: 8),
                        Text(_order!.address.address.isEmpty
                            ? 'Address unavailable'
                            : _order!.address.address),
                        if (_order!.address.phone.isNotEmpty)
                          Text(_order!.address.phone),
                        const SizedBox(height: 24),
                        if (!widget.isReceipt && _order!.id != null)
                          OutlinedButton.icon(
                            onPressed: () => Get.to(
                                () => OrderHelpScreen(orderId: _order!.id!)),
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Get help with this order'),
                          ),
                        if (!widget.isReceipt &&
                            _order!.paymentStatus == 'Paid')
                          OutlinedButton.icon(
                            onPressed: () => Get.to(() => TrackOrderPage(
                                orderId: widget.orderId, isReceipt: true)),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('View Receipt'),
                          ),
                        if (!widget.isReceipt &&
                            (_order!.deliveryStatus == 'Delivered' ||
                                _order!.deliveryStatus == 'Cancelled'))
                          Obx(() {
                            final busy = controller.reorderingIds
                                .contains(widget.orderId);
                            return ElevatedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () => controller.buyAgain(widget.orderId!),
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: Text(busy ? 'Adding…' : 'Buy Again'),
                            );
                          }),
                      ],
                    ),
                  ),
      );

  Widget _status(OrderModel order) {
    final cancelled = order.deliveryStatus == 'Cancelled';
    final progress =
        ['Pending', 'Shipped', 'Delivered'].indexOf(order.deliveryStatus ?? '');
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(order.deliveryStatus ?? 'Status unavailable',
            style: AppStyles.headLineStyle3),
        const SizedBox(height: 8),
        if (cancelled)
          const Text(
              'This order was cancelled. You can check available items with Buy Again.')
        else if (progress >= 0) ...[
          for (var index = 0; index < 3; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Icon(
                    index <= progress
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: index <= progress
                        ? AppStyles.primaryColor
                        : Colors.grey),
                const SizedBox(width: 12),
                Text(['Order placed', 'Shipped', 'Delivered'][index]),
              ]),
            ),
          if (order.deliveryStatus != 'Delivered')
            const Text(
                'Delivery updates will appear here as your order progresses.'),
        ],
      ]),
    ));
  }

  Widget _product(OrderProduct product, OrderModel order) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 64,
                  height: 64,
                  child: product.imageUrls.isEmpty
                      ? const Icon(Icons.shopping_bag_outlined)
                      : Image.network(product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) =>
                              const Icon(Icons.image_not_supported_outlined))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(product.title ?? 'Product unavailable',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Quantity: ${product.quantity ?? 1}'),
                    if (product.sizes.isNotEmpty)
                      Text('Size: ${product.sizes.join(', ')}'),
                    if (product.colors.isNotEmpty)
                      Text('Color: ${product.colors.join(', ')}'),
                    Text('Unit price: ${_money(product.unitPrice)}'),
                    Text('Item total: ${_money(product.lineTotal)}'),
                  ])),
            ]),
            if (!widget.isReceipt &&
                order.deliveryStatus == 'Delivered' &&
                product.id != null)
              TextButton.icon(
                onPressed: () => _review(product),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(order.rated.contains(product.id)
                    ? 'View / Edit Review'
                    : 'Review Item'),
              ),
          ]),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ]),
      );
  String _money(double? value) => _order!.formatAmount(value);
  String _date(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
