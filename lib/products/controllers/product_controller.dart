import 'dart:convert';

import 'package:ecom_app/base/utils/my_request.dart';
import 'package:get/get.dart';

import '../hooks/product_service.dart';
import '../models/product_model.dart';

class ProductsController extends GetxController {
  // Singleton instance
  static ProductsController get instance {
    return Get.find<ProductsController>();
  }

  // Filter service instance
  final ProductFilterService _filterService = ProductFilterService();

  // Observable variables
  var isLoad = false.obs;
  var products = <ProductModel>[].obs;
  var allProducts = <ProductModel>[].obs; // Store all products without filter
  var selectedFilterIndex = 0.obs;

  // Get filtered products
  List<ProductModel> get filteredProducts => products.value;

  @override
  void onInit() {
    super.onInit();
    getProduct();
  }


Future<void> getProduct() async {
    isLoad.value = true;
    update();
        
    try {
      final data = await MyRequest('products/', {}, false).getApi();
      if (data == null) {
        isLoad.value = false;
        update();
        return;
      }

      final decoded = jsonDecode(data);
      
      // Handle paginated response
      if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
        final results = decoded['results'];
        
        if (results is List) {
          final productList = results
              .whereType<Map<String, dynamic>>() // filters only maps
              .map((item) => ProductModel.fromJson(item))
              .toList();
                
          // Store all products and apply current filter
          allProducts.value = productList;
          applyFilter(selectedFilterIndex.value);
        } else {
          print("Expected results to be a list but got: ${results.runtimeType}");
        }
      } else if (decoded is List) {
        // Handle direct array response (fallback)
        final productList = decoded
            .whereType<Map<String, dynamic>>() // filters only maps
            .map((item) => ProductModel.fromJson(item))
            .toList();
                
        // Store all products and apply current filter
        allProducts.value = productList;
        applyFilter(selectedFilterIndex.value);
      } else {
        print("Expected a paginated response or list but got: ${decoded.runtimeType}");
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoad.value = false;
      update();
    }
  }

  // Apply filter based on selected index
  void applyFilter(int filterIndex) {
    selectedFilterIndex.value = filterIndex;
    products.value = _filterService.filterProductsByIndex(
      allProducts.value, 
      filterIndex
    );
    update();
  }

  // Filter by type (alternative method)
  void filterByType(FilterType filterType) {
    products.value = _filterService.filterProducts(
      allProducts.value, 
      filterType
    );
    update();
  }

  // Get filter description
  String getFilterDescription() {
    return _filterService.getFilterDescription(selectedFilterIndex.value);
  }

  // Get filter name
  String getFilterName() {
    return _filterService.getFilterName(selectedFilterIndex.value);
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await getProduct();
  }

  // Search products
  void searchProducts(String query) {
    if (query.isEmpty) {
      applyFilter(selectedFilterIndex.value);
      return;
    }

    products.value = allProducts.value.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    update();
  }
}

  