import '../../products/models/product_model.dart';
class CartModel {
  int? id;
  ProductModel? product;
  int? quantity;
  String? size;
  String? color;

  CartModel({this.id, this.product, this.quantity, this.size, this.color});

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