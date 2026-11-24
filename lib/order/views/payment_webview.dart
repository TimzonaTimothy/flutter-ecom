import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../base/res/base_url.dart';
import '../controllers/payment_controller.dart';
import 'order_help_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.reference,
    required this.paymentMethod,
    required this.orderId,
  });

  static const verified = 'verified';
  static const dismissed = 'dismissed';
  final String url;
  final String reference;
  final String paymentMethod;
  final int orderId;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

enum _CheckoutReturn { complete, cancelled, paystackAuthorization }

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  static const _maxChecks = 15;
  final _api = Uri.parse(baseUrl);
  Timer? _pageTimer;
  Timer? _recoveryTimer;
  bool _showRecovery = false;
  bool get _isFlutterwave => widget.paymentMethod == 'Flutterwave';
  Timer? _pollTimer;
  late final Uri? _checkoutUrl;
  int _attempt = 0;
  int _checks = 0;
  int? _popupId;
  bool _loading = true;
  bool _checking = false;
  bool _visibleCheck = false;
  bool _checkoutOverlayOpen = false;
  bool _finished = false;
  String? _deferredResult;
  String? _loadError;
  String? _statusMessage;
  _CheckoutReturn? _returned;

  @override
  void initState() {
    super.initState();
    final url = Uri.tryParse(widget.url);
    _checkoutUrl = url != null && url.scheme == 'https' && url.host.isNotEmpty
        ? url
        : null;
    if (_checkoutUrl == null) {
      _loading = false;
      _loadError = 'This payment link could not be opened.';
    } else {
      _startPageTimer();
      _startRecoveryTimer();
    }
  }

  @override
  void dispose() {
    _recoveryTimer?.cancel();
    _pageTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPageTimer() {
    _pageTimer?.cancel();
    _pageTimer = Timer(const Duration(seconds: 45), () {
      if (!mounted || _finished || !_loading) return;
      _showLoadError('The checkout page took too long to load. Try again.');
    });
  }

  void _startRecoveryTimer() {
    if (!_isFlutterwave) return;
    _recoveryTimer?.cancel();
    // A hosted page can finish navigating before its payment form appears.
    _recoveryTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted || _finished || _returned != null || _loadError != null) {
        return;
      }
      setState(() => _showRecovery = true);
    });
  }

  void _showLoadError(String message) {
    _pageTimer?.cancel();
    setState(() {
      _loading = false;
      if (_popupId != null) {
        _popupId = null;
        _statusMessage = message;
      } else {
        _loadError = message;
      }
    });
  }

  void _retry() {
    if (_checkoutUrl == null || _finished) return;
    _pollTimer?.cancel();
    setState(() {
      _attempt++;
      _showRecovery = false;
      _checks = 0;
      _popupId = null;
      _returned = null;
      _loadError = null;
      _statusMessage = null;
      _loading = true;
    });
    _startPageTimer();
    _startRecoveryTimer();
  }

  _CheckoutReturn? _checkoutReturn(WebUri? value) {
    final url = value == null ? null : Uri.tryParse(value.toString());
    if (url == null) return null;
    final gateway = widget.paymentMethod.toLowerCase();
    final path = url.path.replaceFirst(RegExp(r'/$'), '');
    if (gateway == 'paystack' &&
        url.scheme == 'https' &&
        url.host == 'standard.paystack.co' &&
        url.port == 443 &&
        path == '/close') {
      return _CheckoutReturn.paystackAuthorization;
    }
    if (url.scheme != _api.scheme ||
        url.host != _api.host ||
        url.port != _api.port) {
      return null;
    }

    final apiPath = _api.path.replaceFirst(RegExp(r'/$'), '');
    final payments = '$apiPath/payments';
    final orderReturn = '$payments/checkout-return/$gateway/${widget.orderId}';
    if (path == '$orderReturn/cancel' ||
        (gateway == 'stripe' && path == '$payments/cancel')) {
      return _CheckoutReturn.cancelled;
    }

    final reference = switch (gateway) {
      'paystack' =>
        url.queryParameters['reference'] ?? url.queryParameters['trxref'],
      'flutterwave' => url.queryParameters['tx_ref'],
      'stripe' => url.queryParameters['session_id'],
      _ => null,
    };
    if (reference != null && reference != widget.reference) return null;

    if (path == '$orderReturn/complete' ||
        (gateway == 'stripe' &&
            path == '$payments/verify-stripe-payment/${widget.reference}') ||
        (gateway == 'flutterwave' &&
            path ==
                '$payments/verify-flutterwave-payment/${widget.reference}') ||
        (gateway == 'paystack' &&
            path == '$payments/verify-paystack-payment/${widget.reference}')) {
      final status = url.queryParameters['status']?.toLowerCase();
      return const ['cancelled', 'canceled', 'failed'].contains(status)
          ? _CheckoutReturn.cancelled
          : _CheckoutReturn.complete;
    }
    return null;
  }

  bool _handleReturn(WebUri? url, {required bool popup}) {
    final result = _checkoutReturn(url);
    if (result == null) return false;
    if (_finished || _returned != null) return true;

    _pageTimer?.cancel();
    if (result == _CheckoutReturn.paystackAuthorization && popup) {
      _closePopup();
    } else {
      setState(() {
        _returned = result;
        _popupId = null;
        _loading = false;
        _loadError = null;
        _statusMessage = null;
      });
    }

    // A redirect is a cue to check the current server-side reference.
    _pollTimer?.cancel();
    _checks = 0;
    if (result != _CheckoutReturn.cancelled) _startPolling();
    unawaited(_checkPayment(
        visible: result != _CheckoutReturn.paystackAuthorization));
    return true;
  }

  void _startPolling() {
    if (_finished || _pollTimer?.isActive == true || _checks >= _maxChecks) {
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_checks >= _maxChecks) {
        timer.cancel();
      } else if (!_checking && !_finished) {
        _checks++;
        unawaited(_checkPayment());
      }
    });
  }

  Future<void> _checkPayment(
      {bool visible = false, bool manual = false}) async {
    if (!mounted || _finished) return;
    if (_checking) {
      if (visible && !_visibleCheck) setState(() => _visibleCheck = true);
      return;
    }
    setState(() {
      _checking = true;
      _visibleCheck = visible;
      if (manual) _statusMessage = null;
    });
    try {
      final controller = switch (widget.paymentMethod) {
        'PayStack' => Get.find<PaystackPaymentController>(),
        'Flutterwave' => Get.find<FlutterwavePaymentController>(),
        _ => Get.find<StripePaymentController>(),
      };
      final paid = await controller.verifyPayment(widget.reference);
      if (!mounted || _finished) return;
      if (paid) {
        _finish(PaymentWebViewScreen.verified);
      } else if (controller.verificationUnavailable &&
          (manual || _returned != null)) {
        setState(() => _statusMessage =
            'Payment status is temporarily unavailable. You can check again shortly.');
      } else if (manual) {
        setState(() => _statusMessage = 'Payment has not been confirmed yet.');
      } else if (_returned != null && _statusMessage != null) {
        setState(() => _statusMessage = null);
      }
    } catch (error) {
      log('Checkout verification unavailable: ${error.runtimeType}');
      if (mounted && manual) {
        setState(() => _statusMessage = 'Could not check payment. Try again.');
      }
    } finally {
      if (mounted && !_finished) {
        setState(() {
          _checking = false;
          _visibleCheck = false;
        });
      }
    }
  }

  void _finish(String result) {
    if (!mounted || _finished) return;
    if (_checkoutOverlayOpen) {
      _deferredResult = result;
      return;
    }
    _finished = true;
    _recoveryTimer?.cancel();
    _pageTimer?.cancel();
    _pollTimer?.cancel();
    Navigator.of(context).pop(result);
  }

  void _closePopup() {
    if (_popupId == null) return;
    _pageTimer?.cancel();
    setState(() {
      _popupId = null;
      _loading = false;
    });
    unawaited(_checkPayment());
  }

  Future<void> _close() async {
    if (_popupId != null) {
      _closePopup();
      return;
    }
    if (_finished || _checkoutOverlayOpen) return;
    if (_returned != null) {
      _finish(PaymentWebViewScreen.dismissed);
      return;
    }
    _checkoutOverlayOpen = true;
    final close = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave checkout?'),
        content: const Text('You can resume payment from My Orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave checkout'),
          ),
        ],
      ),
    );
    _checkoutOverlayOpen = false;
    if (_deferredResult case final result?) {
      _finish(result);
    } else if (close == true) {
      _finish(PaymentWebViewScreen.dismissed);
    }
  }

  Future<void> _openOrderHelp() async {
    if (_finished || _checkoutOverlayOpen) return;
    _checkoutOverlayOpen = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => OrderHelpScreen(orderId: widget.orderId),
        ),
      );
    } finally {
      _checkoutOverlayOpen = false;
      if (_deferredResult case final result?) _finish(result);
    }
  }

  Widget _recoveryNotice() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Column(
          children: [
            const Text(
                'If the payment form hasn’t appeared, you can reload Flutterwave or get help.'),
            Wrap(
              children: [
                TextButton(
                    onPressed: _retry, child: const Text('Reload checkout')),
                TextButton(
                    onPressed: _openOrderHelp, child: const Text('Get help')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _webView({int? windowId}) {
    final attempt = _attempt;
    final isPopup = windowId != null;
    bool current() =>
        mounted &&
        !_finished &&
        attempt == _attempt &&
        (!isPopup || windowId == _popupId);

    return InAppWebView(
      key: ValueKey((attempt, windowId)),
      windowId: windowId,
      initialUrlRequest:
          isPopup ? null : URLRequest(url: WebUri.uri(_checkoutUrl!)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: true,
        useShouldOverrideUrlLoading: true,
        allowsInlineMediaPlayback: true,
        supportZoom: false,
      ),
      shouldOverrideUrlLoading: (_, action) async {
        if (current() &&
            action.isForMainFrame &&
            _handleReturn(action.request.url, popup: isPopup)) {
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onLoadStart: (_, url) {
        if (current()) _handleReturn(url, popup: isPopup);
      },
      onLoadStop: (_, url) {
        if (!current() || _handleReturn(url, popup: isPopup)) return;
        if (isPopup || _popupId == null) {
          _pageTimer?.cancel();
          if (_loading) setState(() => _loading = false);
        }
        if (!isPopup) _startPolling();
      },
      onProgressChanged: (_, progress) {
        // Some hosted pages keep loading analytics after checkout is usable.
        if (current() &&
            !isPopup &&
            _popupId == null &&
            progress == 100 &&
            _loading) {
          _pageTimer?.cancel();
          setState(() => _loading = false);
          _startPolling();
        }
      },
      onReceivedError: (_, request, error) {
        if (current() &&
            request.isForMainFrame != false &&
            !_handleReturn(request.url, popup: isPopup)) {
          log('Checkout WebView load error: ${error.type}');
          _showLoadError(
              'Could not load checkout. Check your connection and try again.');
        }
      },
      onReceivedHttpError: (_, request, response) {
        final code = response.statusCode ?? 0;
        final host = request.url.host.toLowerCase();
        final isChallenge = response.headers?.entries.any((entry) =>
                entry.key.toLowerCase() == 'cf-mitigated' &&
                entry.value.toLowerCase() == 'challenge') ??
            false;
        if (current() &&
            !isPopup &&
            request.isForMainFrame == true &&
            code == 403 &&
            !isChallenge &&
            _isFlutterwave &&
            host == _checkoutUrl?.host &&
            host.endsWith('.dev-flutterwave.com')) {
          _pollTimer?.cancel();
          _showLoadError(
            'Flutterwave’s sandbox blocked this checkout. You can retry, check payment status, or get help with this order.',
          );
          return;
        }
        // A hosted checkout can serve a browser challenge as a 403 page.
        // Let the native WebView render and run it.
        if (current() &&
            request.isForMainFrame == true &&
            code >= 400 &&
            code != 403 &&
            !_handleReturn(request.url, popup: isPopup)) {
          _showLoadError(
            'The payment provider could not open this page. Try again.',
          );
        }
      },
      onCreateWindow: (_, action) async {
        if (!current() || isPopup || _popupId != null || _returned != null) {
          return false;
        }
        if (_handleReturn(action.request.url, popup: false)) return false;
        setState(() {
          _popupId = action.windowId;
          _loading = true;
        });
        _startPageTimer();
        return true;
      },
      onCloseWindow: (_) {
        if (current() && isPopup) _closePopup();
      },
    );
  }

  Widget _statusPanel() {
    final cancelled = _returned == _CheckoutReturn.cancelled;
    final title = _loadError != null
        ? 'Checkout unavailable'
        : cancelled
            ? 'Checkout cancelled'
            : 'Waiting for payment confirmation';
    final description = _loadError ??
        (cancelled
            ? 'You can resume checkout or check for a payment already made.'
            : 'You can check again or view this order later in My Orders.');
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if ((_loadError != null && _checkoutUrl != null) || cancelled)
              FilledButton(
                  onPressed: _retry,
                  child: Text(cancelled ? 'Resume checkout' : 'Retry')),
            TextButton(
              onPressed: _checking
                  ? null
                  : () => _checkPayment(visible: true, manual: true),
              child: const Text('Check payment status'),
            ),
            if (_isFlutterwave && _loadError != null)
              TextButton(
                  onPressed: _openOrderHelp,
                  child: const Text('Get help with this order')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<String>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: _popupId == null ? 'Close checkout' : 'Back to checkout',
            icon: Icon(_popupId == null ? Icons.close : Icons.arrow_back),
            onPressed: _close,
          ),
          title: Text('${widget.paymentMethod} checkout'),
          actions: [
            if (_returned == null && _loadError == null && _popupId == null)
              IconButton(
                  tooltip: 'Reload checkout',
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh)),
            if (_returned == null && _loadError == null)
              IconButton(
                tooltip: 'Check payment status',
                onPressed: _checking
                    ? null
                    : () => _checkPayment(visible: true, manual: true),
                icon: const Icon(Icons.verified_outlined),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (_loading || _visibleCheck) const LinearProgressIndicator(),
              if (_showRecovery &&
                  _loadError == null &&
                  _returned == null &&
                  _popupId == null)
                _recoveryNotice(),
              if (_statusMessage case final message?)
                Padding(
                    padding: const EdgeInsets.all(12), child: Text(message)),
              Expanded(
                child: _loadError != null || _returned != null
                    ? _statusPanel()
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          _webView(),
                          if (_popupId case final popupId?)
                            ColoredBox(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: _webView(windowId: popupId)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
