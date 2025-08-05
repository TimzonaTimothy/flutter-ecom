import 'package:http/http.dart' as http;

import 'auth_service.dart';


class AuthHttpClient {
  static final AuthHttpClient _instance = AuthHttpClient._internal();
  factory AuthHttpClient() => _instance;
  AuthHttpClient._internal();

  static AuthHttpClient get instance => _instance;

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return await _makeRequest(() => http.get(Uri.parse(url), headers: headers));
  }

  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    return await _makeRequest(() => http.post(Uri.parse(url), headers: headers, body: body));
  }

  Future<http.Response> put(String url, {Map<String, String>? headers, Object? body}) async {
    return await _makeRequest(() => http.put(Uri.parse(url), headers: headers, body: body));
  }

  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    return await _makeRequest(() => http.delete(Uri.parse(url), headers: headers));
  }

  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    try {
      // Make the initial request
      var response = await request();
      
      // If token is expired (401), try to refresh and retry
      if (response.statusCode == 401 && AuthService.instance.isAuthenticated) {
        print('Token expired, attempting refresh...');
        
        final refreshSuccess = await AuthService.instance.refreshAccessToken();
        if (refreshSuccess) {
          // Retry the request with new token
          response = await request();
        }
      }
      
      return response;
    } catch (e) {
      print('HTTP request error: $e');
      rethrow;
    }
  }
}