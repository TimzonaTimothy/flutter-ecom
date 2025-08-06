import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/service/auth_service.dart';
import '../../base/bottom_nav_bar.dart';
import '../../base/res/base_url.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';
import '../../cart/controllers/address_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import 'reciept_screen.dart';
import 'track_order_screen.dart';

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

class PaymentSuccessScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final String reference;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final logger = Logger();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _orderDetails;
  final String _paymentTimestamp =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        setState(() {
          _errorMessage =
              'Authentication token not found. Please log in again.';
          _isLoading = false;
        });
        logger.e('Missing authentication token');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseURLGeneral/orders/single/${widget.orderId}/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      logger.i('Order details response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _orderDetails = responseData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch order details: ${response.body}';
          _isLoading = false;
        });
        logger.e(
            'Failed to fetch order details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching order details: $e';
        _isLoading = false;
      });
      logger.e('Error fetching order details: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final addressController = Get.find<AddressController>();

    // Calculate subtotal and shipping/tax (assuming $7.50 is shipping + tax)
    final double subtotal = widget.amount - 7.50;
    const double shippingTax = 7.50;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text('Payment Successful', style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.offAll(
              () => const BottomNavBar(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOrderDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Success Icon and Message
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Thank You for Your Purchase!',
                              style: AppStyles.headLineStyle2.copyWith(
                                color: AppStyles.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your payment has been successfully processed.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppStyles.whiteColor,
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
                              'Payment Details',
                              style: AppStyles.headLineStyle3,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Order ID', '#${widget.orderId}'),
                            _buildDetailRow(
                                'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                            _buildDetailRow('Shipping & Tax',
                                '\$${shippingTax.toStringAsFixed(2)}'),
                            _buildDetailRow('Total Amount',
                                '\$${widget.amount.toStringAsFixed(2)}'),
                            _buildDetailRow(
                                'Payment Method', widget.paymentMethod),
                            _buildDetailRow(
                                'Payment Reference', widget.reference),
                            _buildDetailRow('Payment Date', _paymentTimestamp),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Items Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppStyles.whiteColor,
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
                              'Order Items',
                              style: AppStyles.headLineStyle3,
                            ),
                            const SizedBox(height: 12),
                            if (_orderDetails != null &&
                                _orderDetails!['order_products'] != null)
                              ...(_orderDetails!['order_products'] as List)
                                  .map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] ??
                                                  'Unknown Product',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${item['price'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item['quantity']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (item['size'] != null)
                                        Text(
                                          'Size: ${item['size']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (item['color'] != null)
                                        Text(
                                          'Color: ${item['color']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              })
                            else
                              ...cartController.cartItems.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product?.title ??
                                                  'Unknown Product',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${item.product?.discountPrice ?? item.product?.originalPrice ?? '0.00'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (item.size != null)
                                        Text(
                                          'Size: ${item.size}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (item.color != null)
                                        Text(
                                          'Color: ${item.color}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Shipping Address Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppStyles.whiteColor,
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
                              'Shipping Address',
                              style: AppStyles.headLineStyle3,
                            ),
                            const SizedBox(height: 12),
                            if (_orderDetails != null &&
                                _orderDetails!['address'] != null &&
                                _orderDetails!['address'] is Map)
                              Text(
                                '${_orderDetails!['address']['address']}, ${_orderDetails!['address']['addressType']}, ${_orderDetails!['address']['phone']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            else if (_orderDetails != null &&
                                _orderDetails!['address'] is int)
                              Text(
                                'Address ID: ${_orderDetails!['address']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            else if (addressController.selectedAddress.value !=
                                null)
                              Text(
                                '${addressController.selectedAddress.value!.address}, ${addressController.selectedAddress.value!.addressType}, ${addressController.selectedAddress.value!.phone}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            else
                              Text(
                                'No address available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Center(
                        child: Column(
                          children: [
                            PrimaryButton(
                              verticalPadding: 10,
                              horizontalPadding: 10,
                              text: 'Back to Home',
                              onTap: () {
                                Get.offAll(
                                  const BottomNavBar(),
                                  transition: Transition.rightToLeftWithFade,
                                  duration: const Duration(milliseconds: 500),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 360;
          final horizontalPadding = screenWidth * 0.05;
          final verticalPadding = screenWidth * 0.025;
          final buttonPadding = EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenWidth * 0.035,
          );
          final textScaleFactor =
              screenWidth < 400 ? 0.9 : 1.0; 

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: isSmallScreen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(buttonPadding),
                          backgroundColor: WidgetStateProperty.all(
                            AppStyles.primaryColor.withOpacity(0.1),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          side: WidgetStateProperty.all(
                            BorderSide(
                              color: AppStyles.primaryColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Get.to(
                            const EReceiptScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: Text(
                          'View E-Receipt',
                          textScaler: TextScaler.linear(textScaleFactor),
                          style: AppStyles.headLineStyle3.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(
                            const TrackOrderPage(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        icon: Icon(
                          Icons
                              .local_shipping_outlined, // Added icon for consistency
                          color: AppStyles.whiteColor,
                        ),
                        label: Text(
                          'Track Order',
                          textScaler: TextScaler.linear(textScaleFactor),
                          style: AppStyles.headLineStyle3.copyWith(
                            color: AppStyles.whiteColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: buttonPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(buttonPadding),
                            backgroundColor: WidgetStateProperty.all(
                              AppStyles.primaryColor.withOpacity(0.1),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            side: WidgetStateProperty.all(
                              BorderSide(
                                color: AppStyles.primaryColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Get.to(
                              const EReceiptScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          child: Text(
                            'View E-Receipt',
                            textScaler: TextScaler.linear(textScaleFactor),
                            style: AppStyles.headLineStyle3.copyWith(
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: horizontalPadding),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(
                              const TrackOrderPage(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                            );
                          },
                          icon: Icon(
                            Icons
                                .local_shipping_outlined, // Added icon for consistency
                            color: AppStyles.whiteColor,
                          ),
                          label: Text(
                            'Track Order',
                            textScaler: TextScaler.linear(textScaleFactor),
                            style: AppStyles.headLineStyle3.copyWith(
                              color: AppStyles.whiteColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            padding: buttonPadding,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
