// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import '../../base/res/styles/app_styles.dart';
// import '../../base/utils/snackbar.dart';
// import '../controllers/payment_controller.dart';
// import 'payment_methods_screen.dart';

// class PaymentWebViewScreen extends StatefulWidget {
//   final String url;
//   final String reference;
//   final String paymentMethod;
//   final int orderId;
//   final Function(bool success, String? message, {int? orderId}) onPaymentComplete;

//   const PaymentWebViewScreen({
//     Key? key,
//     required this.url,
//     required this.reference,
//     required this.paymentMethod,
//     required this.orderId,
//     required this.onPaymentComplete,
//   }) : super(key: key);

//   @override
//   State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
// }

// class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   String? _errorMessage;
//   Timer? _pollTimer;
//   Timer? _timeoutTimer;
//   bool _paymentCompleted = false;
//   bool _isVerifying = false;
//   int _verificationAttempts = 0;
//   static const int _maxVerificationAttempts = 15;
//   bool _webViewInitialized = false;

//   // Enhanced success/failure URL patterns
//   final Map<String, Map<String, List<String>>> _urlPatterns = {
//     'PayStack': {
//       'success': [
//         'callback',
//         'success',
//         'verify',
//         'payment-success',
//         'completed',
//         'trxref=',
//         'reference=',
//         'paystack.co/pay/success',
//         'status=success',
//         'payment_status=success',
//       ],
//       'failure': [
//         'cancel',
//         'failed',
//         'error',
//         'payment-cancelled',
//         'cancelled',
//         'paystack.co/pay/cancel',
//         'status=cancelled',
//         'payment_status=failed',
//       ],
//     },
//     'Flutterwave': {
//       'success': [
//         'callback',
//         'success',
//         'verify',
//         'payment-success',
//         'completed',
//         'tx_ref=',
//         'transaction_id=',
//         'status=successful',
//         'flutterwave.com/pay/success',
//         'payment_status=successful',
//       ],
//       'failure': [
//         'cancel',
//         'failed',
//         'error',
//         'payment-cancelled',
//         'cancelled',
//         'status=cancelled',
//         'flutterwave.com/pay/cancel',
//         'payment_status=failed',
//       ],
//     },
//     'Stripe': {
//       'success': [
//         'success',
//         'payment/success',
//         'checkout/success',
//         'verify-stripe-payment',
//         'session_id=cs_',
//         'payment_status=paid',
//         'stripe.com/pay/success',
//         'payment_intent_status=succeeded',
//       ],
//       'failure': [
//         'cancel',
//         'payment/cancel',
//         'checkout/cancel',
//         'payment_status=unpaid',
//         'cancelled',
//         'stripe.com/pay/cancel',
//         'payment_intent_status=canceled',
//       ],
//     },
//   };

//   @override
//   void initState() {
//     super.initState();
//     log('=== PaymentWebViewScreen INIT ===');
//     log('URL: ${widget.url}');
//     log('Reference: ${widget.reference}');
//     log('Payment Method: ${widget.paymentMethod}');
//     log('Order ID: ${widget.orderId}');
    
//     _validateUrl();
//     _initializeWebView();
//     _startPaymentPolling();
//     _startTimeoutTimer();
//   }

//   // void _validateUrl() {
//   //   if (widget.url.isEmpty) {
//   //     setState(() {
//   //       _errorMessage = 'Payment URL is empty';
//   //       _isLoading = false;
//   //     });
//   //     return;
//   //   }

//   //   try {
//   //     final uri = Uri.parse(widget.url);
//   //     if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
//   //       setState(() {
//   //         _errorMessage = 'Invalid payment URL format';
//   //         _isLoading = false;
//   //       });
//   //       return;
//   //     }
//   //     log('URL validation passed: ${widget.url}');
//   //   } catch (e) {
//   //     log('URL validation failed: $e');
//   //     setState(() {
//   //       _errorMessage = 'Invalid payment URL: $e';
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//   void _validateUrl() {
//   if (widget.url.isEmpty) {
//     setState(() {
//       _errorMessage = 'Payment URL is empty';
//       _isLoading = false;
//     });
//     return;
//   }

//   try {
//     final uri = Uri.parse(widget.url);
//     if (!uri.hasScheme || !uri.scheme.startsWith('https')) {
//       log('Invalid URL scheme: ${uri.scheme}');
//       setState(() {
//         _errorMessage = 'Payment URL must use HTTPS';
//         _isLoading = false;
//       });
//       return;
//     }
//     log('URL validation passed: ${widget.url}');
//   } catch (e) {
//     log('URL validation failed: $e');
//     setState(() {
//       _errorMessage = 'Invalid payment URL: $e';
//       _isLoading = false;
//     });
//   }
// }

//   @override
//   void dispose() {
//     log('=== PaymentWebViewScreen DISPOSE ===');
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
//     super.dispose();
//   }

//   void _initializeWebView() {
//     if (_errorMessage != null) return;

//     log('Initializing WebView...');
    
//     try {
//       _controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setUserAgent(
//           'Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36'
//         )
//         ..setBackgroundColor(Colors.white)
//         ..clearCache()
//         ..enableZoom(false)
//         ..clearLocalStorage()
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onPageStarted: (String url) {
//               log('🔄 Page STARTED loading: $url');
//               if (!_paymentCompleted) {
//                 _checkUrlForPaymentStatus(url);
//               }
//             },
//             onPageFinished: (String url) {
//               log('✅ Page FINISHED loading: $url');
//               setState(() {
//                 _isLoading = false;
//                 _webViewInitialized = true;
//               });
//               if (!_paymentCompleted) {
//                 _checkUrlForPaymentStatus(url);
//               }
//             },
//             onWebResourceError: (WebResourceError error) {
//               log('❌ WebView error: ${error.description} (Code: ${error.errorCode})');
//               setState(() {
//                 _isLoading = false;
//                 _errorMessage = 'Failed to load payment page: ${error.description}';
//               });
//             },
//             onNavigationRequest: (NavigationRequest request) {
//               log('🚀 Navigation request: ${request.url}');
//               if (!_paymentCompleted) {
//                 _checkUrlForPaymentStatus(request.url);
//               }
//               return NavigationDecision.navigate;
//             },
//             onHttpError: (HttpResponseError error) {
//               log('🔥 HTTP error: ${error.response?.statusCode}');
//             },
//             onUrlChange: (UrlChange change) {
//               log('🔄 URL changed: ${change.url}');
//               if (change.url != null && !_paymentCompleted) {
//                 _checkUrlForPaymentStatus(change.url!);
//               }
//             },
//           ),
//         );

//       // Load the payment URL
//       _loadPaymentUrl();
      
//     } catch (e) {
//       log('Error initializing WebView: $e');
//       setState(() {
//         _errorMessage = 'Failed to initialize payment page: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _loadPaymentUrl() {
//     try {
//       log('🌐 Loading payment URL: ${widget.url}');
//       _controller.loadRequest(Uri.parse(widget.url));
      
//       // Add a timeout for URL loading
//       Timer(const Duration(seconds: 30), () {
//         if (_isLoading && !_webViewInitialized && mounted) {
//           log('⏰ URL loading timeout');
//           setState(() {
//             _errorMessage = 'Payment page took too long to load. Please check your internet connection.';
//             _isLoading = false;
//           });
//         }
//       });
      
//     } catch (e) {
//       log('Error loading URL: $e');
//       setState(() {
//         _errorMessage = 'Invalid payment URL: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _checkUrlForPaymentStatus(String url) {
//     if (_paymentCompleted || _isVerifying) return;

//     final lowercaseUrl = url.toLowerCase();
//     final patterns = _urlPatterns[widget.paymentMethod];
    
//     if (patterns == null) {
//       log('⚠️ No URL patterns found for payment method: ${widget.paymentMethod}');
//       return;
//     }

//     log('🔍 Checking URL for payment status: $lowercaseUrl');

//     // Check for success patterns
//     final successPatterns = patterns['success'] ?? [];
//     for (String pattern in successPatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('🎉 Success pattern detected: $pattern in $url');
//         _handlePaymentSuccess();
//         return;
//       }
//     }

//     // Check for failure patterns
//     final failurePatterns = patterns['failure'] ?? [];
//     for (String pattern in failurePatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('💥 Failure pattern detected: $pattern in $url');
//         _handlePaymentFailure('Payment was cancelled or failed');
//         return;
//       }
//     }

//     // Special handling for redirect URLs
//     _handleSpecialRedirects(url);
//   }

//   void _handleSpecialRedirects(String url) {
//     final lowercaseUrl = url.toLowerCase();
    
//     if (lowercaseUrl.contains('localhost') || 
//         lowercaseUrl.contains('127.0.0.1') || 
//         lowercaseUrl.contains('callback') || 
//         lowercaseUrl.contains('redirect')) {
      
//       if (lowercaseUrl.contains('success') || 
//           lowercaseUrl.contains('verify') || 
//           lowercaseUrl.contains('complete') || 
//           lowercaseUrl.contains('paid')) {
//         log('🚀 Special success redirect detected: $url');
//         _handlePaymentSuccess();
//       } else if (lowercaseUrl.contains('cancel') || 
//                  lowercaseUrl.contains('failed') || 
//                  lowercaseUrl.contains('error')) {
//         log('🛑 Special failure redirect detected: $url');
//         _handlePaymentFailure('Payment was cancelled');
//       }
//     }
//   }

//   void _startPaymentPolling() {
//     log('🔄 Starting payment polling...');
//     _pollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//       if (!_paymentCompleted && !_isVerifying && _verificationAttempts < _maxVerificationAttempts) {
//         _verifyPaymentStatus();
//       } else if (_verificationAttempts >= _maxVerificationAttempts) {
//         timer.cancel();
//         if (!_paymentCompleted) {
//           log('⏰ Maximum verification attempts reached');
//         }
//       }
//     });
//   }

//   void _startTimeoutTimer() {
//     _timeoutTimer = Timer(const Duration(minutes: 15), () {
//       if (!_paymentCompleted && mounted) {
//         log('⏰ Payment session timed out');
//         _handlePaymentFailure('Payment session timed out. Please try again.');
//       }
//     });
//   }

//   // Fixed verification method that uses the correct controllers
//   Future<void> _verifyPaymentStatus() async {
//     if (_isVerifying || _paymentCompleted) return;
    
//     _verificationAttempts++;
    
//     setState(() {
//       _isVerifying = true;
//     });

//     try {
//       log('🔍 Polling payment verification for reference: ${widget.reference} (Attempt: $_verificationAttempts)');
      
//       bool verified = false;
      
//       // Use the appropriate controller based on payment method
//       switch (widget.paymentMethod) {
//         case 'PayStack':
//           final controller = Get.find<PaystackPaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//         case 'Flutterwave':
//           final controller = Get.find<FlutterwavePaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//         case 'Stripe':
//           final controller = Get.find<StripePaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//       }
      
//       log('✅ Payment verification result: $verified');
      
//       if (verified && !_paymentCompleted) {
//         log('🎉 Payment verified through polling - Success!');
//         _handlePaymentSuccess();
//       } else if (_verificationAttempts >= _maxVerificationAttempts && !_paymentCompleted) {
//         log('💥 Payment verification failed after maximum attempts');
//         // Don't auto-fail here, let user manually verify or close
//       }
//     } catch (e) {
//       log('❌ Error during payment polling: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isVerifying = false;
//         });
//       }
//     }
//   }

//   void _handlePaymentSuccess() {
//     if (_paymentCompleted) return;
    
//     log('=== 🎉 PAYMENT SUCCESS HANDLER CALLED ===');
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
    
//     _showSuccessOverlay();
    
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         log('📞 Calling onPaymentComplete callback with success');
//         widget.onPaymentComplete(
//           true, 
//           'Payment completed successfully',
//           orderId: widget.orderId,
//         );
//       }
//     });
//   }

//   void _handlePaymentFailure(String message) {
//     if (_paymentCompleted) return;
    
//     log('=== 💥 PAYMENT FAILURE HANDLER CALLED ===');
//     log('Payment failed: $message');
    
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
    
//     if (mounted) {
//       widget.onPaymentComplete(false, message, orderId: widget.orderId);
//     }
//   }

//   void _showSuccessOverlay() {
//     if (!mounted) return;
    
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 48,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Payment Successful!',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Redirecting to order confirmation...',
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleManualClose() {
//     if (_paymentCompleted) return;
    
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Close Payment'),
//         content: const Text(
//           'Are you sure you want to close the payment page? Your payment may not be completed.'
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//             },
//             child: const Text('Continue Payment'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.to(() => const PaymentMethodsScreen(), transition: Transition.rightToLeftWithFade,
//                     duration: const Duration(milliseconds: 500),);
              
//               _handlePaymentFailure('Payment cancelled by user');
//             },
//             child: Text(
//               'Close Payment',
//               style: TextStyle(color: Colors.red.shade600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleRefresh() {
//     log('🔄 Refreshing WebView...');
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _webViewInitialized = false;
//     });
    
//     try {
//       _controller.reload();
//     } catch (e) {
//       log('Error refreshing WebView: $e');
//       _loadPaymentUrl();
//     }
//   }

//   Future<void> _handleManualVerification() async {
//     if (_paymentCompleted || _isVerifying) return;

//     log('🔍 Manual verification triggered...');
//     setState(() {
//       _isVerifying = true;
//     });

//     try {
//       bool verified = false;
      
//       // Use the appropriate controller based on payment method
//       switch (widget.paymentMethod) {
//         case 'PayStack':
//           final controller = Get.find<PaystackPaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//         case 'Flutterwave':
//           final controller = Get.find<FlutterwavePaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//         case 'Stripe':
//           final controller = Get.find<StripePaymentController>();
//           verified = await controller.verifyPayment(widget.reference);
//           break;
//       }
      
//       if (verified) {
//         _handlePaymentSuccess();
//       } else {
//         showFailureSnackbar('Verification Failed');
       
//       }
//     } catch (e) {
//       log('Manual verification error: $e');
//       showFailureSnackbar('Verification Error');
     
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isVerifying = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _handleManualClose();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('${widget.paymentMethod} Payment'),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 1,
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: _handleManualClose,
//           ),
//           actions: [
//             if (_isLoading || _isVerifying)
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _handleRefresh,
//             ),
//             IconButton(
//               icon: const Icon(Icons.verified_user),
//               onPressed: _isVerifying ? null : _handleManualVerification,
//               tooltip: 'Verify Payment',
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             // Progress indicator
//             if (_isLoading)
//               const LinearProgressIndicator(),
            
//             // Verification status
//             if (_isVerifying)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 color: Colors.blue.shade50,
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Verifying payment... (Attempt $_verificationAttempts)',
//                         style: TextStyle(
//                           color: Colors.blue.shade700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
            
//             // Error message
//             if (_errorMessage != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 color: Colors.red.shade50,
//                 child: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red.shade700),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _errorMessage!,
//                         style: TextStyle(color: Colors.red.shade700),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: _handleRefresh,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
            
//             // WebView or Error Display
//             Expanded(
//               child: _errorMessage != null 
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Failed to load payment page', 
//                           style: TextStyle(
//                             color: Colors.red.shade600,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 32),
//                           child: Text(
//                             _errorMessage!,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.red.shade500,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _handleRefresh,
//                           child: const Text('Retry'),
//                         ),
//                         const SizedBox(height: 8),
//                         TextButton(
//                           onPressed: _handleManualVerification,
//                           child: const Text('Verify Payment Manually'),
//                         ),
//                       ],
//                     ),
//                   )
//                 : _webViewInitialized || !_isLoading
//                   ? WebViewWidget(controller: _controller)
//                   :  
                  
//                   Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(color: AppStyles.primaryColor,),
//                           SizedBox(height: 16),
//                           Text('Loading payment page...'),
//                           SizedBox(height: 8),
//                           Text(
//                             'This may take a few seconds...',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
            
//             // Bottom info bar
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border(top: BorderSide(color: Colors.grey.shade300)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.security, size: 16, color: Colors.green.shade600),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Secure ${widget.paymentMethod} payment processing',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     'Order #${widget.orderId}',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey.shade500,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../base/utils/snackbar.dart';
import '../controllers/payment_controller.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String reference;
  final String paymentMethod;
  final int orderId;
  static const verified = 'verified';

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.reference,
    required this.paymentMethod,
    required this.orderId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  bool _paymentCompleted = false;
  bool _closeDialogOpen = false;
  String? _pendingResult;
  bool _isVerifying = false;
  int _verificationAttempts = 0;
  static const int _maxVerificationAttempts = 15;
  bool _webViewInitialized = false;

  // Enhanced success/failure URL patterns
  final Map<String, Map<String, List<String>>> _urlPatterns = {
    'PayStack': {
      'success': [
        'callback',
        'success',
        'verify',
        'payment-success',
        'completed',
        'trxref=',
        'reference=',
        'paystack.co/pay/success',
        'paystack.co/success',
        'status=success',
        'payment_status=success',
      ],
      'failure': [
        'cancel',
        'failed',
        'error',
        'payment-cancelled',
        'cancelled',
        'paystack.co/pay/cancel',
        'status=cancelled',
        'payment_status=failed',
      ],
    },
    'Flutterwave': {
      'success': [
        'callback',
        'success',
        'verify',
        'payment-success',
        'completed',
        'tx_ref=',
        'transaction_id=',
        'status=successful',
        'flutterwave.com/pay/success',
        'flw.live/success',
        'payment_status=successful',
      ],
      'failure': [
        'cancel',
        'failed',
        'error',
        'payment-cancelled',
        'cancelled',
        'status=cancelled',
        'flutterwave.com/pay/cancel',
        'flw.live/cancel',
        'payment_status=failed',
      ],
    },
    'Stripe': {
      'success': [
        'success',
        'payment/success',
        'checkout/success',
        'verify-stripe-payment',
        'session_id=cs_',
        'payment_status=paid',
        'stripe.com/pay/success',
        'payment_intent_status=succeeded',
      ],
      'failure': [
        'cancel',
        'payment/cancel',
        'checkout/cancel',
        'payment_status=unpaid',
        'cancelled',
        'stripe.com/pay/cancel',
        'payment_intent_status=canceled',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    log('=== PaymentWebViewScreen INIT ===');
    log('URL: ${widget.url}');
    log('Reference: ${widget.reference}');
    log('Payment Method: ${widget.paymentMethod}');
    log('Order ID: ${widget.orderId}');

    _validateUrl();
    _startPaymentPolling();
    _startTimeoutTimer();
  }

  void _validateUrl() {
    if (widget.url.isEmpty) {
      setState(() {
        _errorMessage = 'Payment URL is empty';
        _isLoading = false;
      });
      return;
    }

    try {
      final uri = Uri.parse(widget.url);
      if (!uri.hasScheme || uri.scheme != 'https') {
        log('Invalid URL scheme: ${uri.scheme}');
        setState(() {
          _errorMessage = 'Payment URL must use HTTPS';
          _isLoading = false;
        });
        return;
      }
      log('URL validation passed: ${widget.url}');
    } catch (e) {
      log('URL validation failed: $e');
      setState(() {
        _errorMessage = 'Invalid payment URL: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    log('=== PaymentWebViewScreen DISPOSE ===');
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    if (_errorMessage != null) return;

    log('Initializing InAppWebView...');
    try {
      WebStorageManager.instance().deleteAllData();
    } catch (e) {
      log('Error clearing WebView data: $e');
      setState(() {
        _errorMessage = 'Failed to initialize payment page: $e';
        _isLoading = false;
      });
    }
  }

  void _loadPaymentUrl() {
    try {
      log('🌐 Loading payment URL: ${widget.url}');
      _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));
      Timer(const Duration(seconds: 60), () {
        if (_isLoading && !_webViewInitialized && mounted) {
          log('⏰ URL loading timeout');
          setState(() {
            _errorMessage =
                'Payment page took too long to load. Please try again.';
            _isLoading = false;
          });
          _loadPaymentUrl(); // Retry loading
        }
      });
    } catch (e) {
      log('Error loading URL: $e');
      setState(() {
        _errorMessage = 'Invalid payment URL: $e';
        _isLoading = false;
      });
    }
  }

  void _checkUrlForPaymentStatus(String url) {
    if (_paymentCompleted || _isVerifying) return;

    final lowercaseUrl = url.toLowerCase();
    final patterns = _urlPatterns[widget.paymentMethod];

    if (patterns == null) {
      log('⚠️ No URL patterns found for payment method: ${widget.paymentMethod}');
      return;
    }

    log('🔍 Checking URL for payment status: $lowercaseUrl');

    final successPatterns = patterns['success'] ?? [];
    for (String pattern in successPatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('🎉 Success pattern detected: $pattern in $url');
        _verifyPaymentStatus();
        return;
      }
    }

    final failurePatterns = patterns['failure'] ?? [];
    for (String pattern in failurePatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('💥 Failure pattern detected: $pattern in $url');
        _handlePaymentFailure('Payment was cancelled or failed');
        return;
      }
    }

    _handleSpecialRedirects(url);
  }

  void _handleSpecialRedirects(String url) {
    final lowercaseUrl = url.toLowerCase();
    if (lowercaseUrl.contains('localhost') ||
        lowercaseUrl.contains('127.0.0.1') ||
        lowercaseUrl.contains('callback') ||
        lowercaseUrl.contains('redirect')) {
      if (lowercaseUrl.contains('success') ||
          lowercaseUrl.contains('verify') ||
          lowercaseUrl.contains('complete') ||
          lowercaseUrl.contains('paid')) {
        log('🚀 Special success redirect detected: $url');
        _verifyPaymentStatus();
      } else if (lowercaseUrl.contains('cancel') ||
          lowercaseUrl.contains('failed') ||
          lowercaseUrl.contains('error')) {
        log('🛑 Special failure redirect detected: $url');
        _handlePaymentFailure('Payment was cancelled');
      }
    }
  }

  void _startPaymentPolling() {
    log('🔄 Starting payment polling...');
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_paymentCompleted &&
          !_isVerifying &&
          _verificationAttempts < _maxVerificationAttempts) {
        _verifyPaymentStatus();
      } else if (_verificationAttempts >= _maxVerificationAttempts) {
        timer.cancel();
        if (!_paymentCompleted) {
          log('⏰ Maximum verification attempts reached');
        }
      }
    });
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(minutes: 15), () {
      if (!_paymentCompleted && mounted) {
        log('⏰ Payment session timed out');
        _handlePaymentFailure('Payment session timed out. Please try again.');
      }
    });
  }

  Future<void> _verifyPaymentStatus() async {
    if (_isVerifying || _paymentCompleted) return;

    _verificationAttempts++;
    setState(() {
      _isVerifying = true;
    });

    try {
      log('🔍 Polling payment verification for reference: ${widget.reference} (Attempt: $_verificationAttempts)');
      bool verified = false;

      switch (widget.paymentMethod) {
        case 'PayStack':
          final controller = Get.find<PaystackPaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
        case 'Flutterwave':
          final controller = Get.find<FlutterwavePaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
        case 'Stripe':
          final controller = Get.find<StripePaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
      }

      log('✅ Payment verification result: $verified');
      if (verified && !_paymentCompleted) {
        log('🎉 Payment verified through polling - Success!');
        _handlePaymentSuccess();
      }
    } catch (e) {
      log('❌ Error during payment polling: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _handlePaymentSuccess() => _finishPayment(PaymentWebViewScreen.verified);

  void _handlePaymentFailure(String message) => _finishPayment(message);

  void _finishPayment(String result) {
    if (_paymentCompleted || !mounted) return;
    if (_closeDialogOpen) {
      if (_pendingResult != PaymentWebViewScreen.verified) {
        _pendingResult = result;
      }
      return;
    }
    _paymentCompleted = true;
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    Navigator.of(context).pop(result);
  }

  void _handleManualClose() {
    if (_paymentCompleted || _closeDialogOpen) return;
    _closeDialogOpen = true;
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close payment?'),
        content: const Text(
          'You can return to this order from My Orders to check or resume payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continue payment'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Close payment'),
          ),
        ],
      ),
    ).then((close) {
      _closeDialogOpen = false;
      final result = _pendingResult;
      _pendingResult = null;
      if (result != null) {
        _finishPayment(result);
      } else if (close == true) {
        _handlePaymentFailure('Payment has not been confirmed.');
      }
    });
  }

  void _handleRefresh() {
    log('🔄 Refreshing WebView...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _webViewInitialized = false;
    });

    try {
      _controller?.reload();
      Timer(const Duration(seconds: 5), () {
        if (_isLoading && !_webViewInitialized && mounted) {
          _loadPaymentUrl();
        }
      });
    } catch (e) {
      log('Error refreshing WebView: $e');
      _loadPaymentUrl();
    }
  }

  Future<void> _handleManualVerification() async {
    if (_paymentCompleted || _isVerifying) return;

    log('🔍 Manual verification triggered...');
    setState(() {
      _isVerifying = true;
    });

    try {
      bool verified = false;

      switch (widget.paymentMethod) {
        case 'PayStack':
          final controller = Get.find<PaystackPaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
        case 'Flutterwave':
          final controller = Get.find<FlutterwavePaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
        case 'Stripe':
          final controller = Get.find<StripePaymentController>();
          verified = await controller.verifyPayment(widget.reference);
          break;
      }

      if (verified) {
        _handlePaymentSuccess();
      } else {
        showFailureSnackbar('Verification Failed');
      }
    } catch (e) {
      log('Manual verification error: $e');
      showFailureSnackbar('Verification Error');
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleManualClose();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.paymentMethod} Payment'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleManualClose,
          ),
          actions: [
            if (_isLoading || _isVerifying)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleRefresh,
            ),
            IconButton(
              icon: const Icon(Icons.verified_user),
              onPressed: _isVerifying ? null : _handleManualVerification,
              tooltip: 'Verify Payment',
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(),
            if (_isVerifying)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verifying payment...',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load payment page',
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
                            onPressed: _handleRefresh,
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _handleManualVerification,
                            child: const Text('Verify Payment Manually'),
                          ),
                        ],
                      ),
                    )
                  : InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptEnabled: true,
                          userAgent:
                              'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Mobile Safari/537.36',
                          cacheEnabled: false,
                          supportZoom: false,
                          transparentBackground: false,
                          // mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                          mediaPlaybackRequiresUserGesture: false,
                          javaScriptCanOpenWindowsAutomatically: true,
                          useShouldOverrideUrlLoading: true,
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          hardwareAcceleration: true,
                          supportMultipleWindows: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: false,
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        _controller = controller;
                        _initializeWebView();
                        _loadPaymentUrl();
                      },
                      onLoadStart: (controller, url) {
                        log('🔄 Page STARTED loading: $url');
                        if (!_paymentCompleted && url != null) {
                          _checkUrlForPaymentStatus(url.toString());
                        }
                      },
                      onLoadStop: (controller, url) {
                        log('✅ Page FINISHED loading: $url');
                        setState(() {
                          _isLoading = false;
                          _webViewInitialized = true;
                        });
                        if (!_paymentCompleted && url != null) {
                          _checkUrlForPaymentStatus(url.toString());
                        }
                      },
                      onLoadError: (controller, url, code, message) {
                        log('❌ WebView error: $message (Code: $code)');
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Failed to load payment page: $message';
                        });
                      },
                      onReceivedHttpError: (controller, request, errorResponse) {
                        log('🔥 HTTP error: ${errorResponse.statusCode}');
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        log('🔄 URL changed: $url');
                        if (url != null && !_paymentCompleted) {
                          _checkUrlForPaymentStatus(url.toString());
                        }
                      },
                      onCreateWindow: (controller, createWindowRequest) async {
                        log('Pop-up window requested: ${createWindowRequest.request.url}');
                        if (createWindowRequest.request.url != null) {
                          _checkUrlForPaymentStatus(createWindowRequest.request.url!.toString());
                          await controller.loadUrl(urlRequest: URLRequest(url: createWindowRequest.request.url));
                          return true;
                        }
                        return false;
                      },
                      onReceivedServerTrustAuthRequest: (controller, challenge) async {
                        log('SSL certificate issue: ${challenge.protectionSpace.host}');
                        return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        log('WebView console: ${consoleMessage.message} (Level: ${consoleMessage.messageLevel})');
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Secure ${widget.paymentMethod} payment processing',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Text(
                    'Order #${widget.orderId}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}