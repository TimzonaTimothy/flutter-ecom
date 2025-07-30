import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/payment_controller.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String reference;
  final String paymentMethod;
  final Function(bool success, String? message) onPaymentComplete;

  const PaymentWebViewScreen({
    Key? key,
    required this.url,
    required this.reference,
    required this.paymentMethod,
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
  bool _paymentCompleted = false;

  // Success/failure URL patterns for different payment methods
  final Map<String, List<String>> _successPatterns = {
    'PayStack': [
      'callback',
      'success',
      'verify',
      'payment-success',
      'completed',
    ],
    'Flutterwave': [
      'callback',
      'success',
      'verify',
      'payment-success',
      'completed',
      'flutterwave.com/pay/success',
    ],
    'Stripe': [
      'success',
      'payment/success',
      'checkout/success',
      'verify-stripe-payment',
    ],
  };

  final Map<String, List<String>> _failurePatterns = {
    'PayStack': [
      'cancel',
      'failed',
      'error',
      'payment-cancelled',
    ],
    'Flutterwave': [
      'cancel',
      'failed',
      'error',
      'payment-cancelled',
      'flutterwave.com/pay/cancel',
    ],
    'Stripe': [
      'cancel',
      'payment/cancel',
      'checkout/cancel',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startPaymentPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Page started loading: $url');
            _checkUrlForPaymentStatus(url);
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            _checkUrlForPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load payment page: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Navigation request: ${request.url}');
            _checkUrlForPaymentStatus(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkUrlForPaymentStatus(String url) {
    if (_paymentCompleted) return;

    final lowercaseUrl = url.toLowerCase();
    
    // Check for success patterns
    final successPatterns = _successPatterns[widget.paymentMethod] ?? [];
    for (String pattern in successPatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('Success pattern detected: $pattern in $url');
        _handlePaymentSuccess();
        return;
      }
    }

    // Check for failure patterns
    final failurePatterns = _failurePatterns[widget.paymentMethod] ?? [];
    for (String pattern in failurePatterns) {
      if (lowercaseUrl.contains(pattern.toLowerCase())) {
        log('Failure pattern detected: $pattern in $url');
        _handlePaymentFailure('Payment was cancelled or failed');
        return;
      }
    }

    // Special handling for specific payment methods
    if (widget.paymentMethod == 'Stripe') {
      // Stripe redirects to success URL with session_id
      if (lowercaseUrl.contains('session_id') || lowercaseUrl.contains('checkout_session')) {
        _handlePaymentSuccess();
        return;
      }
    }
  }

  void _startPaymentPolling() {
    // Start polling for payment verification after a short delay
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_paymentCompleted) {
        _verifyPaymentStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyPaymentStatus() async {
    try {
      log('Polling payment verification for reference: ${widget.reference}');
      
      final paymentController = Get.find<PaymentController>();
      final verified = await paymentController.verifyPaymentManually(widget.reference);
      
      if (verified && !_paymentCompleted) {
        log('Payment verified through polling');
        _handlePaymentSuccess();
      }
    } catch (e) {
      log('Error during payment polling: $e');
    }
  }

  void _handlePaymentSuccess() {
    if (_paymentCompleted) return;
    
    _paymentCompleted = true;
    _pollTimer?.cancel();
    
    log('Payment completed successfully');
    Future.delayed(const Duration(seconds: 1), () {
    widget.onPaymentComplete(true, 'Payment completed successfully');
  });
  }

  void _handlePaymentFailure(String message) {
    if (_paymentCompleted) return;
    
    _paymentCompleted = true;
    _pollTimer?.cancel();
    
    log('Payment failed: $message');
    widget.onPaymentComplete(false, message);
  }

  void _handleManualClose() {
    if (_paymentCompleted) return;
    
    // Show confirmation dialog before closing
    Get.dialog(
      AlertDialog(
        title: const Text('Close Payment'),
        content: const Text('Are you sure you want to close the payment page? Your payment may not be completed.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _handlePaymentFailure('Payment cancelled by user');
            },
            child: const Text('Close Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          if (_isLoading)
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
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_isLoading)
            const LinearProgressIndicator(),
          
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
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                      });
                      _controller.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
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
                  'Ref: ${widget.reference.length > 10 ? widget.reference.substring(0, 10) + '...' : widget.reference}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}