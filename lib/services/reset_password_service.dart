import 'dart:convert';

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/reset_password_models.dart';
import 'package:project_taniapp_ta/services/http_service.dart';

class ResetPasswordService {
  /// Request reset password - Send OTP to email
  Future<ApiResponse<OtpResponse>> requestReset(String email) async {
    try {
      print('📧 [RESET_PASSWORD] Requesting reset for email: $email');

      final request = ResetPasswordRequest(email: email);

      final response = await HttpService.post(
        ApiEndpoints.requestReset,
        request.toJson(),
        withAuth: false,
      );

      print('📊 [RESET_PASSWORD] Response status: ${response.statusCode}');
      print('📊 [RESET_PASSWORD] Response body: ${response.body}');

      if (response.body.isEmpty) {
        return ApiResponse<OtpResponse>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        final otpResponse = OtpResponse.fromJson(jsonData['data']);

        print('✅ [RESET_PASSWORD] OTP sent successfully');
        print('📧 [RESET_PASSWORD] Email: ${otpResponse.email}');
        print('⏰ [RESET_PASSWORD] Expires at: ${otpResponse.berakhirPada}');
        print(
          '🔐 [RESET_PASSWORD] OTP Code from backend: ${otpResponse.otpKode}',
        ); // ✅ Debug

        return ApiResponse<OtpResponse>(
          status: 'success',
          message:
              jsonData['message'] ?? 'Kode OTP telah dikirim ke email Anda',
          data: otpResponse,
        );
      } else {
        print('❌ [RESET_PASSWORD] Request failed: ${jsonData['message']}');
        // ✅ Handle rate limit error specifically
        if (jsonData['error_code'] == 'RATE_LIMIT_EXCEEDED') {
          print('⏱️ [RESET_PASSWORD] Rate limit exceeded');

          // Extract cooldown info if available
          int? sisaDetik;
          if (jsonData['data'] != null &&
              jsonData['data']['sisa_detik'] != null) {
            sisaDetik = jsonData['data']['sisa_detik'];
          }

          return ApiResponse<OtpResponse>(
            status: jsonData['status'] ?? 'error',
            message: jsonData['message'],
            errorCode: 'RATE_LIMIT_EXCEEDED',
          );
        }
        return ApiResponse<OtpResponse>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal mengirim kode OTP',
          errorCode: jsonData['error_code'],
        );
      }
    } catch (e, stackTrace) {
      print('💥 [RESET_PASSWORD] Request error: $e');
      print('📚 [RESET_PASSWORD] Stack trace: $stackTrace');
      return ApiResponse<OtpResponse>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
      );
    }
  }

  /// Verify OTP code
  Future<ApiResponse<bool>> verifyOtp(String email, String otpKode) async {
    try {
      final cleanedOtp = otpKode.trim().replaceAll(RegExp(r'\s+'), '');
      print('🔐 [VERIFY_OTP] ========== START VERIFICATION ==========');
      print('🔐 [VERIFY_OTP] Email: $email');
      print('🔐 [VERIFY_OTP] OTP Code entered: $otpKode');
      print('🔐 [VERIFY_OTP] OTP Length: ${otpKode.length}');
      print('🔐 [VERIFY_OTP] OTP Type: ${otpKode.runtimeType}');

      // final request = VerifyOtpRequest(email: email, otpKode: otpKode);
      // Validate OTP length before sending
      if (cleanedOtp.length != 6) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Kode OTP harus 6 digit',
          data: false,
        );
      }

      // Validate only digits
      if (!RegExp(r'^\d{6}$').hasMatch(cleanedOtp)) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Kode OTP harus berisi angka saja',
          data: false,
        );
      }

      final request = VerifyOtpRequest(email: email, otpKode: cleanedOtp);

      print('🔐 [VERIFY_OTP] Request JSON: ${json.encode(request.toJson())}');

      final response = await HttpService.post(
        ApiEndpoints.verifyOtp,
        request.toJson(),
        withAuth: false,
      );

      print(
        '📊 [RESET_PASSWORD] Verify response status: ${response.statusCode}',
      );
      print('📊 [RESET_PASSWORD] Verify response body: ${response.body}');

      if (response.body.isEmpty) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      print('📊 [VERIFY_OTP] Parsed JSON status: ${jsonData['status']}');
      print('📊 [VERIFY_OTP] Parsed JSON message: ${jsonData['message']}');

      if (jsonData['status'] == 'success') {
        print('✅ [RESET_PASSWORD] OTP verified successfully');

        return ApiResponse<bool>(
          status: 'success',
          message: jsonData['message'] ?? 'Kode OTP valid',
          data: true,
        );
      } else {
        print('❌ [VERIFY_OTP] OTP verification failed: ${jsonData['message']}');
        print('❌ [VERIFY_OTP] Error code: ${jsonData['error_code']}');

        // Extract remaining attempts info
        String errorMessage = jsonData['message'] ?? 'Kode OTP tidak valid';

        // Check if data contains remaining attempts
        if (jsonData['data'] != null &&
            jsonData['data']['sisa_percobaan'] != null) {
          final sisaPercobaan = jsonData['data']['sisa_percobaan'];
          errorMessage = 'Kode OTP salah. Sisa percobaan: $sisaPercobaan kali';
        }

        return ApiResponse<bool>(
          status: jsonData['status'] ?? 'error',
          message: errorMessage,
          errorCode: jsonData['error_code'],
          data: false,
        );
      }
    } catch (e, stackTrace) {
      print('💥 [RESET_PASSWORD] Verify error: $e');
      print('📚 [RESET_PASSWORD] Stack trace: $stackTrace');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
        data: false,
      );
    }
  }

  /// Reset password with verified OTP
  Future<ApiResponse<bool>> resetPassword(
    String email,
    String otpKode,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      print('🔒 [RESET_PASSWORD] Resetting password for email: $email');

      final request = ResetPasswordData(
        email: email,
        otpKode: otpKode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await HttpService.post(
        ApiEndpoints.resetPassword,
        request.toJson(),
        withAuth: false,
      );

      print(
        '📊 [RESET_PASSWORD] Reset response status: ${response.statusCode}',
      );
      print('📊 [RESET_PASSWORD] Reset response body: ${response.body}');

      if (response.body.isEmpty) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Server tidak memberikan response',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        print('✅ [RESET_PASSWORD] Password reset successfully');

        return ApiResponse<bool>(
          status: 'success',
          message: jsonData['message'] ?? 'Password berhasil direset',
          data: true,
        );
      } else {
        print(
          '❌ [RESET_PASSWORD] Password reset failed: ${jsonData['message']}',
        );
        return ApiResponse<bool>(
          status: jsonData['status'] ?? 'error',
          message: jsonData['message'] ?? 'Gagal mereset password',
          errorCode: jsonData['error_code'],
          data: false,
        );
      }
    } catch (e, stackTrace) {
      print('💥 [RESET_PASSWORD] Reset error: $e');
      print('📚 [RESET_PASSWORD] Stack trace: $stackTrace');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Koneksi gagal: ${e.toString()}',
        data: false,
      );
    }
  }
}
