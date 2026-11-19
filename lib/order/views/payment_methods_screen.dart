import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../../base/widgets/primary_button.dart';
import '../controllers/payment_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final OrderModel? existingOrder;

  const PaymentMethodsScreen({super.key, this.existingOrder});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int selectedPaymentTypeIndex = 0;
  Map<String, dynamic>? _quote;
  Map<String, dynamic>? _createdOrder;

  String get _currency => selectedPaymentTypeIndex == 2 ? 'USD' : 'NGN';
  OrderModel? _existingOrder;
  bool _loadingOrder = false;
  bool _submitting = false;
  String? _orderError;

  bool get _resuming => widget.existingOrder != null;
  int get _fixedMethodIndex => paymentTypes.indexWhere(
        (method) =>
            (method['label'] as String).toLowerCase() ==
            _existingOrder?.paymentMode?.toLowerCase(),
      );
  late PaystackPaymentController paystackController;
  late FlutterwavePaymentController flutterwaveController;
  late StripePaymentController stripeController;

  final List<Map<String, dynamic>> paymentTypes = [
    {
      "label": "PayStack",
      "icon": Icons.payment,
      "description": "Pay in NGN with PayStack",
    },
    {
      "label": "Flutterwave",
      "icon": Icons.account_balance_wallet,
      "description": "Pay in NGN with Flutterwave",
    },
    {
      "label": "Stripe",
      "icon": Icons.credit_card,
      "description": "Pay in USD with Stripe",
    },
  ];

  @override
  void initState() {
    super.initState();
    paystackController = Get.put(PaystackPaymentController());
    flutterwaveController = Get.put(FlutterwavePaymentController());
    stripeController = Get.put(StripePaymentController());
    _existingOrder = widget.existingOrder;
    if (_resuming) {
      _refreshOrder();
    } else {
      _loadQuote();
    }
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loadingOrder = true;
      _orderError = null;
    });
    final quote = await paystackController.quoteCheckout();
    if (!mounted) return;
    setState(() {
      _quote = quote;
      _loadingOrder = false;
      if (quote == null) _orderError = paystackController.errorMessage.value;
    });
  }

  Future<void> _refreshOrder() async {
    setState(() {
      _loadingOrder = true;
      _orderError = null;
    });
    final order =
        await Get.find<OrderController>().fetchOrder(widget.existingOrder!.id!);
    if (!mounted) return;
    setState(() {
      _existingOrder = order ?? _existingOrder;
      _loadingOrder = false;
      if (order == null) {
        _orderError = 'Could not check this order. Try again.';
      } else if (!order.canResumePayment) {
        _orderError = 'This order is no longer awaiting payment.';
      } else if (order.paymentMode != null && _fixedMethodIndex < 0) {
        _orderError = 'Contact support to continue payment for this order.';
      } else if (_fixedMethodIndex >= 0) {
        selectedPaymentTypeIndex = _fixedMethodIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Payment Methods", style: AppStyles.headLineStyle2),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _submitting ? null : () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            // Payment Summary Section
            _buildPaymentSummary(),

            const SizedBox(height: 20),
            if (_orderError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_orderError!),
              ),
            if (_orderError != null)
              TextButton(
                  onPressed: _resuming ? _refreshOrder : _loadQuote,
                  child: const Text('Refresh')),

            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _fixedMethodIndex >= 0 ? 1 : paymentTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, position) {
                  final index =
                      _fixedMethodIndex >= 0 ? _fixedMethodIndex : position;
                  return PaymentTypeCard(
                    label: paymentTypes[index]['label']!,
                    description: paymentTypes[index]['description']!,
                    icon: paymentTypes[index]['icon'] as IconData,
                    isSelected: selectedPaymentTypeIndex == index,
                    onTap: () {
                      if (_submitting || _loadingOrder) return;
                      setState(() {
                        selectedPaymentTypeIndex = index;
                      });
                    },
                  );
                },
              ),
            ),

            // Payment Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 80,
                text: _resuming ? 'Continue payment' : 'Pay Now',
                isLoading: _submitting || _loadingOrder,
                onTap: _submitting || _loadingOrder || _orderError != null
                    ? null
                    : _handlePaymentConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Summary",
            style: AppStyles.headLineStyle3,
          ),
          const SizedBox(height: 12),
          if (_existingOrder case final order?) ...[
            _buildSummaryRow('Order', '#${order.id}'),
            if (order.shipping != null && order.tax != null) ...[
              _buildSummaryRow('Subtotal', _money(order.subtotal)),
              _buildSummaryRow('Shipping', _money(order.shipping)),
              _buildSummaryRow('Tax', _money(order.tax)),
            ],
            _buildSummaryRow('Total', _money(order.total), isTotal: true),
          ] else if ((_createdOrder ?? _quote) case final amounts?) ...[
            _buildSummaryRow('Subtotal', _money(amounts['subtotal'])),
            _buildSummaryRow('Shipping', _money(amounts['shipping'])),
            _buildSummaryRow('Tax', _money(amounts['tax'])),
            const Divider(),
            _buildSummaryRow('Total', _money(amounts['total']), isTotal: true),
          ],
        ],
      ),
    );
  }

  String _money(Object? amount) {
    final value = double.tryParse('$amount');
    return value == null ? '—' : '$_currency ${value.toStringAsFixed(2)}';
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppStyles.primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePaymentConfirmation() async {
    if (_submitting || _loadingOrder || _orderError != null) return;
    setState(() => _submitting = true);
    try {
      if (!_resuming && _createdOrder == null) {
        final quote = _quote;
        if (quote == null) return;
        final order = await paystackController.createOrder(quote);
        if (!mounted) return;
        if (order == null) {
          final message = paystackController.errorMessage.value;
          showFailureSnackbar(
              message.isEmpty ? 'Could not place order.' : message);
          if (message.startsWith('Prices changed.')) await _loadQuote();
          return;
        }

        final status = order['payment_status'];
        if (status == 'Paid' || order['delivery_status'] != 'Pending') {
          await paystackController.forgetCheckout(order['id'] as int);
          if (mounted) {
            showFailureSnackbar(
                'This checkout is finished. View the order in My Orders.');
            Get.back();
          }
          return;
        }
        setState(() => _createdOrder = order);
        if (order['total'] != quote['total']) {
          showFailureSnackbar('Review the saved order total before paying.');
          return;
        }
      }

      final orderId = _existingOrder?.id ?? _createdOrder!['id'] as int;
      final amount = _existingOrder?.total ??
          double.parse(_createdOrder!['total'] as String);
      final method = paymentTypes[selectedPaymentTypeIndex]['label'];
      final controller = switch (method) {
        'Flutterwave' => flutterwaveController,
        'Stripe' => stripeController,
        _ => paystackController,
      };
      final success = await controller.initiatePayment(
        amount: amount,
        orderId: orderId,
        resume: _resuming,
      );
      if (!mounted) return;
      if (success && _resuming) {
        Get.back();
        showSuccessSnackbar('Payment confirmed for order #$orderId.');
      } else if (!success) {
        showFailureSnackbar(
          controller.errorMessage.value,
          title: 'Payment not confirmed',
        );
        if (_resuming) await _refreshOrder();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    paystackController.clearPaymentData();
    flutterwaveController.clearPaymentData();
    stripeController.clearPaymentData();
    super.dispose();
  }
}

class PaymentTypeCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentTypeCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppStyles.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppStyles.primaryColor : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppStyles.primaryColor : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppStyles.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
