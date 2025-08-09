import '../../base/res/base_url.dart';

const String _baseUrl = baseUrl;

class ProductSearchModel {
  final int id;
  final String title;
  final String slug;
  final double originalPrice;
  final double? discountPrice;
  final double rating;
  final String? productType;
  final int stock;
  final bool isAvailable;
  final CategorySearchModel category;
  final BrandSearchModel brand;
  final List<String> colors;
  final List<String> sizes;
  final String? image;

  ProductSearchModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.originalPrice,
    this.discountPrice,
    required this.rating,
    this.productType,
    required this.stock,
    required this.isAvailable,
    required this.category,
    required this.brand,
    required this.colors,
    required this.sizes,
    this.image,
  });

  factory ProductSearchModel.fromJson(Map<String, dynamic> json) {
    // Select the first image from imageUrls or fall back to a default
    final imageUrls = json['imageUrls'] as List<dynamic>?;
    String? image;
    if (imageUrls != null && imageUrls.isNotEmpty) {
      image = imageUrls[0] as String;
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      // Optionally use the first image from the images field, prepending the base URL
      image = '$baseUrl${json['images'][0]['image']}';
    }

    return ProductSearchModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      originalPrice: double.parse(json['original_price'].toString()),
      discountPrice: json['discount_price'] != null
          ? double.parse(json['discount_price'].toString())
          : null,
      rating: double.parse(json['rating'].toString()),
      productType: json['product_type'],
      stock: json['stock'],
      isAvailable: json['is_available'],
      category: CategorySearchModel.fromJson(json['category']),
      brand: BrandSearchModel.fromJson(json['brand']),
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      image: image,
    );
  }
}

class CategorySearchModel {
  final int id;
  final String title;
  final String slug;
  final String? image;

  CategorySearchModel({
    required this.id,
    required this.title,
    required this.slug,
    this.image,
  });

  factory CategorySearchModel.fromJson(Map<String, dynamic> json) {
    return CategorySearchModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'image': image,
    };
  }
}

class BrandSearchModel {
  final int id;
  final String title;
  final String slug;

  BrandSearchModel({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory BrandSearchModel.fromJson(Map<String, dynamic> json) {
    return BrandSearchModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
    };
  }
}

class FilterOptions {
  final List<BrandSearchModel> brands;
  final List<CategorySearchModel> categories;
  final List<String> colors;
  final List<String> sizes;
  final List<String> productTypes;
  final Map<String, double?> priceRange;
  final Map<String, double?> ratingRange;
  final List<String> sortOptions;

  FilterOptions({
    required this.brands,
    required this.categories,
    required this.colors,
    required this.sizes,
    required this.productTypes,
    required this.priceRange,
    required this.ratingRange,
    required this.sortOptions,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    print('Using updated FilterOptions.fromJson');
    print('Parsing colors: ${json['colors']}'); // Debug
    print('Parsing sizes: ${json['sizes']}'); // Debug
    return FilterOptions(
      brands: List<BrandSearchModel>.from(
          json['brands']?.map((b) => BrandSearchModel.fromJson(b)) ?? []),
      categories: List<CategorySearchModel>.from(
          json['categories']?.map((c) => CategorySearchModel.fromJson(c)) ??
              []),
      colors: List<String>.from(
        (json['colors'] as List<dynamic>?)
                ?.map(
                    (c) => (c as Map<String, dynamic>)['name'] as String? ?? '')
                .where((name) => name.isNotEmpty) ??
            [],
      ),
      sizes: List<String>.from(
        (json['sizes'] as List<dynamic>?)
                ?.map(
                    (s) => (s as Map<String, dynamic>)['name'] as String? ?? '')
                .where((name) => name.isNotEmpty) ??
            [],
      ),
      productTypes: List<String>.from(json['product_types'] ?? []),
      priceRange: {
        'min': json['price_range']?['min_price']?.toDouble() ?? 0.0,
        'max': json['price_range']?['max_price']?.toDouble() ?? 1000.0,
      },
      ratingRange: {
        'min': json['rating_range']?['min_rating']?.toDouble() ?? 0.0,
        'max': json['rating_range']?['max_rating']?.toDouble() ?? 5.0,
      },
      // sortOptions: List<String>.from(json['sort_options'] ?? []),
      sortOptions: List<String>.from((json['sort_options'] ?? [])
          .where((item) => item != null)
          .cast<String>()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brands': brands.map((b) => b.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'colors': colors.map((c) => {'name': c}).toList(),
      'sizes': sizes.map((s) => {'name': s}).toList(),
      'product_types': productTypes,
      'price_range': {
        'min_price': priceRange['min'],
        'max_price': priceRange['max'],
      },
      'rating_range': {
        'min_rating': ratingRange['min'],
        'max_rating': ratingRange['max'],
      },
      'sort_options': sortOptions,
    };
  }
}
