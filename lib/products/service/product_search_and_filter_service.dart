import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../base/res/base_url.dart';

class ApiService {
  static const String _baseUrl = baseUrl; 
  
  // Search products by text
  static Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/search/').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get search suggestions
  static Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/search/suggestions/').replace(
        queryParameters: {'q': query},
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> suggestions = json.decode(response.body);
        return suggestions.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // Advanced search with filters
  static Future<Map<String, dynamic>> advancedSearch({
    String? query,
    List<String>? brands,
    List<String>? categories,
    String? gender,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? colors,
    List<String>? sizes,
    String sortBy = 'Most Recent',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'sort_by': sortBy,
      };
      
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      
      if (brands != null && brands.isNotEmpty) {
        queryParams['brand'] = brands.join(',');
      }
      
      if (categories != null && categories.isNotEmpty) {
        queryParams['category'] = categories.join(',');
      }
      
      if (gender != null && gender != 'All') {
        queryParams['gender'] = gender;
      }
      
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      
      if (minRating != null) {
        queryParams['min_rating'] = minRating.toString();
      }
      
      if (colors != null && colors.isNotEmpty) {
        queryParams['color'] = colors.join(',');
      }
      
      if (sizes != null && sizes.isNotEmpty) {
        queryParams['size'] = sizes.join(',');
      }
      
      final uri = Uri.parse('$_baseUrl/products/search/advanced/').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Filter products (for Flutter filter screen)
  static Future<Map<String, dynamic>> filterProducts({
    String? brand,
    String? gender,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String sortBy = 'Most Recent',
  }) async {
    try {
      Map<String, String> queryParams = {};
      
      if (brand != null && brand != 'All') {
        queryParams['brand'] = brand;
      }
      
      if (gender != null && gender != 'All') {
        queryParams['gender'] = gender;
      }
      
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      
      if (minRating != null) {
        queryParams['min_rating'] = minRating.toString();
      }
      
      queryParams['sort_by'] = sortBy;
      
      final uri = Uri.parse('$_baseUrl/products/filter/').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to filter products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get filter options
  static Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/filter/options/'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get filter options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}