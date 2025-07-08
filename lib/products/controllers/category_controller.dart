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

// Get products by category (if you have category filtering)
  // Future<void> getProductsByCategory(String categoryId) async {
  //   isLoad.value = true;
  //   update();
    
  //   try {
  //     final data = await MyRequest('products/category/$categoryId', {}, false).getApi();
  //     if (data == null) {
  //       isLoad.value = false;
  //       update();
  //       return;
  //     }

  //     final decoded = jsonDecode(data);
  //     if (decoded is List) {
  //       final productList = decoded
  //           .whereType<Map<String, dynamic>>()
  //           .map((item) => ProductModel.fromJson(item))
  //           .toList();
        
  //       allProducts.value = productList;
  //       applyFilter(selectedFilterIndex.value);
        
  //     } else {
  //       print("Expected a list but got: ${decoded.runtimeType}");
  //     }
  //   } catch (e) {
  //     print("Error fetching products by category: $e");
  //   } finally {
  //     isLoad.value = false;
  //     update();
  //   }
  // }

  // // Clear filters
  // void clearFilters() {
  //   selectedFilterIndex.value = 0;
  //   products.value = allProducts.value;
  //   update();
  // }