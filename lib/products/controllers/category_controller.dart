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

  // void fetchCategories() async {
  //   isLoading.value = true;

  //   final response = await MyRequest('products/categories/', {}, false)
  //       .init(showToast: true)
  //       .getApi();

  //   if (response != null) {
  //     try {
  //       final List data = jsonDecode(response);
        
  //       categories.value = data.map((e) => CategoryModel.fromJson(e)).toList();
  //     } catch (e) {
  //       showFailureSnackbar('Failed to parse category data');
  //     }
  //   }

  //   isLoading.value = false;
  // }

  Future<void> fetchCategories() async {
    isLoading.value = true;

    try {
      final response = await MyRequest('products/categories/', {}, false)
          .init(showToast: true)
          .getApi();

      if (response != null) {
        final decoded = jsonDecode(response);
        
        // Handle paginated response
        if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
          final results = decoded['results'];
          
          if (results is List) {
            categories.value = results
                .whereType<Map<String, dynamic>>()
                .map((e) => CategoryModel.fromJson(e))
                .toList();
          } else {
            print("Expected results to be a list but got: ${results.runtimeType}");
            showFailureSnackbar('Invalid category data format');
          }
        } 
        // Handle direct array response (fallback)
        else if (decoded is List) {
          categories.value = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        } 
        // Handle unexpected response format
        else {
          print("Expected a paginated response or list but got: ${decoded.runtimeType}");
          print("Response data: $decoded");
          showFailureSnackbar('Unexpected response format');
        }
      } else {
        showFailureSnackbar('Failed to fetch categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      showFailureSnackbar('Failed to parse category data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh categories
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  // Method to get category by ID
  CategoryModel? getCategoryById(int id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to get category by slug
  CategoryModel? getCategoryBySlug(String slug) {
    try {
      return categories.firstWhere((category) => category.slug == slug);
    } catch (e) {
      return null;
    }
  }

}