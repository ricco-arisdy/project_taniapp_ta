import 'dart:convert';

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/http_service.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';

class ProfileUpdateService {
  Future<ApiResponse<User>> updateProfile(String nama) async {
    try {
      print('🔄 [PROFILE_UPDATE] Updating profile with name: $nama');

      final response = await HttpService.put(
        ApiEndpoints.updateProfile,
        {'nama': nama},
      );

      print('📊 [PROFILE_UPDATE] Response Status: ${response.statusCode}');
      print('📊 [PROFILE_UPDATE] Response Body: ${response.body}');

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success' && jsonData['data'] != null) {
        print('✅ [PROFILE_UPDATE] Profile updated successfully');

        // Extract user and token data
        final responseData = jsonData['data'];
        final userData = responseData['user'];
        final newToken = responseData['token'];
        final tokenType = responseData['token_type'];

        // Create updated user with new token
        final updatedUser = User(
          id: userData['id'],
          nama: userData['nama'],
          email: userData['email'],
          tanggalDibuat: DateTime.parse(userData['tanggal_dibuat']),
          token: newToken,
          tokenType: tokenType,
        );

        // 🔑 IMPORTANT: Update token in storage automatically
        await _updateTokenInStorage(newToken, updatedUser);

        return ApiResponse<User>(
          status: 'success',
          message: jsonData['message'] ?? 'Profil berhasil diperbarui',
          data: updatedUser,
        );
      } else {
        return ApiResponse<User>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal memperbarui profil',
          errorCode: jsonData['error_code'],
        );
      }
    } catch (e) {
      print('💥 [PROFILE_UPDATE] Error: $e');
      return ApiResponse<User>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  Future<void> _updateTokenInStorage(String newToken, User updatedUser) async {
    try {
      print('🔄 [PROFILE_UPDATE] Updating token in storage...');

      // Get current rememberMe setting
      final rememberMe = await SharedPreferencesService.getRememberMe();

      // Save new auth data (this will update the token)
      await SharedPreferencesService.saveAuthData(
        token: newToken,
        rememberMe: rememberMe,
        userId: jsonEncode(updatedUser.toJson()),
      );

      print('✅ [PROFILE_UPDATE] Token updated in storage');
      print('🔑 [PROFILE_UPDATE] New token: ${newToken.substring(0, 20)}...');
    } catch (e) {
      print('💥 [PROFILE_UPDATE] Error updating token in storage: $e');
    }
  }

  Future<ApiResponse<User>> getCurrentProfile() async {
    try {
      print('👤 [PROFILE_UPDATE] Getting current profile...');

      final response = await HttpService.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final userData = jsonData['data'];

          final user = User(
            id: userData['id'],
            nama: userData['nama'],
            email: userData['email'],
            tanggalDibuat: DateTime.parse(userData['tanggal_dibuat']),
          );

          return ApiResponse<User>(
            status: 'success',
            message: 'Profil berhasil dimuat',
            data: user,
          );
        }
      }

      return ApiResponse<User>(
        status: 'error',
        message: 'Gagal memuat profil',
      );
    } catch (e) {
      print('💥 [PROFILE_UPDATE] Error getting profile: $e');
      return ApiResponse<User>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }
}
