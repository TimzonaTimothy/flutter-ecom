import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ecom_app/onboarding/views/welcome_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/res/base_url.dart';
import '../../base/utils/snackbar.dart';
import '../views/sign_in.dart';

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

class AuthService extends GetxController {
  static AuthService get instance => Get.find<AuthService>();

  Timer? _tokenRefreshTimer;
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxBool _isInitialized = false.obs;

  bool get isAuthenticated => _isAuthenticated.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onClose() {
    _tokenRefreshTimer?.cancel();
    super.onClose();
  }

  Future<void> checkAuthenticationStatus() async {
    if (_isInitialized.value) return; // Already initialized

    await _initializeAuth();
    _isInitialized.value = true;
  }

  // Initialize authentication
  Future<void> _initializeAuth() async {
    try {
      final token = await getToken();
      final rememberMe = await getRememberMe();

      if (token != null) {
        if (rememberMe) {
          // If remember me is enabled, try to refresh token
          final isValid = await _verifyAndRefreshToken();
          _isAuthenticated.value = isValid;
          if (isValid) {
            _startTokenRefreshTimer();
          }
        } else {
          // If remember me is disabled, verify token without refresh
          final isValid = await verifyTokenOnly();
          if (isValid) {
            _isAuthenticated.value = true;
            _startTokenRefreshTimer();
          } else {
            await removeTokens();
          }
        }
      }
    } catch (e) {
      log('Error initializing auth: $e');
      _isAuthenticated.value = false;
    }
  }

  // Force refresh authentication status (useful for logout, etc.)
  Future<void> refreshAuthStatus() async {
    _isInitialized.value = false;
    await checkAuthenticationStatus();
    update(); // Notify GetBuilder widgets
  }

  // ============================================================================
  // TOKEN STORAGE METHODS
  // ============================================================================

  Future<void> saveTokens(String accessToken, String refreshToken,
      {bool rememberMe = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setBool('remember_me', rememberMe);

    // Set token expiry time (50 minutes from now to refresh before expiry)
    final expiryTime = DateTime.now().add(const Duration(minutes: 50));
    await prefs.setString('token_expiry', expiryTime.toIso8601String());

    _isAuthenticated.value = true;
    _startTokenRefreshTimer();

    log('Tokens saved successfully. Remember me: $rememberMe');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString('token_expiry');
    return expiryString != null ? DateTime.parse(expiryString) : null;
  }

  Future<void> removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('remember_me');
    await prefs.remove('token_expiry');
    await prefs.remove('user_id');

    _isAuthenticated.value = false;
    _tokenRefreshTimer?.cancel();

    Get.offAll(() => const WelcomeScreen());

    update();
  }

  Future<void> handleSuccessfulLogin(String accessToken, String refreshToken,
      {bool rememberMe = false}) async {
    await saveTokens(accessToken, refreshToken, rememberMe: rememberMe);
    _isAuthenticated.value = true;
    update(); // Notify GetBuilder widgets
  }

  // ============================================================================
  // TOKEN REFRESH SYSTEM
  // ============================================================================

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    // Calculate time until token refresh (refresh 5 minutes before expiry)
    const refreshInterval = Duration(minutes: 55);

    _tokenRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      if (!_isRefreshing.value) {
        await _refreshTokenIfNeeded();
      }
    });
  }

  Future<void> _refreshTokenIfNeeded() async {
    final expiry = await getTokenExpiry();
    if (expiry != null &&
        DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 10)))) {
      await refreshAccessToken();
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_isRefreshing.value) return false;

    _isRefreshing.value = true;

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        log('No refresh token found');
        await removeTokens();
        return false;
      }

      final url = Uri.parse('$baseURLGeneral/auth/jwt/refresh/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        final newRefreshToken = data['refresh'] ??
            refreshToken; // Use new refresh token if provided

        final rememberMe = await getRememberMe();
        await saveTokens(newAccessToken, newRefreshToken,
            rememberMe: rememberMe);

        log('Token refreshed successfully');
        return true;
      } else {
        log('Token refresh failed: ${response.body}');
        await removeTokens();
        showFailureSnackbar('Session expired. Please log in again.');
        return false;
      }
    } catch (e) {
      log('Error refreshing token: $e');
      await removeTokens();
      showFailureSnackbar('Session expired. Please log in again.');
      return false;
    } finally {
      _isRefreshing.value = false;
    }
  }

  // ============================================================================
  // TOKEN VERIFICATION
  // ============================================================================

  Future<bool> verifyTokenOnly() async {
    final token = await getToken();

    if (token == null) {
      Get.offAll(() => const WelcomeScreen());

      return false;
    }

    final url = Uri.parse('$baseURLGeneral/auth/jwt/verify/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      log("Token verification error: $e");
      return false;
    }
  }

  Future<bool> _verifyAndRefreshToken() async {
    // First try to verify current token
    if (await verifyTokenOnly()) {
      return true;
    }

    // If verification fails, try to refresh
    return await refreshAccessToken();
  }

  // ============================================================================
  // HTTP HEADERS
  // ============================================================================

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
