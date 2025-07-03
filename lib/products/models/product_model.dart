class BrandProductModel {
  final int id;
  final String title;

  BrandProductModel({required this.id, required this.title});

  factory BrandProductModel.fromJson(Map<String, dynamic> json) {
    return BrandProductModel(
      id: json['id'],
      title: json['title'],
    );
  }
}

class CategoryProductModel {
  final int id;
  final String title;

  CategoryProductModel({required this.id, required this.title});

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    return CategoryProductModel(
      id: json['id'],
      title: json['title'],
    );
  }
}



class ProductModel {
  final int id;
    final CategoryProductModel category;
  final BrandProductModel brand;
  final String title;
  final String slug;
  final String? description;
  final int stock;
  final bool isFeatured;
  final bool isAvailable;
  final String? originalPrice;
  final String? discountPrice;
  final double rating;
  final String productType;
  final List<String>? colors;
  final List<String>? sizes;
  final List<String>? imageUrls;
  final DateTime createdDate;
  final DateTime modifiedDate;

  ProductModel({
    required this.id,
    required this.category,
    required this.brand,
    required this.title,
    required this.slug,
    this.description,
    required this.stock,
    required this.isFeatured,
    required this.isAvailable,
    this.originalPrice,
    this.discountPrice,
    required this.rating,
    required this.productType,
    this.colors,
    this.sizes,
    this.imageUrls,
    required this.createdDate,
    required this.modifiedDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      category: CategoryProductModel.fromJson(json['category']),
      brand: BrandProductModel.fromJson(json['brand']),
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      stock: json['stock'],
      isFeatured: json['is_featured'],
      isAvailable: json['is_available'],
      originalPrice: json['original_price'],
      discountPrice: json['discount_price'],
      rating: json['rating']?.toDouble() ?? 1.0,
      productType: json['product_type'],
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList(),
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList(),
      imageUrls: (json['imageUrls'] as List?)?.map((e) => e.toString()).toList(),
      createdDate: DateTime.parse(json['created_date']),
      modifiedDate: DateTime.parse(json['modified_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'brand': brand,
      'title': title,
      'slug': slug,
      'description': description,
      'stock': stock,
      'is_featured': isFeatured,
      'is_available': isAvailable,
      'original_price': originalPrice,
      'discount_price': discountPrice,
      'rating': rating,
      'product_type': productType,
      'colors': colors,
      'sizes': sizes,
      'imageUrls': imageUrls,
      'created_date': createdDate.toIso8601String(),
      'modified_date': modifiedDate.toIso8601String(),
    };
  }
}
