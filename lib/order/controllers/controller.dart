import 'dart:convert';
import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
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
      final token = prefs.getString('token');
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
        logger.e('Order creation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error creating order: $e';
      logger.e('Order creation error: $e', error: e, stackTrace: StackTrace.current);
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
      final token = prefs.getString('token');
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

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Paystack response: $responseData');

        final authorizationUrl = responseData['data']?['authorization_url'];
        final reference = responseData['data']?['reference'];

        if (authorizationUrl == null || reference == null) {
          errorMessage.value = 'Invalid Paystack response data';
          return false;
        }

        return await _openPaymentWebView(authorizationUrl, reference, 'PayStack', orderId);
      } else {
        errorMessage.value = 'Failed to initiate Paystack payment: ${response.body}';
        logger.e('Paystack initiation failed: ${response.body}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Paystack payment error: $e';
      logger.e('Paystack payment error: $e');
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
      final token = prefs.getString('token');
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseURLGeneral/payments/verify-paystack-payment/$reference/'),
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

  Future<bool> _openPaymentWebView(String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    logger.i('Opening Paystack WebView: $url, Reference: $reference');

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
            // Get.snackbar('Payment Failed', message ?? 'Payment was cancelled or failed',
            //     backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                showFailureSnackbar('Payment Failed');
          }
        },
      ),
      transition: Transition.fadeIn,
    );

    return result ?? false;
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
      final token = prefs.getString('token');
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

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Flutterwave response: $responseData');

        final paymentLink = responseData['data']?['link'];
        final reference = responseData['data']?['reference'];

        if (paymentLink == null || reference == null) {
          errorMessage.value = 'Invalid Flutterwave response data';
          return false;
        }

        return await _openPaymentWebView(paymentLink, reference, 'Flutterwave', orderId);
      } else {
        errorMessage.value = 'Failed to initiate Flutterwave payment: ${response.body}';
        logger.e('Flutterwave initiation failed: ${response.body}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Flutterwave payment error: $e';
      logger.e('Flutterwave payment error: $e');
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
      final token = prefs.getString('token');
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseURLGeneral/payments/verify-flutterwave-payment/$reference/'),
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

  Future<bool> _openPaymentWebView(String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    logger.i('Opening Flutterwave WebView: $url, Reference: $reference');

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
            // Get.snackbar('Payment Failed', message ?? 'Payment was cancelled or failed',
            //     backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
            showFailureSnackbar('Payment Failed');
          }
        },
      ),
      transition: Transition.fadeIn,
    );

    return result ?? false;
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
      final token = prefs.getString('token');
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

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Stripe response: $responseData');

        final checkoutUrl = responseData['data']?['link'];
        final sessionId = responseData['data']?['reference'];

        if (checkoutUrl == null || sessionId == null) {
          errorMessage.value = 'Invalid Stripe response data';
          return false;
        }

        return await _openPaymentWebView(checkoutUrl, sessionId, 'Stripe', orderId);
      } else {
        errorMessage.value = 'Failed to initiate Stripe payment: ${response.body}';
        logger.e('Stripe initiation failed: ${response.body}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Stripe payment error: $e';
      logger.e('Stripe payment error: $e');
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
      final token = prefs.getString('token');
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

  Future<bool> _openPaymentWebView(String url, String reference, String paymentMethod, int orderId) async {
    if (url.isEmpty) {
      errorMessage.value = 'Payment URL is empty';
      return false;
    }

    logger.i('Opening Stripe WebView: $url, Reference: $reference');

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
            // Get.snackbar('Payment Failed', message ?? 'Payment was cancelled or failed',
            //     backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
            showFailureSnackbar('Payment Failed');
          }
        },
      ),
      transition: Transition.fadeIn,
    );

    return result ?? false;
  }
}