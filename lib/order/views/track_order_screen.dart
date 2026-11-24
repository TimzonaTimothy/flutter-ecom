import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/res/styles/app_styles.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import 'order_help_screen.dart';
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

  ButtonStyle get _primaryAction => FilledButton.styleFrom(
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: AppStyles.blackColor,
      );

  ButtonStyle get _secondaryAction => OutlinedButton.styleFrom(
        foregroundColor: AppStyles.blackColor,
        side: BorderSide(color: AppStyles.primaryColor),
      );

  TextStyle get _heading =>
      AppStyles.headLineStyle3.copyWith(color: AppStyles.blackColor);

  TextStyle get _caption =>
      AppStyles.textStyle.copyWith(color: AppStyles.greColor);

  Widget _surface(Widget child, {EdgeInsets margin = EdgeInsets.zero}) => Card(
        color: AppStyles.whiteColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: margin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.whiteColor,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppStyles.blackColor,
          centerTitle: true,
          title: Text(
            widget.orderId == null
                ? 'Order Details'
                : '${widget.isReceipt ? 'Receipt' : 'Order'} #${widget.orderId}',
            style: AppStyles.headLineStyle2,
          ),
          actions: [
            IconButton(
                tooltip: 'Refresh order',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(color: AppStyles.primaryColor))
            : _error != null
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.error_outline,
                          size: 40, color: AppStyles.greColor),
                      const SizedBox(height: 16),
                      Text(_error!,
                          textAlign: TextAlign.center, style: _caption),
                      if (widget.orderId != null && widget.orderId! > 0)
                        FilledButton(
                            style: _primaryAction,
                            onPressed: _load,
                            child: const Text('Retry')),
                    ]),
                  ))
                : RefreshIndicator(
                    color: AppStyles.primaryColor,
                    backgroundColor: AppStyles.whiteColor,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        _status(_order!),
                        const SizedBox(height: 20),
                        Text('Items (${_order!.orderProducts.length})',
                            style: AppStyles.headLineStyle3),
                        const SizedBox(height: 12),
                        for (final product in _order!.orderProducts)
                          _product(product, _order!),
                        const SizedBox(height: 4),
                        _surface(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment summary', style: _heading),
                              const SizedBox(height: 6),
                              _row('Payment status',
                                  _order!.paymentStatus ?? 'Unknown'),
                              if (_order!.subtotal != null)
                                _row('Subtotal', _money(_order!.subtotal)),
                              if (_order!.shipping != null)
                                _row('Shipping', _money(_order!.shipping)),
                              if (_order!.tax != null)
                                _row('Tax', _money(_order!.tax)),
                              Divider(color: AppStyles.bgColor),
                              _row('Order total', _money(_order!.total),
                                  emphasize: true),
                              if (_order!.createdDate != null)
                                _row('Ordered', _date(_order!.createdDate!)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _surface(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery address', style: _heading),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.place_outlined,
                                      color: AppStyles.greColor, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            _order!.address.address.isEmpty
                                                ? 'Address unavailable'
                                                : _order!.address.address,
                                            style: _caption),
                                        if (_order!.address.phone.isNotEmpty)
                                          Text(_order!.address.phone,
                                              style: _caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!widget.isReceipt) const SizedBox(height: 16),
                        if (!widget.isReceipt && _order!.id != null)
                          OutlinedButton.icon(
                            style: _secondaryAction,
                            onPressed: () => Get.to(
                                () => OrderHelpScreen(orderId: _order!.id!)),
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Get help with this order'),
                          ),
                        if (!widget.isReceipt &&
                            _order!.paymentStatus == 'Paid')
                          OutlinedButton.icon(
                            style: _secondaryAction,
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
                            return FilledButton.icon(
                              style: _primaryAction,
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
    return _surface(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cancelled
                  ? AppStyles.bgColor
                  : AppStyles.primaryColor.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(order.deliveryStatus ?? 'Status unavailable',
                style: _caption.copyWith(
                  color: AppStyles.blackColor,
                  fontWeight: FontWeight.w600,
                )),
          ),
          if (cancelled) ...[
            const SizedBox(height: 10),
            Text(
                'This order was cancelled. You can check available items with Buy Again.',
                style: _caption),
          ] else if (progress >= 0) ...[
            const SizedBox(height: 10),
            for (final (index, label)
                in ['Order placed', 'Shipped', 'Delivered'].indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      index <= progress
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: index <= progress
                          ? AppStyles.primaryColor
                          : AppStyles.greColor,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label,
                          style: _caption.copyWith(
                            color: index <= progress
                                ? AppStyles.blackColor
                                : AppStyles.greColor,
                            fontWeight: index == progress
                                ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _product(OrderProduct product, OrderModel order) {
    final placeholder = Center(
      child: Icon(Icons.shopping_bag_outlined, color: AppStyles.greColor),
    );
    return _surface(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: AppStyles.bgColor,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: product.imageUrls.isEmpty
                        ? placeholder
                        : Image.network(product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stack) => placeholder),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title ?? 'Product unavailable',
                        style: AppStyles.headLineStyle4.copyWith(
                            color: AppStyles.blackColor,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Quantity: ${product.quantity ?? 1}', style: _caption),
                    if (product.sizes.isNotEmpty)
                      Text('Size: ${product.sizes.join(', ')}',
                          style: _caption),
                    if (product.colors.isNotEmpty)
                      Text('Color: ${product.colors.join(', ')}',
                          style: _caption),
                    Text('Unit price: ${_money(product.unitPrice)}',
                        style: _caption),
                    Text('Item total: ${_money(product.lineTotal)}',
                        style: _caption.copyWith(
                            color: AppStyles.blackColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          if (!widget.isReceipt &&
              order.deliveryStatus == 'Delivered' &&
              product.id != null)
            TextButton.icon(
              style:
                  TextButton.styleFrom(foregroundColor: AppStyles.blackColor),
              onPressed: () => _review(product),
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(order.rated.contains(product.id)
                  ? 'View / Edit Review'
                  : 'Review Item'),
            ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    final style = emphasize
        ? _caption.copyWith(
            color: AppStyles.blackColor, fontWeight: FontWeight.w600)
        : _caption;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Flexible(
              child: Text(value, textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }

  String _money(double? value) => _order!.formatAmount(value);
  String _date(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
