class WishlistModel {
  int? id;
  Category? category;
  Brand? brand;
  String? title;
  String? slug;
  String? description;
  int? stock;
  bool? isFeatured;
  String? discountPrice; 
  String? originalPrice;
  bool? isAvailable;
  double? rating;
  String? productType;
  List<String>? colors;
  List<String>? sizes;
  List<String>? imageUrls;
  String? createdDate;
  String? modifiedDate;

  WishlistModel(
      {this.id,
      this.category,
      this.brand,
      this.title,
      this.slug,
      this.description,
      this.stock,
      this.isFeatured,
      this.discountPrice,
      this.originalPrice,
      this.isAvailable,
      this.rating,
      this.productType,
      this.colors,
      this.sizes,
      this.imageUrls,
      this.createdDate,
      this.modifiedDate});

  WishlistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    brand = json['brand'] != null ? new Brand.fromJson(json['brand']) : null;
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    stock = json['stock'];
    isFeatured = json['is_featured'];
    discountPrice = json['discount_price']?.toString(); 
    originalPrice = json['original_price']?.toString();
    isAvailable = json['is_available'];
    rating = json['rating']?.toDouble();
    productType = json['product_type']?.toString().trim().toLowerCase();
    colors = json['colors'] != null 
        ? List<String>.from(json['colors'].map((x) => x.toString()))
        : null;
    sizes = json['sizes'] != null 
        ? List<String>.from(json['sizes'].map((x) => x.toString()))
        : null;
    imageUrls = json['imageUrls'] != null 
        ? List<String>.from(json['imageUrls'].map((x) => x.toString()))
        : null;
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['stock'] = stock;
    data['is_featured'] = isFeatured;
    data['discount_price'] = discountPrice;
    data['original_price'] = originalPrice;
    data['is_available'] = isAvailable;
    data['rating'] = rating;
    data['product_type'] = productType;
    data['colors'] = colors;
    data['sizes'] = sizes;
    data['imageUrls'] = imageUrls;
    data['created_date'] = createdDate;
    data['modified_date'] = modifiedDate;
    return data;
  }
}

class Category {
  int? id;
  String? title;
  String? slug;
  String? image;

  Category({this.id, this.title, this.slug, this.image});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['image'] = image;
    return data;
  }
}

class Brand {
  int? id;
  String? title;
  String? slug;

  Brand({this.id, this.title, this.slug});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    return data;
  }
}