class CreateCartModel {
  int? product;
  int? quantity;
  String? color;
  String? size;

  CreateCartModel({this.product, this.quantity, this.color, this.size});

  CreateCartModel.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    quantity = json['quantity'];
    color = json['color'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product'] = this.product;
    data['quantity'] = this.quantity;
    data['color'] = this.color;
    data['size'] = this.size;
    return data;
  }
}