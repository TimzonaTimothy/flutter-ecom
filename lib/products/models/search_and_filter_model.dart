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
  final String? imagePreview;

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
    this.imagePreview,
  });

  factory ProductSearchModel.fromJson(Map<String, dynamic> json) {
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
      colors: List<String>.from(json['colors'].map((color) => color['name'])),
      sizes: List<String>.from(json['sizes'].map((size) => size['name'])),
      imagePreview: json['image_preview'],
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
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      image: json['image'],
    );
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
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
    );
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
    return FilterOptions(
      brands: List<BrandSearchModel>.from(json['brands'].map((b) => BrandSearchModel.fromJson(b))),
      categories: List<CategorySearchModel>.from(json['categories'].map((c) => CategorySearchModel.fromJson(c))),
      colors: List<String>.from(json['colors'].map((c) => c['name'])),
      sizes: List<String>.from(json['sizes'].map((s) => s['name'])),
      productTypes: List<String>.from(json['product_types']),
      priceRange: {
        'min': json['price_range']['min_price']?.toDouble(),
        'max': json['price_range']['max_price']?.toDouble(),
      },
      ratingRange: {
        'min': json['rating_range']['min_rating']?.toDouble(),
        'max': json['rating_range']['max_rating']?.toDouble(),
      },
      sortOptions: List<String>.from(json['sort_options']),
    );
  }
}