import '../../products/models/product_model.dart';
class CartModel {
  int? id;
  ProductModel? product;
  int? quantity;
  String? size;
  String? color;

  CartModel({this.id, this.product, this.quantity, this.size, this.color});

   CartModel copyWith({
    int? id,
    ProductModel? product,
    int? quantity,
    String? size,
    String? color,
  }) {
    return CartModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product =
        json['product'] != null ? new ProductModel.fromJson(json['product']) : null;
    quantity = json['quantity'];
    size = json['size'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['quantity'] = this.quantity;
    data['size'] = this.size;
    data['color'] = this.color;
    return data;
  }

  
}




class Product {
  int? id;
  Category? category;
  Brand? brand;
  List<String>? colors;
  List<String>? sizes;
  List<Images>? images;
  String? title;
  String? slug;
  String? description;
  int? stock;
  bool? isFeatured;
  bool? isAvailable;
  String? originalPrice;
  String? discountPrice;
  double? rating;
  String? productType;
  List<String>? imageUrls;
  String? createdDate;
  String? modifiedDate;

  Product(
      {this.id,
      this.category,
      this.brand,
      this.colors,
      this.sizes,
      this.images,
      this.title,
      this.slug,
      this.description,
      this.stock,
      this.isFeatured,
      this.isAvailable,
      this.originalPrice,
      this.discountPrice,
      this.rating,
      this.productType,
      this.imageUrls,
      this.createdDate,
      this.modifiedDate});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    brand = json['brand'] != null ? new Brand.fromJson(json['brand']) : null;
    colors = json['colors'].cast<String>();
    sizes = json['sizes'].cast<String>();
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    stock = json['stock'];
    isFeatured = json['is_featured'];
    isAvailable = json['is_available'];
    originalPrice = json['original_price'];
    discountPrice = json['discount_price'];
    rating = json['rating'];
    productType = json['product_type'];
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
    data['colors'] = this.colors;
    data['sizes'] = this.sizes;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['stock'] = this.stock;
    data['is_featured'] = this.isFeatured;
    data['is_available'] = this.isAvailable;
    data['original_price'] = this.originalPrice;
    data['discount_price'] = this.discountPrice;
    data['rating'] = this.rating;
    data['product_type'] = this.productType;
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

class Images {
  String? image;

  Images({this.image});

  Images.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    return data;
  }
}