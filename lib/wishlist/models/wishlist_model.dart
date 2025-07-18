class WishlistModel {
  int? id;
  Category? category;
  Brand? brand;
  String? title;
  String? slug;
  String? description;
  int? stock;
  bool? isFeatured;
  int? discountPrice;
  int? originalPrice;
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
    discountPrice = json['discount_price'];
    originalPrice = json['original_price'];
    isAvailable = json['is_available'];
    rating = json['rating'];
    productType = json['product_type'];
    colors = json['colors'].cast<String>();
    sizes = json['sizes'].cast<String>();
    imageUrls = json['imageUrls'].cast<String>();
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.brand != null) {
      data['brand'] = this.brand!.toJson();
    }
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['stock'] = this.stock;
    data['is_featured'] = this.isFeatured;
    data['discount_price'] = this.discountPrice;
    data['original_price'] = this.originalPrice;
    data['is_available'] = this.isAvailable;
    data['rating'] = this.rating;
    data['product_type'] = this.productType;
    data['colors'] = this.colors;
    data['sizes'] = this.sizes;
    data['imageUrls'] = this.imageUrls;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['image'] = this.image;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    return data;
  }
}

