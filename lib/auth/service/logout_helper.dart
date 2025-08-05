import 'auth_service.dart';

class AuthHelpers {
  static Future<void> logout() async {
    await AuthService.instance.removeTokens();
    // AppWrapper will automatically show SignInScreen
  }
  
  static Future<void> forceReauthentication() async {
    await AuthService.instance.refreshAuthStatus();
  }
}