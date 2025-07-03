import 'dart:convert';

import 'package:ecom_app/base/utils/my_request.dart';
import 'package:get/get.dart';

import '../../base/utils/snackbar.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;
  static CategoryController get instance {
    return Get.find<CategoryController>();
  }

  var categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    isLoading.value = true;

    final response = await MyRequest('products/categories/', {}, false)
        .init(showToast: true)
        .getApi();

    if (response != null) {
      try {
        final List data = jsonDecode(response);
        
        categories.value = data.map((e) => CategoryModel.fromJson(e)).toList();
      } catch (e) {
        showFailureSnackbar('Failed to parse category data');
      }
    }

    isLoading.value = false;
  }
}
