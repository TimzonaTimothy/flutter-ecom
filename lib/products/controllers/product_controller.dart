import 'dart:convert';

import 'package:ecom_app/base/utils/my_request.dart';
import 'package:get/get.dart';

import '../models/product_model.dart';

class ProductsController extends GetxController {
  var isLoad = false.obs;
  static ProductsController get instance {
    return Get.find<ProductsController>();
  }

  var products = <ProductModel>[].obs;

  Future<void> getProduct() async {
    isLoad.value = true;
    update();
    final data = await MyRequest('products/', {}, false).getApi();
    if (data == null) {
      isLoad = false.obs;
      update();
      return;
    }

    final decoded = jsonDecode(data);
if (decoded is List) {
  products.value = decoded
      .whereType<Map<String, dynamic>>() // filters only maps
      .map((item) => ProductModel.fromJson(item))
      .toList();
} else {
  print("Expected a list but got: ${decoded.runtimeType}");
}

    isLoad.value = false;
    update();
  }
}
