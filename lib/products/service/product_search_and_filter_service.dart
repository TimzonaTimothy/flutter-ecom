import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../base/res/base_url.dart';

class SearchAndFilterApiService {
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
      print('Search response: ${response.body}');
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
  const maxRetries = 3;
  const retryDelay = Duration(seconds: 2);
  int attempt = 0;

  while (attempt < maxRetries) {
    try {
      final uri = Uri.parse('$_baseUrl/products/filter/options/');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      print('Raw filter options response: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('Parsed filter options JSON: $jsonResponse');
      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        throw Exception('Failed to get filter options: ${response.statusCode}');
      }
    } catch (e) {
      attempt++;
      print('Filter options attempt $attempt failed: $e');
      if (attempt == maxRetries) {
        throw Exception('Network error after $maxRetries attempts: $e');
      }
      await Future.delayed(retryDelay);
    }
  }
  throw Exception('Failed to get filter options after $maxRetries attempts');
}
}