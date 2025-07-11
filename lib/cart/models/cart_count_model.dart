class CartCountModel {
  int? cartCountModel;

  CartCountModel({this.cartCountModel});

  CartCountModel.fromJson(Map<String, dynamic> json) {
    cartCountModel = json['cart_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_count'] = this.cartCountModel;
    return data;
  }
}