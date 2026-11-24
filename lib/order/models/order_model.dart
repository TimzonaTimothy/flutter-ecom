int? _int(dynamic value) => value is int ? value : int.tryParse('$value');
double? _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value');
List<String> _strings(dynamic value) =>
    (value is List ? value : [if (value != null) value])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();

class OrderModel {
  final int? id; // Made nullable
  final String? customerId; // Made nullable
  final Address address;
  final List<OrderProduct> orderProducts;
  final List<int> rated;
  final int? totalQuantity; // Made nullable
  final double? subtotal; // Made nullable
  final double? shipping;
  final double? tax;
  final double? total; // Made nullable
  final String? deliveryStatus; // Made nullable
  final String? paymentMode;
  final bool canSwitchPaymentMethod;
  final String? paymentStatus; // Made nullable
  final DateTime? createdDate; // Made nullable
  final DateTime? modifiedDate; // Made nullable
  final int? userId; // Made nullable

  OrderModel({
    this.id,
    this.customerId,
    required this.address,
    required this.orderProducts,
    required this.rated,
    this.totalQuantity,
    this.subtotal,
    this.total,
    this.shipping,
    this.tax,
    this.deliveryStatus,
    this.paymentStatus,
    this.paymentMode,
    this.canSwitchPaymentMethod = false,
    this.createdDate,
    this.modifiedDate,
    this.userId,
  });

  String formatAmount(double? value) {
    if (value == null) return 'Unavailable';
    final usesNaira =
        ['paystack', 'flutterwave'].contains(paymentMode?.toLowerCase());
    final symbol = usesNaira ? '₦' : r'$';
    return '$symbol${value.toStringAsFixed(2)}';
  }

  bool get canResumePayment =>
      id != null &&
      deliveryStatus == 'Pending' &&
      (paymentStatus == 'Unpaid' || paymentStatus == 'Failed') &&
      total != null &&
      total!.isFinite &&
      total! > 0;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _int(json['id']),
      customerId: json['customer_id'] as String?,
      address: Address.fromJson(json['address'] ?? {}),
      orderProducts: (json['order_products'] as List<dynamic>?)
              ?.map((product) => OrderProduct.fromJson(product))
              .toList() ??
          [],
      rated: (json['rated'] as List? ?? []).map(_int).whereType<int>().toList(),
      totalQuantity: _int(json['total_quantity']),
      subtotal: _double(json['subtotal']),
      total: _double(json['total']),
      shipping: _double(json['shipping']),
      tax: _double(json['tax']),
      deliveryStatus: json['delivery_status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentMode: json['payment_mode'] as String?,
      canSwitchPaymentMethod: json['can_switch_payment_method'] == true,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      modifiedDate: json['modified_date'] != null
          ? DateTime.parse(json['modified_date'])
          : null,
      userId: _int(json['user']),
    );
  }
}

class OrderProduct {
  final int? id; // Made nullable
  final ProductCategory? category; // Made nullable
  final ProductBrand? brand; // Made nullable
  final List<String> colors;
  final List<String> sizes;
  final String? title; // Made nullable
  final String? slug; // Made nullable
  final String? description; // Made nullable
  final int? stock; // Made nullable
  final bool? isFeatured; // Made nullable
  final bool? isAvailable; // Made nullable
  final String? originalPrice; // Made nullable
  final String? discountPrice; // Made nullable
  final double? rating; // Made nullable
  final int? quantity;
  final String? productType; // Made nullable
  final List<String> imageUrls;
  final DateTime? createdDate; // Made nullable
  final DateTime? modifiedDate; // Made nullable

  OrderProduct({
    this.id,
    this.category,
    this.brand,
    required this.colors,
    required this.sizes,
    this.title,
    this.slug,
    this.description,
    this.stock,
    this.isFeatured,
    this.isAvailable,
    this.originalPrice,
    this.discountPrice,
    this.rating,
    this.quantity,
    this.productType,
    required this.imageUrls,
    this.createdDate,
    this.modifiedDate,
  });

  double? get unitPrice =>
      double.tryParse(discountPrice ?? originalPrice ?? '');
  double? get lineTotal =>
      unitPrice == null ? null : unitPrice! * (quantity ?? 1);

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: _int(json['product_id'] ??
          json['id']), // Changed from 'id' to 'product_id'
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'])
          : null,
      brand:
          json['brand'] != null ? ProductBrand.fromJson(json['brand']) : null,
      colors: _strings(json['color'] ?? json['colors']),
      sizes: _strings(json['size'] ?? json['sizes']),
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      stock: json['stock'] as int?,
      isFeatured: json['is_featured'] as bool?,
      isAvailable: json['is_available'] as bool?,
      originalPrice: json['original_price']?.toString(),
      discountPrice: (json['price'] ?? json['discount_price'])?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      quantity: _int(json['quantity']),
      productType: json['product_type'] as String?,
      imageUrls: _strings(json['imageUrls'] ?? json['imageUrl']),
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      modifiedDate: json['modified_date'] != null
          ? DateTime.parse(json['modified_date'])
          : null,
    );
  }
}

class ProductCategory {
  final int id;
  final String title;
  final String slug;
  final String image;

  ProductCategory({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: _int(json['id']) ?? 0,
      title: json['title'],
      slug: json['slug'],
      image: json['image'],
    );
  }
}

class ProductBrand {
  final int id;
  final String title;
  final String slug;

  ProductBrand({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory ProductBrand.fromJson(Map<String, dynamic> json) {
    return ProductBrand(
      id: _int(json['id']) ?? 0,
      title: json['title'],
      slug: json['slug'],
    );
  }
}

class Address {
  final int id;
  final double lat;
  final double lng;
  final bool isDefault;
  final String address;
  final String phone;
  final String addressType;
  final DateTime createdDate;
  final DateTime modifiedDate;
  final int userId;

  Address({
    required this.id,
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.address,
    required this.phone,
    required this.addressType,
    required this.createdDate,
    required this.modifiedDate,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _int(json['id']) ?? 0,
      lat: _double(json['lat']) ?? 0,
      lng: _double(json['lng']) ?? 0,
      isDefault: json['isDefault'] == true,
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressType: json['addressType']?.toString() ?? '',
      createdDate:
          DateTime.tryParse('${json['created_date'] ?? ''}') ?? DateTime(1970),
      modifiedDate:
          DateTime.tryParse('${json['modified_date'] ?? ''}') ?? DateTime(1970),
      userId: _int(json['user']) ?? 0,
    );
  }
}
