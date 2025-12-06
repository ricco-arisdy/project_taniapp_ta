import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Save token with expiry time
  static Future<void> saveAuthData({
    required String token,
    required bool rememberMe,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    await prefs.setString(AppConstants.tokenKey, token);

    // Save token creation time
    final now = DateTime.now();
    await prefs.setString('token_created_at', now.toIso8601String());

    // Calculate expiry time 1 jam
    final expiryTime = now.add(const Duration(hours: 24));
    await prefs.setString('token_expires_at', expiryTime.toIso8601String());

    await prefs.setBool(AppConstants.rememberMeKey, rememberMe);
    await prefs.setBool(AppConstants.isLoggedInKey, true);

    if (userId != null) {
      await prefs.setString(AppConstants.userDataKey, userId);
    }

    print(
      '🔐 [SHARED_PREFS] Token saved with expiry: ${expiryTime.toIso8601String()}',
    );
    print('🔐 [SHARED_PREFS] Token will expire in 24 hours (86400 seconds)');
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString('token_expires_at');

      if (expiryString == null) {
        print('⚠️ [SHARED_PREFS] No expiry time found');
        return true;
      }

      final expiryTime = DateTime.parse(expiryString);
      final now = DateTime.now();

      final isExpired = now.isAfter(expiryTime);

      if (isExpired) {
        print(
          '❌ [SHARED_PREFS] Token expired at: ${expiryTime.toIso8601String()}',
        );
        print('❌ [SHARED_PREFS] Current time: ${now.toIso8601String()}');
        final diff = now.difference(expiryTime);
        print('❌ [SHARED_PREFS] Expired ${diff.inMinutes} minutes ago');
      } else {
        final remainingSeconds = expiryTime.difference(now).inSeconds;
        final remainingHours = (remainingSeconds / 3600).floor();
        final remainingMinutes = ((remainingSeconds % 3600) / 60).floor();
        print(
          '✅ [SHARED_PREFS] Token valid for ${remainingHours}h ${remainingMinutes}m',
        );
      }

      return isExpired;
    } catch (e) {
      print('💥 [SHARED_PREFS] Error checking token expiry: $e');
      return true;
    }
  }

  // Get remaining token validity time
  static Future<Duration?> getTokenRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString('token_expires_at');

      if (expiryString == null) return null;

      final expiryTime = DateTime.parse(expiryString);
      final now = DateTime.now();

      if (now.isAfter(expiryTime)) return Duration.zero;

      return expiryTime.difference(now);
    } catch (e) {
      print('💥 [SHARED_PREFS] Error getting remaining time: $e');
      return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.rememberMeKey) ?? false;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userDataKey);
  }

  // Check login with token expiry
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
      final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
      final token = prefs.getString(AppConstants.tokenKey);

      // Check token expiry
      final isExpired = await isTokenExpired();

      if (isExpired) {
        print('❌ [SHARED_PREFS] Token expired, clearing auth data');
        await clearAuthData();
        return false;
      }

      return isLoggedIn && rememberMe && (token != null && token.isNotEmpty);
    } catch (e) {
      print('💥 [SHARED_PREFS] Error checking login status: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(AppConstants.savedEmailKey) ?? '',
      'password': prefs.getString(AppConstants.savedPasswordKey) ?? '',
      'rememberMe': prefs.getBool(AppConstants.rememberMeKey) ?? false,
    };
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.remove('token_created_at');
    await prefs.remove('token_expires_at');
    await prefs.remove('last_activity_time');
    await prefs.setBool(AppConstants.isLoggedInKey, false);
    print('🔓 [SHARED_PREFS] Auth data cleared');
  }

  static Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.savedEmailKey);
    await prefs.remove(AppConstants.savedPasswordKey);
    await prefs.setBool(AppConstants.rememberMeKey, false);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
