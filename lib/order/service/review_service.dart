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
  }) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/submit-review/$productId/');
      
      final body = jsonEncode({
        'subject': subject,
        'review': review,
        'rating': rating,
      });

      log('Submitting review to: $url');
      log('Request body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      log('Review submission response: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        log('Failed to submit review: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error submitting review: $e');
      return null;
    }
  }

  static Future<List<ReviewModel>?> getProductReviews(int productId) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/products/$productId/reviews/');
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        log('Failed to get reviews: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error getting reviews: $e');
      return null;
    }
  }

  static Future<ReviewModel?> getUserReviewForProduct(int productId) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final url = Uri.parse('$_baseUrl/user-review/$productId/');
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // No existing review found
        return null;
      } else {
        log('Failed to get user review: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error getting user review: $e');
      return null;
    }
  }
}