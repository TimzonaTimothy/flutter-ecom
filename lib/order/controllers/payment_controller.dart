import 'dart:convert';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/service/auth_service.dart';
import '../../base/res/base_url.dart';
import '../../cart/controllers/address_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/payment_request_model.dart';
import '../views/payment_success_screen.dart';
import '../views/payment_webview.dart';

final logger = Logger();

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

class BasePaymentController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<int?> createOrder() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final token = await AuthService.instance.getToken();
      if (userId == null || token == null) {
        errorMessage.value = 'User authentication failed. Please log in again.';
        logger.e('Missing user_id or token in SharedPreferences');
        return null;
      }

      final cartController = Get.find<CartController>();
      final addressController = Get.find<AddressController>();

      if (cartController.cartItems.isEmpty) {
        errorMessage.value = 'Cart is empty';
        logger.w('Cart is empty');
        return null;
      }

      if (addressController.selectedAddress.value == null) {
        errorMessage.value = 'No shipping address selected';
        logger.w('No shipping address selected');
        return null;
      }

      // Validate cart items
      for (var item in cartController.cartItems) {
        if (item.product?.id == null) {
          errorMessage.value = 'Invalid product in cart';
          logger.e('Invalid product in cart: ${item.toJson()}');
          return null;
        }
      }

      final orderData = {
        'order_products': cartController.cartItems
            .map((item) => OrderItem.fromCartModel(item).toJson())
            .toList(),
        'address': addressController.selectedAddress.value!.id,
        'customer_id': userId,
        'total_quantity': cartController.totalQuantity,
        'subtotal': cartController.totalPrice,
        'total': cartController.totalPrice + 7.50, // Add shipping + tax
        'delivery_status': 'Pending',
        'payment_status': 'Unpaid',
      };

      logger.i('Order creation payload: $orderData');

      final response = await http.post(
        Uri.parse('$baseURLGeneral/orders/add/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final orderId = responseData['id'];
        logger.i('Order created successfully: Order ID $orderId');
        return orderId;
      } else {
        final errorData = jsonDecode(response.body);
        errorMessage.value = errorData['message'] ?? 'Failed to create order';
        logger.e(
            'Order creation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error creating order: $e';
      logger.e('Order creation error: $e',
          error: e, stackTrace: StackTrace.current);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void clearPaymentData() {
    errorMessage.value = '';
    isLoading.value = false;
  }
}

class PaystackPaymentController extends BasePaymentController {
  static PaystackPaymentController get to => Get.find();

  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId};
      logger.i('Paystack payment initiation payload: $payload');

      final response = await http.post(
        Uri.parse('$baseURLGeneral/payments/initiate-paystack-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      logger.i('Paystack API response status: ${response.statusCode}');
      logger.i('Paystack API response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Paystack response: $responseData');

        // Handle different response structures
        String? authorizationUrl;
        String? reference;

        if (responseData['data'] != null) {
          // Standard response format
          authorizationUrl = responseData['data']['authorization_url'];
          reference = responseData['data']['reference'];
        } else {
          // Direct response format
          authorizationUrl = responseData['authorization_url'];
          reference = responseData['reference'];
        }

        if (authorizationUrl == null || reference == null) {
          logger.e(
              'Invalid Paystack response data: authorization_url=$authorizationUrl, reference=$reference');
          errorMessage.value = 'Invalid payment response from server';
          return false;
        }

        // Validate the URL format
        if (!_isValidUrl(authorizationUrl)) {
          logger.e('Invalid authorization URL format: $authorizationUrl');
          errorMessage.value = 'Invalid payment URL received';
          return false;
        }

        logger.i(
            'Opening payment with URL: $authorizationUrl, Reference: $reference');
        return await _openPaymentWebView(
            authorizationUrl, reference, 'PayStack', orderId);
      } else {
        final errorBody = response.body;
        errorMessage.value = 'Failed to initiate Paystack payment: $errorBody';
        logger.e(
            'Paystack initiation failed: ${response.statusCode} - $errorBody');
        return false;
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Paystack payment error: $e';
      logger.e('Paystack payment error: $e', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final response = await http.get(
        Uri.parse(
            '$baseURLGeneral/payments/verify-paystack-payment/$reference/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      logger.i('Paystack verification response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['payment_status'] == 'Paid';
      } else {
        errorMessage.value = 'Payment verification failed: ${response.body}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error verifying payment: $e';
      logger.e('Paystack verification error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _openPaymentWebView(
      String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    // Validate URL one more time before opening WebView
    if (!_isValidUrl(url)) {
      errorMessage.value = 'Invalid payment URL format';
      logger.e('Invalid URL format: $url');
      return false;
    }

    logger.i('Opening Paystack WebView: $url, Reference: $reference');
    print('Opening $paymentMethod WebView: $url, Reference: $reference');
  print('URL details: scheme=${Uri.parse(url).scheme}, host=${Uri.parse(url).host}, path=${Uri.parse(url).path}');

    try {
      final result = await Get.to<bool>(
        () => PaymentWebViewScreen(
          url: url,
          reference: reference,
          paymentMethod: paymentMethod,
          orderId: orderId,
          onPaymentComplete: (success, message, {orderId}) {
            if (success) {
              Get.off(() => PaymentSuccessScreen(
                    orderId: orderId!,
                    amount: Get.find<CartController>().totalPrice + 7.50,
                    paymentMethod: paymentMethod,
                    reference: reference,
                  ));
            } else {
              showFailureSnackbar('Payment Failed');
            }
          },
        ),
        transition: Transition.fadeIn,
      );

      return result ?? false;
    } catch (e) {
      logger.e('Error opening WebView: $e');
      errorMessage.value = 'Failed to open payment page: $e';
      return false;
    }
  }
}

class FlutterwavePaymentController extends BasePaymentController {
  static FlutterwavePaymentController get to => Get.find();

  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId};
      logger.i('Flutterwave payment initiation payload: $payload');

      final response = await http.post(
        Uri.parse('$baseURLGeneral/payments/initiate-flutterwave-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      logger.i('Flutterwave API response status: ${response.statusCode}');
      logger.i('Flutterwave API response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Flutterwave response: $responseData');

        // Handle different response structures
        String? paymentLink;
        String? reference;

        if (responseData['data'] != null) {
          paymentLink = responseData['data']['link'];
          reference = responseData['data']['reference'];
        } else {
          paymentLink = responseData['link'];
          reference = responseData['reference'];
        }

        if (paymentLink == null || reference == null) {
          logger.e(
              'Invalid Flutterwave response data: link=$paymentLink, reference=$reference');
          errorMessage.value = 'Invalid payment response from server';
          return false;
        }

        // Validate the URL format
        if (!_isValidUrl(paymentLink)) {
          logger.e('Invalid payment link format: $paymentLink');
          errorMessage.value = 'Invalid payment URL received';
          return false;
        }

        logger
            .i('Opening payment with URL: $paymentLink, Reference: $reference');
        return await _openPaymentWebView(
            paymentLink, reference, 'Flutterwave', orderId);
      } else {
        final errorBody = response.body;
        errorMessage.value =
            'Failed to initiate Flutterwave payment: $errorBody';
        logger.e(
            'Flutterwave initiation failed: ${response.statusCode} - $errorBody');
        return false;
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Flutterwave payment error: $e';
      logger.e('Flutterwave payment error: $e',
          error: e, stackTrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final response = await http.get(
        Uri.parse(
            '$baseURLGeneral/payments/verify-flutterwave-payment/$reference/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      logger.i('Flutterwave verification response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['payment_status'] == 'Paid';
      } else {
        errorMessage.value = 'Payment verification failed: ${response.body}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error verifying payment: $e';
      logger.e('Flutterwave verification error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _openPaymentWebView(
      String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    // Validate URL one more time before opening WebView
    if (!_isValidUrl(url)) {
      errorMessage.value = 'Invalid payment URL format';
      logger.e('Invalid URL format: $url');
      return false;
    }

    logger.i('Opening Flutterwave WebView: $url, Reference: $reference');

    try {
      final result = await Get.to<bool>(
        () => PaymentWebViewScreen(
          url: url,
          reference: reference,
          paymentMethod: paymentMethod,
          orderId: orderId,
          onPaymentComplete: (success, message, {orderId}) {
            if (success) {
              Get.off(() => PaymentSuccessScreen(
                    orderId: orderId!,
                    amount: Get.find<CartController>().totalPrice + 7.50,
                    paymentMethod: paymentMethod,
                    reference: reference,
                  ));
            } else {
              showFailureSnackbar('Payment Failed');
            }
          },
        ),
        transition: Transition.fadeIn,
      );

      return result ?? false;
    } catch (e) {
      logger.e('Error opening WebView: $e');
      errorMessage.value = 'Failed to open payment page: $e';
      return false;
    }
  }
}

class StripePaymentController extends BasePaymentController {
  static StripePaymentController get to => Get.find();

  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId};
      logger.i('Stripe payment initiation payload: $payload');

      final response = await http.post(
        Uri.parse('$baseURLGeneral/payments/initiate-stripe-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      logger.i('Stripe API response status: ${response.statusCode}');
      logger.i('Stripe API response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Stripe response: $responseData');

        // Handle different response structures
        String? checkoutUrl;
        String? sessionId;

        if (responseData['data'] != null) {
          checkoutUrl = responseData['data']['link'];
          sessionId = responseData['data']['reference'];
        } else {
          checkoutUrl = responseData['link'];
          sessionId = responseData['reference'];
        }

        if (checkoutUrl == null || sessionId == null) {
          logger.e(
              'Invalid Stripe response data: link=$checkoutUrl, reference=$sessionId');
          errorMessage.value = 'Invalid payment response from server';
          return false;
        }

        // Validate the URL format
        if (!_isValidUrl(checkoutUrl)) {
          logger.e('Invalid checkout URL format: $checkoutUrl');
          errorMessage.value = 'Invalid payment URL received';
          return false;
        }

        logger.i(
            'Opening payment with URL: $checkoutUrl, Session ID: $sessionId');
        return await _openPaymentWebView(
            checkoutUrl, sessionId, 'Stripe', orderId);
      } else {
        final errorBody = response.body;
        errorMessage.value = 'Failed to initiate Stripe payment: $errorBody';
        logger
            .e('Stripe initiation failed: ${response.statusCode} - $errorBody');
        return false;
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Stripe payment error: $e';
      logger.e('Stripe payment error: $e', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPayment(String sessionId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseURLGeneral/payments/verify-stripe-payment/$sessionId/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      logger.i('Stripe verification response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['payment_status'] == 'Paid';
      } else {
        errorMessage.value = 'Payment verification failed: ${response.body}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error verifying payment: $e';
      logger.e('Stripe verification error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _openPaymentWebView(
      String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    // Validate URL one more time before opening WebView
    if (!_isValidUrl(url)) {
      errorMessage.value = 'Invalid payment URL format';
      logger.e('Invalid URL format: $url');
      return false;
    }

    logger.i('Opening Stripe WebView: $url, Reference: $reference');

    try {
      final result = await Get.to<bool>(
        () => PaymentWebViewScreen(
          url: url,
          reference: reference,
          paymentMethod: paymentMethod,
          orderId: orderId,
          onPaymentComplete: (success, message, {orderId}) {
            if (success) {
              Get.off(() => PaymentSuccessScreen(
                    orderId: orderId!,
                    amount: Get.find<CartController>().totalPrice + 7.50,
                    paymentMethod: paymentMethod,
                    reference: reference,
                  ));
            } else {
              showFailureSnackbar('Payment Failed');
            }
          },
        ),
        transition: Transition.fadeIn,
      );

      return result ?? false;
    } catch (e) {
      logger.e('Error opening WebView: $e');
      errorMessage.value = 'Failed to open payment page: $e';
      return false;
    }
  }
}
