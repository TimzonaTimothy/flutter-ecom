import '../../cart/models/address_model.dart';
import '../../cart/models/cart_model.dart';

class PaymentRequest {
  final double amount;
  final String currency;
  final Map<String, dynamic>? metadata;

  PaymentRequest({
    required this.amount,
    required this.currency,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'metadata': metadata ?? {},
    };
  }
}

class PaystackPaymentRequest extends PaymentRequest {
  PaystackPaymentRequest({
    required super.amount,
    super.currency = 'NGN',
    super.metadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': (amount * 100).toInt(), // Convert to kobo
      'currency': currency,
      'metadata': metadata ?? {},
    };
  }
}

class FlutterwavePaymentRequest extends PaymentRequest {
  FlutterwavePaymentRequest({
    required super.amount,
    super.currency = 'NGN',
    super.metadata,
  });
}

class StripePaymentRequest extends PaymentRequest {
  StripePaymentRequest({
    required super.amount,
    super.currency = 'usd',
    super.metadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': (amount * 100).toInt(), // Convert to cents
      'currency': currency.toLowerCase(),
      'metadata': metadata ?? {},
    };
  }
}

class PaymentResponse {
  final bool success;
  final String? authorizationUrl;
  final String? reference;
  final String? sessionId;
  final String? message;
  final Map<String, dynamic>? data;

  PaymentResponse({
    required this.success,
    this.authorizationUrl,
    this.reference,
    this.sessionId,
    this.message,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      authorizationUrl: json['authorization_url'] ?? 
                       json['data']?['authorization_url'] ??
                       json['checkout_url'],
      reference: json['reference'] ?? 
                json['data']?['reference'] ?? 
                json['data']?['tx_ref'],
      sessionId: json['session_id'] ?? json['data']?['id'],
      message: json['message'],
      data: json['data'],
    );
  }
}

class PaymentVerificationResponse {
  final bool verified;
  final String paymentStatus;
  final double? amount;
  final String? message;
  final Map<String, dynamic>? data;

  PaymentVerificationResponse({
    required this.verified,
    required this.paymentStatus,
    this.amount,
    this.message,
    this.data,
  });

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponse(
      verified: json['payment_status'] == 'Paid',
      paymentStatus: json['payment_status'] ?? 'Unknown',
      amount: json['amount']?.toDouble(),
      message: json['message'],
      data: json,
    );
  }
}

class OrderCreationRequest {
  final List<OrderItem> items;
  final AddressModel shippingAddress;
  final double totalAmount;
  final double shippingCost;
  final double tax;
  final String? notes;

  OrderCreationRequest({
    required this.items,
    required this.shippingAddress,
    required this.totalAmount,
    this.shippingCost = 5.0,
    this.tax = 2.5,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      'total_amount': totalAmount,
      'shipping_cost': shippingCost,
      'tax': tax,
      'notes': notes,
    };
  }
}


class OrderItem {
  final int id;
  final int quantity;
  final String? size;
  final String? color;
  final double price;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
  });

  factory OrderItem.fromCartModel(CartModel cartItem) {
    double price = 0.0;
    if (cartItem.product?.discountPrice != null) {
      price = double.tryParse(cartItem.product!.discountPrice!) ?? 0.0;
    } else if (cartItem.product?.originalPrice != null) {
      price = double.tryParse(cartItem.product!.originalPrice!) ?? 0.0;
    }

    return OrderItem(
      id: cartItem.product?.id ?? 0,
      quantity: cartItem.quantity ?? 1,
      price: price,
      size: cartItem.size,
      color: cartItem.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'price': price,
      'sizes': size,
      'colors': color,
    };
  }
}