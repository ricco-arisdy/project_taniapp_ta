import 'dart:convert';

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/http_service.dart';

class AuthLoginService {
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      print('🚀 [AUTH] Attempting login for email: $email');

      final response = await HttpService.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      }, withAuth: false);

      print('📊 [AUTH] Raw Response Status: ${response.statusCode}');
      print('📊 [AUTH] Raw Response Body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('📊 [AUTH] Decoded JSON: $jsonData');

      if (jsonData['status'] == 'success') {
        print('📊 [AUTH] Login success, data: ${jsonData['data']}');

        // Debug: Check structure
        print('📊 [AUTH] User data: ${jsonData['data']['user']}');
        print('📊 [AUTH] Token: ${jsonData['data']['token']}');
        print('📊 [AUTH] Token type: ${jsonData['data']['token_type']}');

        // Create proper structure for User.fromJson
        final userDataWithToken = {
          'user': jsonData['data']['user'],
          'token': jsonData['data']['token'],
          'token_type': jsonData['data']['token_type'],
        };

        print('📊 [AUTH] Final user data structure: $userDataWithToken');

        final user = User.fromJson(userDataWithToken);
        print('🎉 [AUTH] User created: $user');
        print('🎉 [AUTH] Token in user: ${user.token}');

        return ApiResponse<User>(
          status: 'success',
          message: jsonData['message'] ?? 'Login berhasil',
          data: user,
        );
      } else {
        print('❌ [AUTH] Login FAILED: ${jsonData['message']}');
        return ApiResponse<User>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Login gagal',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [AUTH] Login error: $e');
      print('📚 [AUTH] Stack trace: $stackTrace');
      return ApiResponse<User>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  // Add method to test token validity
  Future<ApiResponse<bool>> testTokenValidity() async {
    try {
      print('🔐 [AUTH] Testing token validity...');

      final response = await HttpService.get(
        ApiEndpoints.profile,
        withAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          return ApiResponse<bool>(
            status: 'success',
            message: 'Token valid',
            data: true,
          );
        }
      }

      return ApiResponse<bool>(
        status: 'error',
        message: 'Token invalid',
        data: false,
      );
    } catch (e) {
      print('💥 [AUTH] Token test error: $e');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Token test failed',
        data: false,
      );
    }
  }
}
