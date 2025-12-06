import 'dart:convert';

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/services/http_service.dart';

class DashboardStats {
  final int totalKebun;
  final int totalPanen;
  final int totalPerawatan;
  final double totalLuas;
  final double totalPendapatan;

  DashboardStats({
    required this.totalKebun,
    required this.totalPanen,
    required this.totalPerawatan,
    required this.totalLuas,
    required this.totalPendapatan,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalKebun: json['total_kebun'] ?? 0,
      totalPanen: json['total_panen'] ?? 0,
      totalPerawatan: json['total_perawatan'] ?? 0,
      totalLuas: (json['total_luas'] ?? 0.0).toDouble(),
      totalPendapatan: (json['total_pendapatan'] ?? 0.0).toDouble(),
    );
  }
}

class DashboardService {
  // Get dashboard statistics
  static Future<ApiResponse<DashboardStats>> getDashboardStats() async {
    try {
      print('📊 [DASHBOARD] Getting dashboard stats...');

      final response = await HttpService.get('dashboard.php');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final stats = DashboardStats.fromJson(jsonData['data']);

          return ApiResponse<DashboardStats>(
            status: 'success',
            message: 'Dashboard data berhasil dimuat',
            data: stats,
          );
        }
      }

      // Return empty stats if no data
      return ApiResponse<DashboardStats>(
        status: 'success',
        message: 'Belum ada data',
        data: DashboardStats(
          totalKebun: 0,
          totalPanen: 0,
          totalPerawatan: 0,
          totalLuas: 0.0,
          totalPendapatan: 0.0,
        ),
      );
    } catch (e) {
      print('💥 [DASHBOARD] Error: $e');

      // Return empty stats on error
      return ApiResponse<DashboardStats>(
        status: 'success',
        message: 'Belum ada data',
        data: DashboardStats(
          totalKebun: 0,
          totalPanen: 0,
          totalPerawatan: 0,
          totalLuas: 0.0,
          totalPendapatan: 0.0,
        ),
      );
    }
  }
}
