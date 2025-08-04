class OrderModel {
  final int? id; // Made nullable
  final String? customerId; // Made nullable
  final Address address;
  final List<OrderProduct> orderProducts;
  final List<int> rated;
  final int? totalQuantity; // Made nullable
  final double? subtotal; // Made nullable
  final double? total; // Made nullable
  final String? deliveryStatus; // Made nullable
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
    this.deliveryStatus,
    this.paymentStatus,
    this.createdDate,
    this.modifiedDate,
    this.userId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      customerId: json['customer_id'] as String?,
      address: Address.fromJson(json['address'] ?? {}),
      orderProducts: (json['order_products'] as List<dynamic>?)
              ?.map((product) => OrderProduct.fromJson(product))
              .toList() ??
          [],
      rated: List<int>.from(json['rated'] ?? []),
      totalQuantity: json['total_quantity'] as int?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      deliveryStatus: json['delivery_status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      modifiedDate: json['modified_date'] != null
          ? DateTime.parse(json['modified_date'])
          : null,
      userId: json['user'] as int?,
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

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['product_id'] as int?, // Changed from 'id' to 'product_id'
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'])
          : null,
      brand: json['brand'] != null ? ProductBrand.fromJson(json['brand']) : null,
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      stock: json['stock'] as int?,
      isFeatured: json['is_featured'] as bool?,
      isAvailable: json['is_available'] as bool?,
      originalPrice: json['original_price'] as String?,
      discountPrice: json['discount_price'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
      productType: json['product_type'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] ?? [json['imageUrl'] ?? '']),
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
      id: json['id'],
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
      id: json['id'],
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
      id: json['id'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isDefault: json['isDefault'],
      address: json['address'],
      phone: json['phone'],
      addressType: json['addressType'],
      createdDate: DateTime.parse(json['created_date']),
      modifiedDate: DateTime.parse(json['modified_date']),
      userId: json['user'],
    );
  }
}