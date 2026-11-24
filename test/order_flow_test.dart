import 'dart:convert';
import 'dart:async';
import 'package:ecom_app/order/controllers/review_controller.dart';
import 'package:ecom_app/order/views/review_screen.dart';
import 'package:ecom_app/order/views/reciept_screen.dart';
import 'package:ecom_app/auth/service/auth_service.dart';
import 'package:ecom_app/base/res/base_url.dart';
import 'package:ecom_app/base/res/styles/app_styles.dart';
import 'package:ecom_app/order/controllers/order_controller.dart';
import 'package:ecom_app/order/controllers/payment_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom_app/order/models/order_model.dart';
import 'package:ecom_app/order/views/my_orders_screen.dart';
import 'package:ecom_app/order/views/order_help_screen.dart';
import 'package:ecom_app/order/views/payment_webview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ecom_app/order/views/track_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Auth extends AuthService {
  @override
  Future<String?> getToken() async => 'test';
}

class _CheckoutWebViewPlatform extends InAppWebViewPlatform {
  final views = <_CheckoutWebView>[];

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    final view = _CheckoutWebView(params);
    views.add(view);
    return view;
  }
}

class _CheckoutWebView extends PlatformInAppWebViewWidget {
  _CheckoutWebView(PlatformInAppWebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) => const Text('Embedded checkout');

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      throw UnimplementedError();

  @override
  void dispose() {}
}

class _CheckoutWebViewController extends Fake
    implements InAppWebViewController {}

class _PaystackVerification extends PaystackPaymentController {
  int checks = 0;

  @override
  Future<bool> verifyPayment(String reference) async {
    expect(reference, 'test-reference');
    checks++;
    return false;
  }
}

Map<String, dynamic> orderJson(int id, String status) => {
      'id': id,
      'delivery_status': status,
      'payment_status': 'Paid',
      'created_date': '2026-10-01T10:00:00Z',
      'total': '65.00',
      'subtotal': 65,
      'total_quantity': 3,
      'rated': [0],
      'address': {'address': '123 Test Street', 'phone': '123456'},
      'order_products': [
        {
          'product_id': 10,
          'title': 'Shirt',
          'price': 25,
          'quantity': 2,
          'size': 'M',
          'color': 'Blue'
        },
        {
          'product_id': 11,
          'title': 'Socks',
          'price': '15.00',
          'quantity': 1,
          'size': 'L',
          'color': 'White'
        },
      ],
    };

http.Response jsonResponse(Object value, [int status = 200]) =>
    http.Response(jsonEncode(value), status);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'user_id': 41});
    Get.testMode = true;
    Get.put<AuthService>(_Auth());
    AppStyles.textStyle = const TextStyle();
    AppStyles.headLineStyle1 = const TextStyle(fontSize: 26);
    AppStyles.headLineStyle2 = const TextStyle(fontSize: 20);
    AppStyles.headLineStyle3 = const TextStyle(fontSize: 17);
    AppStyles.headLineStyle4 = const TextStyle(fontSize: 14);
  });
  tearDown(() => Get.reset());

  test('backend order snapshots retain purchased prices and selected variants',
      () {
    final order = OrderModel.fromJson(orderJson(1, 'Delivered'));
    expect(order.total, 65);
    expect(order.orderProducts.first.unitPrice, 25);
    expect(order.orderProducts.first.lineTotal, 50);
    expect(order.orderProducts.first.sizes, ['M']);
    expect(order.orderProducts.first.colors, ['Blue']);
    expect(order.orderProducts.first.imageUrls, isEmpty);
    expect(order.address.address, '123 Test Street');
  });

  test('active loading uses one combined endpoint and removes duplicate orders',
      () async {
    final calls = <String>[];
    await http.runWithClient(() async {
      final controller = Get.put(OrderController());
      await controller.loadAllOrders();
      expect(calls.where((path) => path == 'Pending').length, 1);
      expect(calls, isNot(contains('Shipped')));
      expect(controller.pendingOrders.map((order) => order.id), [1, 2]);
      expect(controller.isPendingLoading.value, isFalse);
      await controller.fetchOrder(1);
      expect(controller.pendingOrders.map((order) => order.id), [2]);
      expect(controller.deliveredOrders.map((order) => order.id), [1]);
    },
        () => MockClient((request) async {
              if (request.url.path.contains('/single/'))
                return jsonResponse(orderJson(1, 'Delivered'));
              final status = request.url.queryParameters['status']!;
              calls.add(status);
              return jsonResponse(status == 'Pending'
                  ? [
                      orderJson(1, 'Pending'),
                      orderJson(2, 'Shipped'),
                      orderJson(2, 'Shipped')
                    ]
                  : []);
            }));
  });

  test('checkout retries reuse the persisted key and the quoted amount',
      () async {
    final quote = {
      'total': '38.19',
      'draft': {
        'address': 3,
        'order_products': [
          {'id': 7, 'quantity': 3}
        ],
      },
    };
    final keys = <String?>[];
    await http.runWithClient(() async {
      expect(await PaystackPaymentController().createOrder(quote), isNull);
      final replay = await PaystackPaymentController().createOrder(quote);
      expect(replay?['id'], 123);
      await PaystackPaymentController().forgetCheckout(123);
      await PaystackPaymentController().createOrder(quote);
    },
        () => MockClient((request) async {
              keys.add(request.headers['idempotency-key']);
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              expect(body['expected_total'], '38.19');
              expect(body.containsKey('total'), isFalse);
              if (keys.length == 1) return jsonResponse({}, 503);
              return jsonResponse({'id': 123, 'total': '38.19'}, 200);
            }));
    expect(keys, hasLength(3));
    expect(keys.first, isNotNull);
    expect(keys[1], keys.first);
    expect(keys[2], isNot(keys.first));
  });

  testWidgets('Paystack loads in-app before background verification starts',
      (tester) async {
    final original = InAppWebViewPlatform.instance;
    final webView = _CheckoutWebViewPlatform();
    InAppWebViewPlatform.instance = webView;
    addTearDown(() {
      if (original != null) InAppWebViewPlatform.instance = original;
    });

    final payment = _PaystackVerification();
    Get.put<PaystackPaymentController>(payment);
    const checkoutUrl = 'https://checkout.paystack.com/test-session';
    await tester.pumpWidget(const GetMaterialApp(
      home: PaymentWebViewScreen(
        url: checkoutUrl,
        reference: 'test-reference',
        paymentMethod: 'PayStack',
        orderId: 90,
      ),
    ));
    final initialParams = webView.views.single.params;
    tester.binding.addPostFrameCallback((_) {
      initialParams.onReceivedHttpError!(
        _CheckoutWebViewController(),
        WebResourceRequest(url: WebUri(checkoutUrl), isForMainFrame: true),
        WebResourceResponse(statusCode: 403),
      );
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Embedded checkout'), findsOneWidget);
    expect(payment.checks, 0);

    await tester.pump(const Duration(seconds: 52));
    expect(find.textContaining('took too long'), findsWidgets);
    await tester.tap(find.text('Retry').first);
    await tester.pump();
    expect(webView.views, hasLength(2));
    final params = webView.views.last.params;
    expect(params.initialUrlRequest?.url.toString(), checkoutUrl);
    tester.binding.addPostFrameCallback((_) {
      params.onLoadStop!
          .call(_CheckoutWebViewController(), WebUri(checkoutUrl));
    });
    await tester.pump();
    expect(Get.find<PaystackPaymentController>(), same(payment));
    await tester.pump(const Duration(seconds: 9));
    expect(payment.checks, 1);
    expect(find.text('Verifying payment...'), findsNothing);

    bool? acceptedPopup;
    tester.binding.addPostFrameCallback((_) {
      params.onCreateWindow!(
        _CheckoutWebViewController(),
        CreateWindowAction(
          windowId: 42,
          request: URLRequest(url: WebUri('https://bank.example.com/3ds')),
          isForMainFrame: true,
        ),
      )
          .then((result) => acceptedPopup = result);
    });
    await tester.pump();
    await tester.pump();
    expect(acceptedPopup, isTrue);
    final popup = webView.views.last.params;
    expect(popup.windowId, 42);
    expect(popup.initialUrlRequest, isNull);
    expect(find.byTooltip('Back to checkout'), findsOneWidget);

    tester.binding.addPostFrameCallback((_) {
      popup.shouldOverrideUrlLoading!(
        _CheckoutWebViewController(),
        NavigationAction(
          request:
              URLRequest(url: WebUri('https://standard.paystack.co/close')),
          isForMainFrame: true,
        ),
      );
    });
    await tester.pump();
    await tester.pump();
    expect(find.byTooltip('Back to checkout'), findsNothing);
    expect(find.text('Embedded checkout'), findsOneWidget);
    expect(payment.checks, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final (label, gateway, referenceParameter) in [
    ('PayStack', 'paystack', 'reference'),
    ('Flutterwave', 'flutterwave', 'tx_ref'),
    ('Stripe', 'stripe', 'session_id'),
  ]) {
    testWidgets('$label verifies the current session after a trusted return',
        (tester) async {
      final original = InAppWebViewPlatform.instance;
      final webView = _CheckoutWebViewPlatform();
      InAppWebViewPlatform.instance = webView;
      addTearDown(() {
        if (original != null) InAppWebViewPlatform.instance = original;
      });
      Get.put(PaystackPaymentController());
      Get.put(FlutterwavePaymentController());
      Get.put(StripePaymentController());

      var checks = 0;
      var paid = false;
      String? result;
      await http.runWithClient(() async {
        await tester.pumpWidget(GetMaterialApp(
          home: Builder(builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => PaymentWebViewScreen(
                      url: 'https://checkout.example.com/start',
                      reference: 'test-reference',
                      paymentMethod: label,
                      orderId: 90,
                    ),
                  ),
                );
              },
              child: const Text('Open checkout'),
            );
          }),
        ));
        await tester.tap(find.text('Open checkout'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        Future<NavigationActionPolicy?> navigateTo(String url) async {
          NavigationActionPolicy? policy;
          tester.binding.addPostFrameCallback((_) {
            webView
                .views
                .last
                .params
                .shouldOverrideUrlLoading!(
              _CheckoutWebViewController(),
              NavigationAction(
                request: URLRequest(url: WebUri(url)),
                isForMainFrame: true,
              ),
            )
                .then((value) => policy = value);
          });
          await tester.pump();
          await tester.pump();
          return policy;
        }

        final returnPath = 'payments/checkout-return/$gateway/90/complete/';
        expect(
          await navigateTo(
              'https://unrelated.example.com/$returnPath?status=failed'),
          NavigationActionPolicy.ALLOW,
        );
        expect(checks, 0);

        expect(
          await navigateTo(
              '$baseUrl/$returnPath?$referenceParameter=other-order'),
          NavigationActionPolicy.ALLOW,
        );
        expect(checks, 0);

        expect(
          await navigateTo(
              '$baseUrl/$returnPath?$referenceParameter=test-reference'),
          NavigationActionPolicy.CANCEL,
        );
        expect(checks, 1);
        expect(result, isNull);
        expect(find.text('Waiting for payment confirmation'), findsOneWidget);

        paid = true;
        await tester.tap(find.text('Check payment status'));
        await tester.pumpAndSettle();
        expect(checks, 2);
        expect(result, PaymentWebViewScreen.verified);
      },
          () => MockClient((request) async {
                expect(request.url.path,
                    endsWith('/verify-$gateway-payment/test-reference/'));
                checks++;
                return jsonResponse(
                    {'payment_status': paid ? 'Paid' : 'Unpaid'},
                    paid ? 200 : 400);
              }));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  test('payment controllers surface the gateway error from Django', () async {
    for (final controller in [
      PaystackPaymentController(),
      FlutterwavePaymentController(),
      StripePaymentController(),
    ]) {
      await http.runWithClient(() async {
        expect(
            await controller.initiatePayment(amount: 65, orderId: 1), isFalse);
        expect(controller.errorMessage.value,
            'Continue this order with Paystack.');
      },
          () => MockClient((request) async {
                expect(jsonDecode(request.body), {'order_id': 1});
                return jsonResponse({
                  'error': {
                    'message': 'Bad request',
                    'details': ['Continue this order with Paystack.'],
                  }
                }, 400);
              }));
    }
  });

  testWidgets('order help sends the issue and shows the support reference',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const GetMaterialApp(home: OrderHelpScreen(orderId: 15)),
      );
      expect(find.text('Help with order #15'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'My parcel is missing.');
      await tester.pump();
      await tester.tap(find.text('Send request'));
      await tester.pumpAndSettle();

      expect(find.text('Request sent. Your support reference is #27.'),
          findsOneWidget);
    },
        () => MockClient((request) async {
              expect(request.url.path, endsWith('/orders/single/15/support/'));
              expect(request.method, 'POST');
              expect(jsonDecode(request.body),
                  {'message': 'My parcel is missing.'});
              return jsonResponse({'id': 27});
            }));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('only an unpaid pending order can reopen its original checkout',
      (tester) async {
    final unpaid = {
      ...orderJson(1, 'Pending'),
      'payment_status': 'Unpaid',
    };
    final checkoutRequests = <Map<String, dynamic>>[];
    var verified = false;
    await http.runWithClient(() async {
      await tester.pumpWidget(const GetMaterialApp(home: OrdersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Resume payment'), findsOneWidget);
      await tester.tap(find.text('Resume payment'));
      await tester.pumpAndSettle();

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('USD 65.00'), findsOneWidget);
      expect(find.text('Stripe'), findsOneWidget);
      expect(find.text('PayStack'), findsNothing);
      expect(find.text('Continue payment'), findsOneWidget);
      await tester.tap(find.text('Continue payment'));
      await tester.pumpAndSettle();

      expect(checkoutRequests, [
        {'order_id': 1, 'resume': true}
      ]);
      expect(verified, isTrue);
      expect(find.text('Payment: Paid'), findsWidgets);
      expect(find.text('Resume payment'), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path.endsWith('/initiate-stripe-payment/')) {
                checkoutRequests
                    .add(jsonDecode(request.body) as Map<String, dynamic>);
                return jsonResponse({
                  'reused': true,
                  'data': {
                    'link': 'https://example.com/checkout',
                    'reference': 'original-session',
                  },
                }, 201);
              }
              if (request.url.path
                  .contains('/verify-stripe-payment/original-session/')) {
                verified = true;
                return jsonResponse({'payment_status': 'Paid'});
              }
              expect(request.method, 'GET');
              if (request.url.path.contains('/single/')) {
                return jsonResponse({
                  ...unpaid,
                  'payment_mode': 'Stripe',
                  if (verified) 'payment_status': 'Paid',
                });
              }
              return jsonResponse(
                  request.url.queryParameters['status'] == 'Pending'
                      ? [
                          unpaid,
                          orderJson(2, 'Pending'),
                          {
                            ...orderJson(3, 'Shipped'),
                            'payment_status': 'Unpaid'
                          },
                        ]
                      : []);
            }));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'opening an order fetches fresh status and shows every purchased item',
      (tester) async {
    var detailsCalls = 0;
    await http.runWithClient(() async {
      final controller = Get.put(OrderController());
      await controller.loadAllOrders();
      controller.cacheOrder(OrderModel.fromJson(orderJson(1, 'Pending')));
      await tester
          .pumpWidget(const GetMaterialApp(home: TrackOrderPage(orderId: 1)));
      await tester.pumpAndSettle();
      expect(detailsCalls, 1);
      expect(find.text('Shirt'), findsOneWidget);
      expect(find.text('Socks'), findsOneWidget);
      expect(find.text('Size: M'), findsOneWidget);
      expect(find.text('Color: Blue'), findsOneWidget);
      expect(find.text('Item total: \$50.00'), findsOneWidget);
      expect(controller.getOrderById(1)!.deliveryStatus, 'Delivered');
      expect(find.text('Expected Delivery Date'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path.contains('/single/')) {
                detailsCalls++;
                return jsonResponse(orderJson(1, 'Delivered'));
              }
              return jsonResponse([]);
            }));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed detail load retries with a fresh request',
      (tester) async {
    var attempts = 0;
    await http.runWithClient(() async {
      await tester
          .pumpWidget(const GetMaterialApp(home: TrackOrderPage(orderId: 1)));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text('Shirt'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.path.contains('/single/')) {
                attempts++;
                return attempts == 1
                    ? jsonResponse({}, 500)
                    : jsonResponse(orderJson(1, 'Cancelled'));
              }
              return jsonResponse([]);
            }));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('empty My Orders remains refreshable and tabs can be reopened',
      (tester) async {
    var activeCalls = 0;
    await http.runWithClient(() async {
      await tester.pumpWidget(const GetMaterialApp(home: OrdersScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No active orders yet'), findsOneWidget);
      await tester.drag(
          find.byType(CustomScrollView).first, const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(activeCalls, 2);
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('No completed orders yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              if (request.url.queryParameters['status'] == 'Pending')
                activeCalls++;
              return jsonResponse([]);
            }));
  });
  testWidgets('receipt uses the selected order instead of placeholder data',
      (tester) async {
    await http.runWithClient(() async {
      await tester
          .pumpWidget(const GetMaterialApp(home: EReceiptScreen(orderId: 42)));
      await tester.pumpAndSettle();
      expect(find.text('Receipt #42'), findsOneWidget);
      expect(find.text('Shirt'), findsOneWidget);
      expect(find.text('Socks'), findsOneWidget);
      expect(find.text('Brown Jacket'), findsNothing);
      expect(find.text('Review Item'), findsNothing);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async => jsonResponse(
              request.url.path.contains('/single/42/')
                  ? orderJson(42, 'Delivered')
                  : [],
            )));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('closing a review preserves another screen’s review controller',
      (tester) async {
    final parent = Get.put(ReviewController());
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(
          const GetMaterialApp(home: LeaveReviewPage(productId: 10)));
      await tester.pump();
      expect(Get.find<ReviewController>(), same(parent));
      await tester.pumpWidget(const SizedBox.shrink());
      response.complete(jsonResponse({}, 404));
      await tester.pumpAndSettle();
      expect(Get.find<ReviewController>(), same(parent));
      expect(parent.isClosed, isFalse);
      expect(tester.takeException(), isNull);
    }, () => MockClient((request) => response.future));
  });
}
