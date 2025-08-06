import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../base/res/base_url.dart';
import '../../auth/service/auth_service.dart';
import '../models/review_model.dart';

class ReviewService {
  static const String _baseUrl = baseUrl;

  static Future<Map<String, dynamic>?> submitReview({
    required int productId,
    required String subject,
    required String review,
    required double rating,
    required bool isUpdate,
  }) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/products/submit-review/$productId/');
      
      final body = jsonEncode({
        'subject': subject,
        'review': review,
        'rating': rating,
      });

      log('Submitting review to: $url', name: 'ReviewService');
      log('Request body: $body', name: 'ReviewService');

      final response = isUpdate
          ? await http.patch(url, headers: headers, body: body)
          : await http.post(url, headers: headers, body: body);

      log('Review submission response: ${response.statusCode}', name: 'ReviewService');
      log('Response body: ${response.body}', name: 'ReviewService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log('Failed to submit review: ${response.body}', name: 'ReviewService');
        return null;
      }
    } catch (e) {
      log('Error submitting review: $e', name: 'ReviewService');
      return null;
    }
  }

  static Future<List<ReviewModel>?> getProductReviews(int productId) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/products/$productId/reviews/');
      
      final response = await http.get(url, headers: headers);

      log('Get reviews response: ${response.statusCode}', name: 'ReviewService');
      log('Response body: ${response.body}', name: 'ReviewService');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          log('No reviews found for product $productId', name: 'ReviewService');
          return [];
        }
        final reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
        log('Parsed reviews: $reviews', name: 'ReviewService');
        return reviews;
      } else {
        log('Failed to get reviews: ${response.body}', name: 'ReviewService');
        return null;
      }
    } catch (e) {
      log('Error getting reviews: $e', name: 'ReviewService');
      return null;
    }
  }

  static Future<ReviewModel?> getUserReviewForProduct(int productId) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/products/user-review/$productId/');
      
      final response = await http.get(url, headers: headers);

      log('Get user review response: ${response.statusCode}', name: 'ReviewService');
      log('Response body: ${response.body}', name: 'ReviewService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('User review data: $data', name: 'ReviewService');
        return ReviewModel.fromJson(data);
      } else if (response.statusCode == 404) {
        log('No review found for product $productId', name: 'ReviewService');
        return null;
      } else {
        log('Failed to get user review: ${response.body}', name: 'ReviewService');
        return null;
      }
    } catch (e) {
      log('Error getting user review: $e', name: 'ReviewService');
      return null;
    }
  }
}