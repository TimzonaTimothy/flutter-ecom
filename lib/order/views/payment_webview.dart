import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/controller.dart';
import '../controllers/payment_controller.dart';
import 'payment_methods_screen.dart';

// class PaymentWebViewScreen extends StatefulWidget {
//   final String url;
//   final String reference;
//   final String paymentMethod;
//   final Function(bool success, String? message) onPaymentComplete;

//   const PaymentWebViewScreen({
//     Key? key,
//     required this.url,
//     required this.reference,
//     required this.paymentMethod,
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
//   bool _paymentCompleted = false;

//   // Success/failure URL patterns for different payment methods
//   final Map<String, List<String>> _successPatterns = {
//     'PayStack': [
//       'callback',
//       'success',
//       'verify',
//       'payment-success',
//       'completed',
//     ],
//     'Flutterwave': [
//       'callback',
//       'success',
//       'verify',
//       'payment-success',
//       'completed',
//       'flutterwave.com/pay/success',
//     ],
//     'Stripe': [
//       'success',
//       'payment/success',
//       'checkout/success',
//       'verify-stripe-payment',
//     ],
//   };

//   final Map<String, List<String>> _failurePatterns = {
//     'PayStack': [
//       'cancel',
//       'failed',
//       'error',
//       'payment-cancelled',
//     ],
//     'Flutterwave': [
//       'cancel',
//       'failed',
//       'error',
//       'payment-cancelled',
//       'flutterwave.com/pay/cancel',
//     ],
//     'Stripe': [
//       'cancel',
//       'payment/cancel',
//       'checkout/cancel',
//     ],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//     _startPaymentPolling();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     super.dispose();
//   }

//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             log('Page started loading: $url');
//             _checkUrlForPaymentStatus(url);
//           },
//           onPageFinished: (String url) {
//             log('Page finished loading: $url');
//             setState(() {
//               _isLoading = false;
//             });
//             _checkUrlForPaymentStatus(url);
//           },
//           onWebResourceError: (WebResourceError error) {
//             log('WebView error: ${error.description}');
//             setState(() {
//               _isLoading = false;
//               _errorMessage = 'Failed to load payment page: ${error.description}';
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             log('Navigation request: ${request.url}');
//             _checkUrlForPaymentStatus(request.url);
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   void _checkUrlForPaymentStatus(String url) {
//     if (_paymentCompleted) return;

//     final lowercaseUrl = url.toLowerCase();
    
//     // Check for success patterns
//     final successPatterns = _successPatterns[widget.paymentMethod] ?? [];
//     for (String pattern in successPatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('Success pattern detected: $pattern in $url');
//         _handlePaymentSuccess();
//         return;
//       }
//     }

//     // Check for failure patterns
//     final failurePatterns = _failurePatterns[widget.paymentMethod] ?? [];
//     for (String pattern in failurePatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('Failure pattern detected: $pattern in $url');
//         _handlePaymentFailure('Payment was cancelled or failed');
//         return;
//       }
//     }

//     // Special handling for specific payment methods
//     if (widget.paymentMethod == 'Stripe') {
//       // Stripe redirects to success URL with session_id
//       if (lowercaseUrl.contains('session_id') || lowercaseUrl.contains('checkout_session')) {
//         _handlePaymentSuccess();
//         return;
//       }
//     }
//   }

//   void _startPaymentPolling() {
//     // Start polling for payment verification after a short delay
//     _pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (!_paymentCompleted) {
//         _verifyPaymentStatus();
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _verifyPaymentStatus() async {
//     try {
//       log('Polling payment verification for reference: ${widget.reference}');
      
//       final paymentController = Get.find<PaymentController>();
//       final verified = await paymentController.verifyPaymentManually(widget.reference);
      
//       if (verified && !_paymentCompleted) {
//         log('Payment verified through polling');
//         _handlePaymentSuccess();
//       }
//     } catch (e) {
//       log('Error during payment polling: $e');
//     }
//   }

//   void _handlePaymentSuccess() {
//     if (_paymentCompleted) return;
    
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
    
//     log('Payment completed successfully');
//     Future.delayed(const Duration(seconds: 1), () {
//     widget.onPaymentComplete(true, 'Payment completed successfully');
//   });
//   }

//   void _handlePaymentFailure(String message) {
//     if (_paymentCompleted) return;
    
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
    
//     log('Payment failed: $message');
//     widget.onPaymentComplete(false, message);
//   }

//   void _handleManualClose() {
//     if (_paymentCompleted) return;
    
//     // Show confirmation dialog before closing
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Close Payment'),
//         content: const Text('Are you sure you want to close the payment page? Your payment may not be completed.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//             },
//             child: const Text('Continue Payment'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//               _handlePaymentFailure('Payment cancelled by user');
//             },
//             child: const Text('Close Payment'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.paymentMethod} Payment'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: _handleManualClose,
//         ),
//         actions: [
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               _controller.reload();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Progress indicator
//           if (_isLoading)
//             const LinearProgressIndicator(),
          
//           // Error message
//           if (_errorMessage != null)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               color: Colors.red.shade50,
//               child: Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.red.shade700),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       _errorMessage!,
//                       style: TextStyle(color: Colors.red.shade700),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _errorMessage = null;
//                         _isLoading = true;
//                       });
//                       _controller.reload();
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
          
//           // WebView
//           Expanded(
//             child: WebViewWidget(controller: _controller),
//           ),
          
//           // Bottom info bar
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border(top: BorderSide(color: Colors.grey.shade300)),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.security, size: 16, color: Colors.green.shade600),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Secure ${widget.paymentMethod} payment processing',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'Ref: ${widget.reference.length > 10 ? widget.reference.substring(0, 10) + '...' : widget.reference}',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



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

//   // Enhanced success/failure URL patterns for different payment methods
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
//       ],
//       'failure': [
//         'cancel',
//         'failed',
//         'error',
//         'payment-cancelled',
//         'cancelled',
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
//       ],
//       'failure': [
//         'cancel',
//         'failed',
//         'error',
//         'payment-cancelled',
//         'cancelled',
//         'status=cancelled',
//         'flutterwave.com/pay/cancel',
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
//       ],
//       'failure': [
//         'cancel',
//         'payment/cancel',
//         'checkout/cancel',
//         'payment_status=unpaid',
//         'cancelled',
//       ],
//     },
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//     _startPaymentPolling();
//     _startTimeoutTimer();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
//     super.dispose();
//   }

//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             log('Page started loading: $url');
//             _checkUrlForPaymentStatus(url);
//           },
//           onPageFinished: (String url) {
//             log('Page finished loading: $url');
//             setState(() {
//               _isLoading = false;
//             });
//             _checkUrlForPaymentStatus(url);
//           },
//           onWebResourceError: (WebResourceError error) {
//             log('WebView error: ${error.description}');
//             setState(() {
//               _isLoading = false;
//               _errorMessage = 'Failed to load payment page: ${error.description}';
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             log('Navigation request: ${request.url}');
//             _checkUrlForPaymentStatus(request.url);
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   void _checkUrlForPaymentStatus(String url) {
//     if (_paymentCompleted || _isVerifying) return;

//     final lowercaseUrl = url.toLowerCase();
//     final patterns = _urlPatterns[widget.paymentMethod];
    
//     if (patterns == null) return;

//     // Check for success patterns
//     final successPatterns = patterns['success'] ?? [];
//     for (String pattern in successPatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('Success pattern detected: $pattern in $url');
//         _handlePaymentSuccess();
//         return;
//       }
//     }

//     // Check for failure patterns
//     final failurePatterns = patterns['failure'] ?? [];
//     for (String pattern in failurePatterns) {
//       if (lowercaseUrl.contains(pattern.toLowerCase())) {
//         log('Failure pattern detected: $pattern in $url');
//         _handlePaymentFailure('Payment was cancelled or failed');
//         return;
//       }
//     }

//     // Special handling for redirect URLs that might contain success/failure info
//     _handleSpecialRedirects(url);
//   }

//   void _handleSpecialRedirects(String url) {
//     // Handle app-specific redirect URLs
//     if (url.contains('localhost') || url.contains('127.0.0.1')) {
//       if (url.contains('success') || url.contains('verify')) {
//         _handlePaymentSuccess();
//       } else if (url.contains('cancel') || url.contains('failed')) {
//         _handlePaymentFailure('Payment was cancelled');
//       }
//     }
//   }

//   void _startPaymentPolling() {
//     // Start polling for payment verification after 5 seconds
//     _pollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//       if (!_paymentCompleted && !_isVerifying) {
//         _verifyPaymentStatus();
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _startTimeoutTimer() {
//     // Set a timeout for the payment process (15 minutes)
//     _timeoutTimer = Timer(const Duration(minutes: 15), () {
//       if (!_paymentCompleted) {
//         _handlePaymentFailure('Payment session timed out');
//       }
//     });
//   }

//   Future<void> _verifyPaymentStatus() async {
//     if (_isVerifying || _paymentCompleted) return;
    
//     setState(() {
//       _isVerifying = true;
//     });

//     try {
//       log('Polling payment verification for reference: ${widget.reference}');
      
//       final paymentController = Get.find<PaymentController>();
//       final verified = await paymentController.verifyPayment(
//         widget.reference, 
//         widget.paymentMethod
//       );
      
//       if (verified && !_paymentCompleted) {
//         log('Payment verified through polling');
//         _handlePaymentSuccess();
//       }
//     } catch (e) {
//       log('Error during payment polling: $e');
//     } finally {
//       setState(() {
//         _isVerifying = false;
//       });
//     }
//   }

//   void _handlePaymentSuccess() {
//     if (_paymentCompleted) return;
    
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
    
//     log('Payment completed successfully');
    
//     // Show success overlay briefly before redirecting
//     _showSuccessOverlay();
    
//     // Redirect after a short delay
//     Future.delayed(const Duration(seconds: 2), () {
//       widget.onPaymentComplete(
//         true, 
//         'Payment completed successfully',
//         orderId: widget.orderId,
//       );
//     });
//   }

//   void _handlePaymentFailure(String message) {
//     if (_paymentCompleted) return;
    
//     _paymentCompleted = true;
//     _pollTimer?.cancel();
//     _timeoutTimer?.cancel();
    
//     log('Payment failed: $message');
//     widget.onPaymentComplete(false, message, orderId: widget.orderId);
//   }

//   void _showSuccessOverlay() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 48,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Payment Successful!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Redirecting to order confirmation...',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleManualClose() {
//     if (_paymentCompleted) return;
    
//     // Show confirmation dialog before closing
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
//               Get.back(); // Close dialog
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
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     _controller.reload();
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
//                         'Verifying payment...',
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
            
//             // WebView
//             Expanded(
//               child: WebViewWidget(controller: _controller),
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


class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String reference;
  final String paymentMethod;
  final int orderId;
  final Function(bool success, String? message, {int? orderId}) onPaymentComplete;

  const PaymentWebViewScreen({
    Key? key,
    required this.url,
    required this.reference,
    required this.paymentMethod,
    required this.orderId,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollTimer;
  Timer? _timeoutTimer;
  bool _paymentCompleted = false;
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
    _initializeWebView();
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
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        setState(() {
          _errorMessage = 'Invalid payment URL format';
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

    log('Initializing WebView...');
    
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36'
        )
        ..setBackgroundColor(Colors.white)
        ..clearCache()
        ..clearLocalStorage()
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              log('🔄 Page STARTED loading: $url');
              if (!_paymentCompleted) {
                _checkUrlForPaymentStatus(url);
              }
            },
            onPageFinished: (String url) {
              log('✅ Page FINISHED loading: $url');
              setState(() {
                _isLoading = false;
                _webViewInitialized = true;
              });
              if (!_paymentCompleted) {
                _checkUrlForPaymentStatus(url);
              }
            },
            onWebResourceError: (WebResourceError error) {
              log('❌ WebView error: ${error.description} (Code: ${error.errorCode})');
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load payment page: ${error.description}';
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              log('🚀 Navigation request: ${request.url}');
              if (!_paymentCompleted) {
                _checkUrlForPaymentStatus(request.url);
              }
              return NavigationDecision.navigate;
            },
            onHttpError: (HttpResponseError error) {
              log('🔥 HTTP error: ${error.response?.statusCode}');
            },
            onUrlChange: (UrlChange change) {
              log('🔄 URL changed: ${change.url}');
              if (change.url != null && !_paymentCompleted) {
                _checkUrlForPaymentStatus(change.url!);
              }
            },
          ),
        );

      // Load the payment URL
      _loadPaymentUrl();
      
    } catch (e) {
      log('Error initializing WebView: $e');
      setState(() {
        _errorMessage = 'Failed to initialize payment page: $e';
        _isLoading = false;
      });
    }
  }

  void _loadPaymentUrl() {
    try {
      log('🌐 Loading payment URL: ${widget.url}');
      _controller.loadRequest(Uri.parse(widget.url));
      
      // Add a timeout for URL loading
      Timer(const Duration(seconds: 30), () {
        if (_isLoading && !_webViewInitialized && mounted) {
          log('⏰ URL loading timeout');
          setState(() {
            _errorMessage = 'Payment page took too long to load. Please check your internet connection.';
            _isLoading = false;
          });
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

    // Check for success patterns
    final successPatterns = patterns['success'] ?? [];
    for (String pattern in successPatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('🎉 Success pattern detected: $pattern in $url');
        _handlePaymentSuccess();
        return;
      }
    }

    // Check for failure patterns
    final failurePatterns = patterns['failure'] ?? [];
    for (String pattern in failurePatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('💥 Failure pattern detected: $pattern in $url');
        _handlePaymentFailure('Payment was cancelled or failed');
        return;
      }
    }

    // Special handling for redirect URLs
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
        _handlePaymentSuccess();
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
      if (!_paymentCompleted && !_isVerifying && _verificationAttempts < _maxVerificationAttempts) {
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

  // Fixed verification method that uses the correct controllers
  Future<void> _verifyPaymentStatus() async {
    if (_isVerifying || _paymentCompleted) return;
    
    _verificationAttempts++;
    
    setState(() {
      _isVerifying = true;
    });

    try {
      log('🔍 Polling payment verification for reference: ${widget.reference} (Attempt: $_verificationAttempts)');
      
      bool verified = false;
      
      // Use the appropriate controller based on payment method
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
      } else if (_verificationAttempts >= _maxVerificationAttempts && !_paymentCompleted) {
        log('💥 Payment verification failed after maximum attempts');
        // Don't auto-fail here, let user manually verify or close
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

  void _handlePaymentSuccess() {
    if (_paymentCompleted) return;
    
    log('=== 🎉 PAYMENT SUCCESS HANDLER CALLED ===');
    _paymentCompleted = true;
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    
    _showSuccessOverlay();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        log('📞 Calling onPaymentComplete callback with success');
        widget.onPaymentComplete(
          true, 
          'Payment completed successfully',
          orderId: widget.orderId,
        );
      }
    });
  }

  void _handlePaymentFailure(String message) {
    if (_paymentCompleted) return;
    
    log('=== 💥 PAYMENT FAILURE HANDLER CALLED ===');
    log('Payment failed: $message');
    
    _paymentCompleted = true;
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    
    if (mounted) {
      widget.onPaymentComplete(false, message, orderId: widget.orderId);
    }
  }

  void _showSuccessOverlay() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Redirecting to order confirmation...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleManualClose() {
    if (_paymentCompleted) return;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Close Payment'),
        content: const Text(
          'Are you sure you want to close the payment page? Your payment may not be completed.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => const PaymentMethodsScreen(), transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),);
              
              _handlePaymentFailure('Payment cancelled by user');
            },
            child: Text(
              'Close Payment',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRefresh() {
    log('🔄 Refreshing WebView...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _webViewInitialized = false;
    });
    
    try {
      _controller.reload();
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
      
      // Use the appropriate controller based on payment method
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
        Get.snackbar(
          'Verification Failed',
          'Payment could not be verified. Please contact support if you were charged.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      log('Manual verification error: $e');
      Get.snackbar(
        'Verification Error',
        'Could not verify payment status. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
            // Progress indicator
            if (_isLoading)
              const LinearProgressIndicator(),
            
            // Verification status
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
                        'Verifying payment... (Attempt $_verificationAttempts)',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
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
            
            // WebView or Error Display
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
                : _webViewInitialized || !_isLoading
                  ? WebViewWidget(controller: _controller)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading payment page...'),
                          SizedBox(height: 8),
                          Text(
                            'This may take a few seconds...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Bottom info bar
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