import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/service/auth_service.dart';
import '../../base/res/base_url.dart';
import '../../cart/controllers/address_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../views/payment_success_screen.dart';
import '../views/payment_webview.dart';

final logger = Logger();

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

abstract class BasePaymentController extends GetxController {
  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
    bool resume = false,
  });

  Future<bool> verifyPayment(String reference);
  bool verificationUnavailable = false;

  Future<bool> _verifyGateway(String gateway, String reference) async {
    verificationUnavailable = false;
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        verificationUnavailable = true;
        return false;
      }
      final response = await http.get(
        Uri.parse(
            '$baseURLGeneral/payments/verify-$gateway-payment/${Uri.encodeComponent(reference)}/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 && response.statusCode != 400) {
        verificationUnavailable = true;
        logger.w('$gateway verification returned HTTP ${response.statusCode}');
        return false;
      }
      final body = jsonDecode(response.body);
      final status = body is Map ? body['payment_status'] : null;
      verificationUnavailable = status != 'Paid' && status != 'Unpaid';
      return response.statusCode == 200 && status == 'Paid';
    } catch (error) {
      verificationUnavailable = true;
      logger.w('$gateway verification unavailable: ${error.runtimeType}');
      return false;
    }
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<Map<String, dynamic>?> quoteCheckout() async {
    final cart = Get.find<CartController>();
    final addressId = Get.find<AddressController>().selectedAddress.value?.id;
    if (addressId == null || cart.cartItems.isEmpty) {
      errorMessage.value = 'Select an address and add items to your cart.';
      return null;
    }
    final items = cart.cartItems
        .map((item) => jsonEncode({
              'id': item.product?.id,
              'quantity': item.quantity ?? 1,
              'sizes': item.size,
              'colors': item.color,
            }))
        .toList()
      ..sort();

    final draft = {
      'address': addressId,
      'order_products': items.map(jsonDecode).toList(),
    };
    final quote = await _checkoutRequest('quote', draft);
    return quote == null ? null : {...quote, 'draft': draft};
  }

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> quote) async {
    final draft = quote['draft'] as Map<String, dynamic>;
    final draftId = jsonEncode(draft);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      errorMessage.value = 'Please sign in again.';
      return null;
    }

    final cacheKey = 'checkout_drafts_$userId';
    final drafts = _checkoutDrafts(prefs, cacheKey);
    final saved = drafts[draftId] as Map<String, dynamic>?;
    final key = saved?['key'] as String? ?? _newCheckoutKey();
    if (saved == null) {
      drafts[draftId] = {'key': key};
      if (!await prefs.setString(cacheKey, jsonEncode(drafts))) {
        errorMessage.value = 'Unable to save this checkout. Please try again.';
        return null;
      }
    }

    final order = await _checkoutRequest(
      'add',
      {...draft, 'expected_total': quote['total']},
      key: key,
    );
    if (order != null) {
      final current = _checkoutDrafts(prefs, cacheKey);
      current[draftId] = {'key': key, 'order_id': order['id']};
      await prefs.setString(cacheKey, jsonEncode(current));
    }
    return order;
  }

  Map<String, dynamic> _checkoutDrafts(SharedPreferences prefs, String key) {
    final stored = prefs.getString(key);
    return stored == null ? {} : jsonDecode(stored) as Map<String, dynamic>;
  }

  String _newCheckoutKey() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-${value.substring(20)}';
  }

  Future<void> forgetCheckout(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'checkout_drafts_${prefs.getInt('user_id')}';
    final drafts = _checkoutDrafts(prefs, cacheKey);
    final length = drafts.length;
    drafts.removeWhere((_, draft) => draft['order_id'] == orderId);
    if (drafts.length != length) {
      await prefs.setString(cacheKey, jsonEncode(drafts));
    }
  }

  Future<Map<String, dynamic>?> _checkoutRequest(
    String action,
    Map<String, dynamic> body, {
    String? key,
  }) async {
    errorMessage.value = '';
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Please sign in again.';
        return null;
      }
      final response = await http
          .post(
            Uri.parse('$baseURLGeneral/orders/$action/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              if (key != null) 'Idempotency-Key': key,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      errorMessage.value = _initiationError(response.body);
    } catch (_) {
      errorMessage.value = 'Could not reach checkout. Please try again.';
    }
    return null;
  }

  Future<bool> _openPaymentWebView(
    String url,
    String reference,
    String paymentMethod,
    int orderId,
    double amount,
    bool resume,
    bool reused,
  ) async {
    final alreadyVerified = reused && await verifyPayment(reference);
    final message = alreadyVerified
        ? PaymentWebViewScreen.verified
        : await Get.to<String>(
            () => PaymentWebViewScreen(
              url: url,
              reference: reference,
              paymentMethod: paymentMethod,
              orderId: orderId,
            ),
            transition: Transition.fadeIn,
          );
    if (message != PaymentWebViewScreen.verified) {
      errorMessage.value = message == PaymentWebViewScreen.dismissed
          ? ''
          : 'Payment has not been confirmed.';
      return false;
    }

    try {
      await forgetCheckout(orderId);
    } catch (_) {
      // A completed payment remains successful if local storage is unavailable.
    }
    if (!resume) {
      if (Get.isRegistered<CartController>()) {
        unawaited(Get.find<CartController>().fetchCartItems());
      }
      Get.offAll(() => PaymentSuccessScreen(
            orderId: orderId,
            amount: amount,
            paymentMethod: paymentMethod,
            reference: reference,
          ));
    }
    return true;
  }

  String _initiationError(String body) {
    try {
      final data = jsonDecode(body);
      if (data is List && data.isNotEmpty && data.first is String) {
        return data.first as String;
      }
      if (data is Map) {
        final error = data['error'];
        if (error is Map) {
          final details = error['details'];
          if (details is List &&
              details.isNotEmpty &&
              details.first is String) {
            return details.first as String;
          }
        }
        final message = data['message'] ?? data['detail'];
        if (message is String) return message;
      }
    } on FormatException {
      // The provider or API may return a non-JSON error response.
    }
    return 'Unable to open checkout. Please try again from My Orders.';
  }

  void clearPaymentData() {
    errorMessage.value = '';
    isLoading.value = false;
  }
}

class PaystackPaymentController extends BasePaymentController {
  static PaystackPaymentController get to => Get.find();

  @override
  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
    bool resume = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId, if (resume) 'resume': true};
      logger.i('Paystack payment initiation payload: $payload');

      final response = await http
          .post(
            Uri.parse('$baseURLGeneral/payments/initiate-paystack-payment/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));

      logger.i('Paystack API response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

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

        return await _openPaymentWebView(
            authorizationUrl,
            reference,
            'PayStack',
            orderId,
            amount,
            resume,
            responseData['reused'] == true);
      } else {
        final errorBody = response.body;
        errorMessage.value = _initiationError(errorBody);
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

  @override
  Future<bool> verifyPayment(String reference) =>
      _verifyGateway('paystack', reference);

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
}

class FlutterwavePaymentController extends BasePaymentController {
  static FlutterwavePaymentController get to => Get.find();

  @override
  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
    bool resume = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId, if (resume) 'resume': true};
      logger.i('Flutterwave payment initiation payload: $payload');

      final response = await http
          .post(
            Uri.parse('$baseURLGeneral/payments/initiate-flutterwave-payment/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));

      logger.i('Flutterwave API response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

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

        return await _openPaymentWebView(paymentLink, reference, 'Flutterwave',
            orderId, amount, resume, responseData['reused'] == true);
      } else {
        final errorBody = response.body;
        errorMessage.value = _initiationError(errorBody);
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

  @override
  Future<bool> verifyPayment(String reference) =>
      _verifyGateway('flutterwave', reference);

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
}

class StripePaymentController extends BasePaymentController {
  static StripePaymentController get to => Get.find();

  @override
  Future<bool> initiatePayment({
    required double amount,
    required int orderId,
    bool resume = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await AuthService.instance.getToken();
      if (token == null) {
        errorMessage.value = 'Authentication token not found';
        return false;
      }

      final payload = {'order_id': orderId, if (resume) 'resume': true};
      logger.i('Stripe payment initiation payload: $payload');

      final response = await http
          .post(
            Uri.parse('$baseURLGeneral/payments/initiate-stripe-payment/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));

      logger.i('Stripe API response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

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

        return await _openPaymentWebView(checkoutUrl, sessionId, 'Stripe',
            orderId, amount, resume, responseData['reused'] == true);
      } else {
        final errorBody = response.body;
        errorMessage.value = _initiationError(errorBody);
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

  @override
  Future<bool> verifyPayment(String reference) =>
      _verifyGateway('stripe', reference);

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
}
