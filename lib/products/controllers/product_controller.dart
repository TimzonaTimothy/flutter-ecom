
import 'dart:convert';
import 'dart:developer';

import 'package:ecom_app/base/utils/my_request.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../../base/bottom_nav_bar.dart';
import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../../base/utils/token.dart';
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
    final data =
        await MyRequest('products/').getApi();
        if(data ==null){
          isLoad = false.obs; 
          update();
          return;
        }

        products.value = (jsonDecode(data) as List)
        .map((item) => ProductModel.fromJson(item))
        .toList();
        
    isLoad.value = false;
    update();
  }
}
