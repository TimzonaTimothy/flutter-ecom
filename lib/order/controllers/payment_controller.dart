import 'dart:convert';
import 'dart:developer';
import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/utils/my_request.dart';
import '../../cart/controllers/address_controller.dart';
import '../../cart/controllers/cart_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../views/payment_success_screen.dart';
import '../views/payment_webview.dart';


// class PaymentController extends GetxController {
//   static PaymentController get to => Get.find();

//   var isLoading = false.obs;
//   var selectedPaymentMethod = ''.obs;
//   String? _errorMessage;

//   String? get errorMessage => _errorMessage;

//   // Payment method types
//   static const String PAYSTACK = 'PayStack';
//   static const String FLUTTERWAVE = 'Flutterwave';
//   static const String STRIPE = 'Stripe';

//   /// Initialize payment based on selected method
//   Future<bool> initiatePayment({
//     required String paymentMethod,
//     required int orderId,
//     required double amount,
//     required String currency,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;
//       selectedPaymentMethod.value = paymentMethod;

//       log('Initiating $paymentMethod payment for amount: $amount');

//       switch (paymentMethod) {
//         case PAYSTACK:
//           return await _initiatePaystackPayment(amount, currency, orderId, metadata);
//         case FLUTTERWAVE:
//           return await _initiateFlutterwavePayment(amount, currency, orderId, metadata);
//         case STRIPE:
//           return await _initiateStripePayment(amount, currency, orderId, metadata);
//         default:
//           _errorMessage = 'Unsupported payment method';
//           return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Error initiating payment: $e';
//       log('Error initiating payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> _initiatePaystackPayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, // Fixed: Use order_id instead of amount/currency
//       };

//       log('Paystack payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-paystack-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Paystack payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Paystack response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final authorizationUrl = responseData['data']?['authorization_url'];
//       final reference = responseData['data']?['reference'];

//       if (authorizationUrl == null || authorizationUrl.isEmpty) {
//         _errorMessage = 'Paystack authorization URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Paystack reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final launched = await _launchPaymentUrl(authorizationUrl);
//       if (!launched) {
//         return false;
//       }

//       return await _pollPaymentVerification(reference, PAYSTACK);
//     } catch (e) {
//       _errorMessage = 'Paystack payment error: $e';
//       log('Paystack payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateFlutterwavePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, // Fixed: Use order_id instead of individual fields
//       };

//       log('Flutterwave payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-flutterwave-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Flutterwave payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Flutterwave response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final paymentLink = responseData['data']?['link'];
//       final reference = responseData['data']?['reference'];

//       if (paymentLink == null || paymentLink.isEmpty) {
//         _errorMessage = 'Flutterwave payment link is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Flutterwave reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final launched = await _launchPaymentUrl(paymentLink);
//       if (!launched) {
//         return false;
//       }

//       return await _pollPaymentVerification(reference, FLUTTERWAVE);
//     } catch (e) {
//       _errorMessage = 'Flutterwave payment error: $e';
//       log('Flutterwave payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateStripePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, // Fixed: Use order_id instead of individual fields
//       };

//       log('Stripe payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-stripe-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Stripe payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Stripe response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final checkoutUrl = responseData['data']?['link'];
//       final sessionId = responseData['data']?['reference'];

//       if (checkoutUrl == null || checkoutUrl.isEmpty) {
//         _errorMessage = 'Stripe checkout URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (sessionId == null || sessionId.isEmpty) {
//         _errorMessage = 'Stripe session ID is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final launched = await _launchPaymentUrl(checkoutUrl);
//       if (!launched) {
//         return false;
//       }

//       return await _pollPaymentVerification(sessionId, STRIPE);
//     } catch (e) {
//       _errorMessage = 'Stripe payment error: $e';
//       log('Stripe payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   // Fixed: Multiple fallback strategies for URL launching
//   Future<bool> _launchPaymentUrl(String url) async {
//     try {
//       if (url.isEmpty) {
//         _errorMessage = 'Payment URL is empty';
//         log('Error: Payment URL is empty');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       // Clean the URL - remove any whitespace and invisible characters
//       final cleanUrl = url.trim().replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
//       log('Attempting to launch cleaned URL: $cleanUrl');

//       final uri = Uri.tryParse(cleanUrl);
//       if (uri == null) {
//         _errorMessage = 'Invalid payment URL format: $cleanUrl';
//         log('Error: Invalid URL format: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (!uri.hasScheme) {
//         _errorMessage = 'Payment URL missing scheme (http/https): $cleanUrl';
//         log('Error: URL missing scheme: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (!uri.isAbsolute) {
//         _errorMessage = 'Payment URL is not absolute: $cleanUrl';
//         log('Error: URL is not absolute: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       // Strategy 1: Try external application mode first
//       log('Strategy 1: Attempting external application launch...');
//       try {
//         final launched = await launchUrl(
//           uri,
//           mode: LaunchMode.externalApplication,
//         );
        
//         if (launched) {
//           log('Successfully launched URL with external application: $cleanUrl');
//           return true;
//         }
//       } catch (e) {
//         log('External application launch failed: $e');
//       }

//       // Strategy 2: Try platform default mode
//       log('Strategy 2: Attempting platform default launch...');
//       try {
//         final launched = await launchUrl(
//           uri,
//           mode: LaunchMode.platformDefault,
//         );
        
//         if (launched) {
//           log('Successfully launched URL with platform default: $cleanUrl');
//           return true;
//         }
//       } catch (e) {
//         log('Platform default launch failed: $e');
//       }

//       // Strategy 3: Try external non-browser application
//       log('Strategy 3: Attempting external non-browser launch...');
//       try {
//         final launched = await launchUrl(
//           uri,
//           mode: LaunchMode.externalNonBrowserApplication,
//         );
        
//         if (launched) {
//           log('Successfully launched URL with external non-browser: $cleanUrl');
//           return true;
//         }
//       } catch (e) {
//         log('External non-browser launch failed: $e');
//       }

//       // Strategy 4: Try in-app web view as last resort
//       log('Strategy 4: Attempting in-app web view launch...');
//       try {
//         final launched = await launchUrl(
//           uri,
//           mode: LaunchMode.inAppWebView,
//           webViewConfiguration: const WebViewConfiguration(
//             enableJavaScript: true,
//             enableDomStorage: true,
//           ),
//         );
        
//         if (launched) {
//           log('Successfully launched URL with in-app web view: $cleanUrl');
//           return true;
//         }
//       } catch (e) {
//         log('In-app web view launch failed: $e');
//       }

//       // Strategy 5: Show URL to user as fallback
//       log('All launch strategies failed. Showing URL to user for manual copy.');
//       _showUrlDialog(cleanUrl);
      
//       // Return true since we provided the URL to the user
//       return true;

//     } catch (e) {
//       _errorMessage = 'Error launching payment URL: $e';
//       log('Error launching payment URL: $e');
//       showFailureSnackbar(_errorMessage!);
      
//       // As a last resort, show the URL to the user
//       _showUrlDialog(url);
//       return true;
//     }
//   }

//   // Helper method to show URL to user when automatic launch fails
//   void _showUrlDialog(String url) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Payment URL'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Unable to automatically open payment page. Please copy and paste this URL in your browser:'),
//             const SizedBox(height: 10),
//             SelectableText(
//               url,
//               style: const TextStyle(
//                 fontFamily: 'monospace',
//                 fontSize: 12,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // Try to copy to clipboard
//               _copyToClipboard(url);
//             },
//             child: const Text('Copy URL'),
//           ),
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to copy URL to clipboard
//   void _copyToClipboard(String url) {
//     try {
//       // You'll need to add clipboard package: flutter/services
//       Clipboard.setData(ClipboardData(text: url));
//       Get.snackbar(
//         'Copied',
//         'Payment URL copied to clipboard',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       log('Failed to copy to clipboard: $e');
//     }
//   }

//   /// Poll for payment verification
//   Future<bool> _pollPaymentVerification(
//     String reference,
//     String paymentMethod,
//   ) async {
//     if (reference.isEmpty) {
//       _errorMessage = 'Payment reference is empty';
//       return false;
//     }

//     const maxAttempts = 60; // 5 minutes with 5-second intervals
//     const pollInterval = Duration(seconds: 5);

//     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
//       try {
//         log('Polling payment verification (attempt $attempt/$maxAttempts) for reference: $reference');
        
//         await Future.delayed(pollInterval);
        
//         final verified = await _verifyPayment(reference, paymentMethod);
        
//         if (verified) {
//           log('Payment verified successfully for reference: $reference');
//           return true;
//         }
        
//         // Continue polling if not verified yet
//         if (attempt < maxAttempts) {
//           log('Payment not verified yet, retrying in ${pollInterval.inSeconds} seconds...');
//         }
        
//       } catch (e) {
//         log('Error during polling attempt $attempt: $e');
//         // Continue polling even if there's an error
//       }
//     }

//     _errorMessage = 'Payment verification timed out for reference: $reference';
//     log('Payment verification timed out for reference: $reference');
//     return false;
//   }

//   /// Verify payment with backend
//   Future<bool> _verifyPayment(String reference, String paymentMethod) async {
//     try {
//       String endpoint;
      
//       switch (paymentMethod) {
//         case PAYSTACK:
//           endpoint = 'payments/verify-paystack-payment/$reference/';
//           break;
//         case FLUTTERWAVE:
//           endpoint = 'payments/verify-flutterwave-payment/$reference/';
//           break;
//         case STRIPE:
//           endpoint = 'payments/verify-stripe-payment/$reference'; // Fixed: No trailing slash for Stripe
//           break;
//         default:
//           throw 'Unknown payment method: $paymentMethod';
//       }

//       log('Verifying payment with endpoint: $endpoint');

//       final response = await MyRequest(
//         endpoint,
//         {},
//         true, // auth required
//         200, // success code
//       ).getApi();

//       if (response != null) {
//         final responseData = jsonDecode(response);
//         log('Payment verification response: $responseData');
        
//         final paymentStatus = responseData['payment_status'];
//         final isVerified = paymentStatus == 'Paid';
        
//         log('Payment status: $paymentStatus, Verified: $isVerified');
//         return isVerified;
//       }

//       log('Payment verification response is null');
//       return false;
//     } catch (e) {
//       log('Error verifying payment: $e');
//       return false;
//     }
//   }

//   /// Manual payment verification (for when user returns to app)
//   Future<bool> verifyPaymentManually(String reference) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       if (reference.isEmpty) {
//         _errorMessage = 'Payment reference is required';
//         return false;
//       }

//       if (selectedPaymentMethod.value.isEmpty) {
//         _errorMessage = 'Payment method not found';
//         return false;
//       }

//       final verified = await _verifyPayment(reference, selectedPaymentMethod.value);
      
//       if (!verified) {
//         _errorMessage = 'Payment verification failed';
//       }
      
//       return verified;
//     } catch (e) {
//       _errorMessage = 'Error verifying payment: $e';
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Get total cart amount
//   double getTotalAmount() {
//     final cartController = Get.find<CartController>();
//     return cartController.totalPrice;
//   }

//   /// Create order and initiate payment
//   Future<bool> processPayment(String paymentMethod) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt("user_id");
//       if (userId == null) {
//         _errorMessage = 'User ID not found. Please log in again.';
//         return false;
//       }

//       // Get cart and address data
//       final cartController = Get.find<CartController>();
//       final addressController = Get.find<AddressController>();

//       if (cartController.cartItems.isEmpty) {
//         _errorMessage = 'Cart is empty';
//         return false;
//       }

//       if (addressController.selectedAddress.value == null) {
//         _errorMessage = 'No shipping address selected';
//         return false;
//       }

//       // Create order first
//       final orderData = {
//         'order_products': cartController.cartItems.map((item) => {
//               'id': item.product?.id,
//               'quantity': item.quantity,
//               'sizes': item.size,
//               'colors': item.color,
//             }).toList(),
//         'address': addressController.selectedAddress.value!.id,
//         'customer_id': userId,
//         'total_quantity': cartController.totalQuantity,
//         'subtotal': cartController.totalPrice,
//         'total': cartController.totalPrice + 7.50, // Add shipping + tax
//         'delivery_status': 'Pending',
//         'payment_status': 'Unpaid',
//       };

//       log('Order payload: $orderData');
//       final orderResponse = await MyRequest(
//         'orders/add/', 
//         orderData,
//         true,
//         201,
//       ).postApi();

//       if (orderResponse == null) {
//         _errorMessage = 'Failed to create order';
//         return false;
//       }

//       final orderResponseData = jsonDecode(orderResponse);
//       final orderId = orderResponseData['id'];
      
//       if (orderId == null) {
//         _errorMessage = 'Order ID not received from server';
//         return false;
//       }

//       log('Order created successfully with ID: $orderId');
      
//       // Initiate payment with the created order ID
//       final amount = cartController.totalPrice;
//       final metadata = {
//         'order_data': orderData,
//         'user_id': userId,
//       };

//       return await initiatePayment(
//         paymentMethod: paymentMethod,
//         amount: amount,
//         metadata: metadata,
//         orderId: orderId,
//         currency: paymentMethod == STRIPE ? 'usd' : 'NGN',
//       );

//     } catch (e) {
//       _errorMessage = 'Error processing payment: $e';
//       log('Error processing payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Clear payment data
//   void clearPaymentData() {
//     selectedPaymentMethod.value = '';
//     _errorMessage = null;
//     isLoading.value = false;
//   }

//   @override
//   void onClose() {
//     clearPaymentData();
//     super.onClose();
//   }

//   // Helper methods (you need to implement these based on your app structure)
//   String extractErrorMessage(String responseBody) {
//     try {
//       final decoded = jsonDecode(responseBody);
//       return decoded['message'] ?? decoded['error'] ?? 'Unknown error occurred';
//     } catch (e) {
//       return 'Error parsing server response';
//     }
//   }

//   void showFailureSnackbar(String message) {
//     Get.snackbar(
//       'Payment Error',
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 5),
//     );
//   }
// }


// class PaymentController extends GetxController {
//   static PaymentController get to => Get.find();

//   var isLoading = false.obs;
//   var selectedPaymentMethod = ''.obs;
//   String? _errorMessage;

//   String? get errorMessage => _errorMessage;

//   // Payment method types
//   static const String PAYSTACK = 'PayStack';
//   static const String FLUTTERWAVE = 'Flutterwave';
//   static const String STRIPE = 'Stripe';


//   /// Initialize payment based on selected method
//   Future<bool> initiatePayment({
//     required String paymentMethod,
//     required int orderId,
//     required double amount,
//     required String currency,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;
//       selectedPaymentMethod.value = paymentMethod;

//       log('Initiating $paymentMethod payment for amount: $amount');

//       switch (paymentMethod) {
//         case PAYSTACK:
//           return await _initiatePaystackPayment(amount, currency, orderId, metadata);
//         case FLUTTERWAVE:
//           return await _initiateFlutterwavePayment(amount, currency, orderId, metadata);
//         case STRIPE:
//           return await _initiateStripePayment(amount, currency, orderId, metadata);
//         default:
//           _errorMessage = 'Unsupported payment method';
//           return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Error initiating payment: $e';
//       log('Error initiating payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }


  
//   // Fixed: Multiple fallback strategies for URL launching
//   Future<bool> _launchPaymentUrl(String url) async {
//     try {
//       if (url.isEmpty) {
//         _errorMessage = 'Payment URL is empty';
//         log('Error: Payment URL is empty');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       // Clean the URL - remove any whitespace and invisible characters
//       final cleanUrl = url.trim().replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
//       log('Attempting to launch cleaned URL: $cleanUrl');

//       final uri = Uri.tryParse(cleanUrl);
//       if (uri == null) {
//         _errorMessage = 'Invalid payment URL format: $cleanUrl';
//         log('Error: Invalid URL format: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (!uri.hasScheme) {
//         _errorMessage = 'Payment URL missing scheme (http/https): $cleanUrl';
//         log('Error: URL missing scheme: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (!uri.isAbsolute) {
//         _errorMessage = 'Payment URL is not absolute: $cleanUrl';
//         log('Error: URL is not absolute: $cleanUrl');
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       // Strategy 1: Try external application mode first
//       log('Strategy 1: Attempting external application launch...');
      

//       // Strategy 2: Try platform default mode
//       log('Strategy 2: Attempting platform default launch...');
//       try {
//         final launched = await launchUrl(
//           uri,
//           mode: LaunchMode.platformDefault,
//         );
        
//         if (launched) {
//           log('Successfully launched URL with platform default: $cleanUrl');
//           return true;
//         }
//       } catch (e) {
//         log('Platform default launch failed: $e');
//       }

     

//       // Strategy 5: Show URL to user as fallback
//       log('All launch strategies failed. Showing URL to user for manual copy.');
//       showFailureSnackbar(cleanUrl);
      
//       // Return true since we provided the URL to the user
//       return true;

//     } catch (e) {
//       _errorMessage = 'Error launching payment URL: $e';
//       log('Error launching payment URL: $e');
//       showFailureSnackbar(_errorMessage!);
      
//       // As a last resort, show the URL to the user
//       showFailureSnackbar(url);
//       return true;
//     }
//   }


//   Future<bool> _initiatePaystackPayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, 
//       };

//       log('Paystack payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-paystack-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Paystack payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Paystack response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final authorizationUrl = responseData['data']?['authorization_url'];
//       final reference = responseData['data']?['reference'];

//       if (authorizationUrl == null || authorizationUrl.isEmpty) {
//         _errorMessage = 'Paystack authorization URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Paystack reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final launched = await _launchPaymentUrl(authorizationUrl);
//       if (!launched) {
//         return false;
//       }

//       return await _pollPaymentVerification(reference, PAYSTACK);
//     } catch (e) {
//       _errorMessage = 'Paystack payment error: $e';
//       log('Paystack payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateFlutterwavePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, // Fixed: Use order_id instead of individual fields
//       };

//       log('Flutterwave payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-flutterwave-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Flutterwave payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Flutterwave response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final paymentLink = responseData['data']?['link'];
//       final reference = responseData['data']?['reference'];

//       if (paymentLink == null || paymentLink.isEmpty) {
//         _errorMessage = 'Flutterwave payment link is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Flutterwave reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }
//     final launched = await _launchPaymentUrl(paymentLink);
//       if (!launched) {
//         return false;
//       }
//       return await _pollPaymentVerification(reference, FLUTTERWAVE);
//       // _openPaymentWebView(paymentLink, reference, FLUTTERWAVE);
//     } catch (e) {
//       _errorMessage = 'Flutterwave payment error: $e';
//       log('Flutterwave payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateStripePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, // Fixed: Use order_id instead of individual fields
//       };

//       log('Stripe payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-stripe-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Stripe payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Stripe response: $responseData');

//       // Fixed: Use correct response structure from backend
//       final checkoutUrl = responseData['data']?['link'];
//       final sessionId = responseData['data']?['reference'];

//       if (checkoutUrl == null || checkoutUrl.isEmpty) {
//         _errorMessage = 'Stripe checkout URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (sessionId == null || sessionId.isEmpty) {
//         _errorMessage = 'Stripe session ID is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       // _openPaymentWebView(checkoutUrl, sessionId, STRIPE); 
//       // return true; 
//        final launched = await _launchPaymentUrl(checkoutUrl);
//       if (!launched) {
//         return false;
//       }
//       return await _pollPaymentVerification(sessionId, STRIPE);
//     } catch (e) {
//       _errorMessage = 'Stripe payment error: $e';
//       log('Stripe payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   // WebView-based payment launcher
//   void _openPaymentWebView(String url, String reference, String paymentMethod) {
//     if (url.isEmpty) {
//       _errorMessage = 'Payment URL is empty';
//       showFailureSnackbar(_errorMessage!);
//       return;
//     }

//     final cleanUrl = url.trim();
//     log('Opening payment WebView for URL: $cleanUrl');

//     Get.to(
//       () => PaymentWebViewScreen(
//         url: cleanUrl,
//         reference: reference,
//         paymentMethod: paymentMethod,
//         onPaymentComplete: (bool success, String? message) {
//           if (success) {
//             // Payment completed successfully
//             Get.back(); // Close WebView
//             Get.snackbar(
//               'Payment Successful',
//               message ?? 'Your payment has been processed successfully',
//               snackPosition: SnackPosition.TOP,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 3),
//             );
//           } else {
//             // Payment failed or cancelled
//             Get.back(); // Close WebView
//             _errorMessage = message ?? 'Payment was cancelled or failed';
//             showFailureSnackbar(_errorMessage!);
//           }
//         },
//       ),
//       fullscreenDialog: true,
//     );
//   }

//   /// Poll for payment verification
//   Future<bool> _pollPaymentVerification(
//     String reference,
//     String paymentMethod,
//   ) async {
//     if (reference.isEmpty) {
//       _errorMessage = 'Payment reference is empty';
//       return false;
//     }

//     const maxAttempts = 60; // 5 minutes with 5-second intervals
//     const pollInterval = Duration(seconds: 5);

//     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
//       try {
//         log('Polling payment verification (attempt $attempt/$maxAttempts) for reference: $reference');
        
//         await Future.delayed(pollInterval);
        
//         final verified = await _verifyPayment(reference, paymentMethod);
        
//         if (verified) {
//           log('Payment verified successfully for reference: $reference');
//           return true;
//         }
        
//         // Continue polling if not verified yet
//         if (attempt < maxAttempts) {
//           log('Payment not verified yet, retrying in ${pollInterval.inSeconds} seconds...');
//         }
        
//       } catch (e) {
//         log('Error during polling attempt $attempt: $e');
//         // Continue polling even if there's an error
//       }
//     }

//     _errorMessage = 'Payment verification timed out for reference: $reference';
//     log('Payment verification timed out for reference: $reference');
//     return false;
//   }

//   /// Verify payment with backend
//   Future<bool> _verifyPayment(String reference, String paymentMethod) async {
//     try {
//       String endpoint;
      
//       switch (paymentMethod) {
//         case PAYSTACK:
//           endpoint = 'payments/verify-paystack-payment/$reference/';
//           break;
//         case FLUTTERWAVE:
//           endpoint = 'payments/verify-flutterwave-payment/$reference/';
//           break;
//         case STRIPE:
//           endpoint = 'payments/verify-stripe-payment/$reference'; 
//           break;
//         default:
//           throw 'Unknown payment method: $paymentMethod';
//       }

//       log('Verifying payment with endpoint: $endpoint');

//       final response = await MyRequest(
//         endpoint,
//         {},
//         true, // auth required
//         200, // success code
//       ).getApi();

//       if (response != null) {
//         final responseData = jsonDecode(response);
//         log('Payment verification response: $responseData');
        
//         final paymentStatus = responseData['payment_status'];
//         final isVerified = paymentStatus == 'Paid';
        
//         log('Payment status: $paymentStatus, Verified: $isVerified');
//         return isVerified;
//       }

//       log('Payment verification response is null');
//       return false;
//     } catch (e) {
//       log('Error verifying payment: $e');
//       return false;
//     }
//   }

//   /// Manual payment verification (for when user returns to app)
//   Future<bool> verifyPaymentManually(String reference) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       if (reference.isEmpty) {
//         _errorMessage = 'Payment reference is required';
//         return false;
//       }

//       if (selectedPaymentMethod.value.isEmpty) {
//         _errorMessage = 'Payment method not found';
//         return false;
//       }

//       final verified = await _verifyPayment(reference, selectedPaymentMethod.value);
      
//       if (!verified) {
//         _errorMessage = 'Payment verification failed';
//       }
      
//       return verified;
//     } catch (e) {
//       _errorMessage = 'Error verifying payment: $e';
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Get total cart amount
//   double getTotalAmount() {
//     final cartController = Get.find<CartController>();
//     return cartController.totalPrice;
//   }

//   /// Create order and initiate payment
//   Future<bool> processPayment(String paymentMethod) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt("user_id");
//       if (userId == null) {
//         _errorMessage = 'User ID not found. Please log in again.';
//         return false;
//       }

//       // Get cart and address data
//       final cartController = Get.find<CartController>();
//       final addressController = Get.find<AddressController>();

//       if (cartController.cartItems.isEmpty) {
//         _errorMessage = 'Cart is empty';
//         return false;
//       }

//       if (addressController.selectedAddress.value == null) {
//         _errorMessage = 'No shipping address selected';
//         return false;
//       }

//       // Create order first
//       final orderData = {
//         'order_products': cartController.cartItems.map((item) => {
//               'id': item.product?.id,
//               'quantity': item.quantity,
//               'sizes': item.size,
//               'colors': item.color,
//             }).toList(),
//         'address': addressController.selectedAddress.value!.id,
//         'customer_id': userId,
//         'total_quantity': cartController.totalQuantity,
//         'subtotal': cartController.totalPrice,
//         'total': cartController.totalPrice + 7.50, // Add shipping + tax
//         'delivery_status': 'Pending',
//         'payment_status': 'Unpaid',
//       };

//       log('Order payload: $orderData');
//       final orderResponse = await MyRequest(
//         'orders/add/', 
//         orderData,
//         true,
//         201,
//       ).postApi();

//       if (orderResponse == null) {
//         _errorMessage = 'Failed to create order';
//         return false;
//       }

//       final orderResponseData = jsonDecode(orderResponse);
//       final orderId = orderResponseData['id'];
      
//       if (orderId == null) {
//         _errorMessage = 'Order ID not received from server';
//         return false;
//       }

//       log('Order created successfully with ID: $orderId');
      
//       // Initiate payment with the created order ID
//       final amount = cartController.totalPrice;
//       final metadata = {
//         'order_data': orderData,
//         'user_id': userId,
//       };

//       return await initiatePayment(
//         paymentMethod: paymentMethod,
//         amount: amount,
//         metadata: metadata,
//         orderId: orderId,
//         currency: paymentMethod == STRIPE ? 'usd' : 'NGN',
//       );

//     } catch (e) {
//       _errorMessage = 'Error processing payment: $e';
//       log('Error processing payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Clear payment data
//   void clearPaymentData() {
//     selectedPaymentMethod.value = '';
//     _errorMessage = null;
//     isLoading.value = false;
//   }

//   @override
//   void onClose() {
//     clearPaymentData();
//     super.onClose();
//   }

  
// }



// class PaymentController extends GetxController {
//   static PaymentController get to => Get.find();

//   var isLoading = false.obs;
//   var selectedPaymentMethod = ''.obs;
//   var currentOrderId = 0.obs;
//   var paymentReference = ''.obs;
//   String? _errorMessage;

//   String? get errorMessage => _errorMessage;

//   // Payment method types
//   static const String PAYSTACK = 'PayStack';
//   static const String FLUTTERWAVE = 'Flutterwave';
//   static const String STRIPE = 'Stripe';

//   /// Initialize payment based on selected method
//   Future<bool> initiatePayment({
//     required String paymentMethod,
//     required int orderId,
//     required double amount,
//     required String currency,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;
//       selectedPaymentMethod.value = paymentMethod;
//       currentOrderId.value = orderId;

//       log('Initiating $paymentMethod payment for order: $orderId, amount: $amount');

//       switch (paymentMethod) {
//         case PAYSTACK:
//           return await _initiatePaystackPayment(amount, currency, orderId, metadata);
//         case FLUTTERWAVE:
//           return await _initiateFlutterwavePayment(amount, currency, orderId, metadata);
//         case STRIPE:
//           return await _initiateStripePayment(amount, currency, orderId, metadata);
//         default:
//           _errorMessage = 'Unsupported payment method';
//           return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Error initiating payment: $e';
//       log('Error initiating payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> _initiatePaystackPayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId, 
//       };

//       log('Paystack payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-paystack-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Paystack payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Paystack response: $responseData');

//       final authorizationUrl = responseData['data']?['authorization_url'];
//       final reference = responseData['data']?['reference'];

//       if (authorizationUrl == null || authorizationUrl.isEmpty) {
//         _errorMessage = 'Paystack authorization URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Paystack reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       paymentReference.value = reference;
      
//       // Use WebView for better control
//       _openPaymentWebView(authorizationUrl, reference, PAYSTACK);
//       return true;
//     } catch (e) {
//       _errorMessage = 'Paystack payment error: $e';
//       log('Paystack payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateFlutterwavePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId,
//       };

//       log('Flutterwave payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-flutterwave-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Flutterwave payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Flutterwave response: $responseData');

//       final paymentLink = responseData['data']?['link'];
//       final reference = responseData['data']?['reference'];

//       if (paymentLink == null || paymentLink.isEmpty) {
//         _errorMessage = 'Flutterwave payment link is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (reference == null || reference.isEmpty) {
//         _errorMessage = 'Flutterwave reference is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       paymentReference.value = reference;
      
//       _openPaymentWebView(paymentLink, reference, FLUTTERWAVE);
//       return true;
//     } catch (e) {
//       _errorMessage = 'Flutterwave payment error: $e';
//       log('Flutterwave payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   Future<bool> _initiateStripePayment(
//     double amount,
//     String currency,
//     int orderId,
//     Map<String, dynamic>? metadata,
//   ) async {
//     try {
//       final payload = {
//         'order_id': orderId,
//       };

//       log('Stripe payload: $payload');

//       final response = await MyRequest(
//         'payments/initiate-stripe-payment/',
//         payload,
//         true,
//         201,
//       ).postApi();

//       if (response == null) {
//         final errorResponse = MyRequest('', {}).returnResponse();
//         _errorMessage = errorResponse != null
//             ? extractErrorMessage(errorResponse.body)
//             : 'Failed to initiate Stripe payment';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       final responseData = jsonDecode(response);
//       log('Stripe response: $responseData');

//       final checkoutUrl = responseData['data']?['link'];
//       final sessionId = responseData['data']?['reference'];

//       if (checkoutUrl == null || checkoutUrl.isEmpty) {
//         _errorMessage = 'Stripe checkout URL is missing or invalid';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       if (sessionId == null || sessionId.isEmpty) {
//         _errorMessage = 'Stripe session ID is missing';
//         showFailureSnackbar(_errorMessage!);
//         return false;
//       }

//       paymentReference.value = sessionId;
      
//       _openPaymentWebView(checkoutUrl, sessionId, STRIPE);
//       return true;
//     } catch (e) {
//       _errorMessage = 'Stripe payment error: $e';
//       log('Stripe payment error: $e');
//       showFailureSnackbar(_errorMessage!);
//       return false;
//     }
//   }

//   // Enhanced WebView-based payment launcher
//   void _openPaymentWebView(String url, String reference, String paymentMethod) {
//     if (url.isEmpty) {
//       _errorMessage = 'Payment URL is empty';
//       showFailureSnackbar(_errorMessage!);
//       return;
//     }

//     final cleanUrl = url.trim();
//     log('Opening payment WebView for URL: $cleanUrl');

//     Get.to(
//       () => PaymentWebViewScreen(
//         url: cleanUrl,
//         reference: reference,
//         paymentMethod: paymentMethod,
//         orderId: currentOrderId.value,
//         onPaymentComplete: (bool success, String? message, {int? orderId}) async {
//           if (success) {
//             // Payment completed successfully - navigate directly to success page
//             await _handlePaymentSuccess(orderId);
//           } else {
//             // Payment failed or cancelled
//             Get.back(); // Close WebView
//             _errorMessage = message ?? 'Payment was cancelled or failed';
//             showFailureSnackbar(_errorMessage!);
//           }
//         },
//       ),
//       fullscreenDialog: true,
//     );
//   }

//   // Handle successful payment
//   Future<void> _handlePaymentSuccess(int? orderId) async {
//     try {
//       // Close WebView
//       Get.back();
      
//       // Clear cart
//       final cartController = Get.find<CartController>();
//       await cartController.clearCart();
      
//       // Navigate to success screen with order details
//       Get.offAll(
//         () => PaymentSuccessScreen(
//           orderId: orderId ?? currentOrderId.value,
//           amount: cartController.totalPrice + 7.50, // Include shipping + tax
//           paymentMethod: selectedPaymentMethod.value,
//           reference: paymentReference.value,
//         ),
//         transition: Transition.rightToLeftWithFade,
//         duration: const Duration(milliseconds: 500),
//       );
      
//       // Show success message
//       Get.snackbar(
//         "Payment Successful",
//         "Your order has been placed successfully!",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       log('Error handling payment success: $e');
//     }
//   }

//   /// Verify payment with backend
//   Future<bool> verifyPayment(String reference, String paymentMethod) async {
//     try {
//       String endpoint;
      
//       switch (paymentMethod) {
//         case PAYSTACK:
//           endpoint = 'payments/verify-paystack-payment/$reference/';
//           break;
//         case FLUTTERWAVE:
//           endpoint = 'payments/verify-flutterwave-payment/$reference/';
//           break;
//         case STRIPE:
//           endpoint = 'payments/verify-stripe-payment/$reference'; 
//           break;
//         default:
//           throw 'Unknown payment method: $paymentMethod';
//       }

//       log('Verifying payment with endpoint: $endpoint');

//       final response = await MyRequest(
//         endpoint,
//         {},
//         true, // auth required
//         200, // success code
//       ).getApi();

//       if (response != null) {
//         final responseData = jsonDecode(response);
//         log('Payment verification response: $responseData');
        
//         final paymentStatus = responseData['payment_status'];
//         final isVerified = paymentStatus == 'Paid';
        
//         log('Payment status: $paymentStatus, Verified: $isVerified');
//         return isVerified;
//       }

//       log('Payment verification response is null');
//       return false;
//     } catch (e) {
//       log('Error verifying payment: $e');
//       return false;
//     }
//   }

//   /// Manual payment verification (for when user returns to app)
//   Future<bool> verifyPaymentManually(String reference) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       if (reference.isEmpty) {
//         _errorMessage = 'Payment reference is required';
//         return false;
//       }

//       if (selectedPaymentMethod.value.isEmpty) {
//         _errorMessage = 'Payment method not found';
//         return false;
//       }

//       final verified = await verifyPayment(reference, selectedPaymentMethod.value);
      
//       if (!verified) {
//         _errorMessage = 'Payment verification failed';
//       }
      
//       return verified;
//     } catch (e) {
//       _errorMessage = 'Error verifying payment: $e';
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Get total cart amount
//   double getTotalAmount() {
//     final cartController = Get.find<CartController>();
//     return cartController.totalPrice;
//   }

//   /// Create order and initiate payment
//   Future<bool> processPayment(String paymentMethod) async {
//     try {
//       isLoading.value = true;
//       _errorMessage = null;

//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt("user_id");
//       if (userId == null) {
//         _errorMessage = 'User ID not found. Please log in again.';
//         return false;
//       }

//       // Get cart and address data
//       final cartController = Get.find<CartController>();
//       final addressController = Get.find<AddressController>();

//       if (cartController.cartItems.isEmpty) {
//         _errorMessage = 'Cart is empty';
//         return false;
//       }

//       if (addressController.selectedAddress.value == null) {
//         _errorMessage = 'No shipping address selected';
//         return false;
//       }

//       // Create order first
//       final orderData = {
//         'order_products': cartController.cartItems.map((item) => {
//               'id': item.product?.id,
//               'quantity': item.quantity,
//               'sizes': item.size,
//               'colors': item.color,
//             }).toList(),
//         'address': addressController.selectedAddress.value!.id,
//         'customer_id': userId,
//         'total_quantity': cartController.totalQuantity,
//         'subtotal': cartController.totalPrice,
//         'total': cartController.totalPrice + 7.50, // Add shipping + tax
//         'delivery_status': 'Pending',
//         'payment_status': 'Unpaid',
//       };

//       log('Order payload: $orderData');
//       final orderResponse = await MyRequest(
//         'orders/add/', 
//         orderData,
//         true,
//         201,
//       ).postApi();

//       if (orderResponse == null) {
//         _errorMessage = 'Failed to create order';
//         return false;
//       }

//       final orderResponseData = jsonDecode(orderResponse);
//       final orderId = orderResponseData['id'];
      
//       if (orderId == null) {
//         _errorMessage = 'Order ID not received from server';
//         return false;
//       }

//       log('Order created successfully with ID: $orderId');
      
//       // Initiate payment with the created order ID
//       final amount = cartController.totalPrice + 7.50; // Total including shipping + tax
//       final metadata = {
//         'order_data': orderData,
//         'user_id': userId,
//       };

//       return await initiatePayment(
//         paymentMethod: paymentMethod,
//         amount: amount,
//         metadata: metadata,
//         orderId: orderId,
//         currency: paymentMethod == STRIPE ? 'usd' : 'NGN',
//       );

//     } catch (e) {
//       _errorMessage = 'Error processing payment: $e';
//       log('Error processing payment: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Clear payment data
//   void clearPaymentData() {
//     selectedPaymentMethod.value = '';
//     currentOrderId.value = 0;
//     paymentReference.value = '';
//     _errorMessage = null;
//     isLoading.value = false;
//   }

//   @override
//   void onClose() {
//     clearPaymentData();
//     super.onClose();
//   }
// }