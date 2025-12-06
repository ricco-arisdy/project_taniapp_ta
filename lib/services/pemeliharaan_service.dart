import 'dart:convert';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';

import '../models/pemeliharaan_models.dart';
import '../models/api_response.dart';
import 'http_service.dart';

class PemeliharaanService {
  static Future<ApiResponse<Map<String, dynamic>>> getAllPemeliharaan({
    int? kebunId,
    String? kegiatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Build query string
      String endpoint = 'pemeliharaan.php';
      List<String> queryParams = [];

      if (kebunId != null && kebunId > 0) {
        queryParams.add('kebun_id=$kebunId');
      }

      if (kegiatan != null && kegiatan.isNotEmpty && kegiatan != 'Semua') {
        queryParams.add('kegiatan=${Uri.encodeComponent(kegiatan)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      print('🌿 [PEMELIHARAAN_SERVICE] Request endpoint: $endpoint');

      final response = await HttpService.get(endpoint);

      print(
        '🌿 [PEMELIHARAAN_SERVICE] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print(
          '🌿 [PEMELIHARAAN_SERVICE] Parsed JSON status: ${jsonData['status']}',
        );

        if (jsonData['status'] == 'success') {
          final dataObject = jsonData['data'];
          print('🔍 [DEBUG] Data object keys: ${dataObject.keys}');

          final pemeliharaanArray = dataObject['pemeliharaan'];

          print(
            '🔍 [DEBUG] Pemeliharaan array type: ${pemeliharaanArray.runtimeType}',
          );
          print(
            '🔍 [DEBUG] Pemeliharaan array length: ${pemeliharaanArray?.length}',
          );
          print(
            '🔍 [DEBUG] First item: ${pemeliharaanArray?.isNotEmpty == true ? pemeliharaanArray[0] : 'EMPTY'}',
          );

          final List<dynamic> pemeliharaanList = pemeliharaanArray ?? [];
          print(
            '📋 [PEMELIHARAAN_SERVICE] Total items in array: ${pemeliharaanList.length}',
          );

          final List<Pemeliharaan> pemeliharaans = [];
          for (var i = 0; i < pemeliharaanList.length; i++) {
            try {
              final item = pemeliharaanList[i];
              print('🔄 [PEMELIHARAAN_SERVICE] Parsing item $i: $item');
              final pemeliharaan = Pemeliharaan.fromJson(item);
              pemeliharaans.add(pemeliharaan);
              print(
                '✅ [PEMELIHARAAN_SERVICE] Successfully parsed item $i: ${pemeliharaan.id}',
              );
            } catch (e, stackTrace) {
              print('❌ [PEMELIHARAAN_SERVICE] Error parsing item $i: $e');
              print('📚 [PEMELIHARAAN_SERVICE] Stack trace: $stackTrace');
              print(
                '📋 [PEMELIHARAAN_SERVICE] Item data: ${pemeliharaanList[i]}',
              );
            }
          }

          print(
            '✅ [PEMELIHARAAN_SERVICE] Successfully parsed ${pemeliharaans.length} pemeliharaan',
          );

          // Parse metadata
          PemeliharaanMetadata? metadata;
          if (dataObject['metadata'] != null) {
            try {
              metadata = PemeliharaanMetadata.fromJson(dataObject['metadata']);
              print('📊 [PEMELIHARAAN_SERVICE] Metadata parsed: $metadata');
            } catch (e) {
              print('⚠️ [PEMELIHARAAN_SERVICE] Error parsing metadata: $e');
            }
          }

          return ApiResponse<Map<String, dynamic>>(
            status: 'success',
            message: pemeliharaans.isEmpty
                ? 'Tidak ada data pemeliharaan'
                : 'Data berhasil diambil',
            data: {'pemeliharaan': pemeliharaans, 'metadata': metadata},
          );
        } else {
          print('❌ [PEMELIHARAAN_SERVICE] API error: ${jsonData['message']}');
          return ApiResponse<Map<String, dynamic>>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengambil data',
          );
        }
      } else {
        print('❌ [PEMELIHARAAN_SERVICE] HTTP error: ${response.statusCode}');
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('💥 [PEMELIHARAAN_SERVICE] Exception: $e');
      print('📚 [PEMELIHARAAN_SERVICE] Stack trace: $stackTrace');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data pemeliharaan berdasarkan ID
  static Future<ApiResponse<Pemeliharaan>> getPemeliharaanById(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final response = await HttpService.get('pemeliharaan.php?id=$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final pemeliharaan = Pemeliharaan.fromJson(jsonData['data']);
          return ApiResponse<Pemeliharaan>(
            status: 'success',
            message: 'Data berhasil diambil',
            data: pemeliharaan,
          );
        } else {
          return ApiResponse<Pemeliharaan>(
            status: 'error',
            message: jsonData['message'] ?? 'Data pemeliharaan tidak ditemukan',
          );
        }
      } else {
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data pemeliharaan baru
  static Future<ApiResponse<Pemeliharaan>> createPemeliharaan({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'kegiatan': kegiatan,
        'tanggal': tanggal,
        'jumlah': jumlah,
        if (satuan != null && satuan.isNotEmpty) 'satuan': satuan,
        'biaya': biaya,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      final response = await HttpService.post('pemeliharaan.php', requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final pemeliharaan = Pemeliharaan.fromJson(jsonData['data']);
          return ApiResponse<Pemeliharaan>(
            status: 'success',
            message: 'Data pemeliharaan berhasil ditambahkan',
            data: pemeliharaan,
          );
        } else {
          return ApiResponse<Pemeliharaan>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menambah data pemeliharaan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambah data pemeliharaan',
        );
      }
    } catch (e) {
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // PUT - Update data pemeliharaan
  static Future<ApiResponse<Pemeliharaan>> updatePemeliharaan({
    required int id,
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'kegiatan': kegiatan,
        'tanggal': tanggal,
        'jumlah': jumlah,
        if (satuan != null && satuan.isNotEmpty) 'satuan': satuan,
        'biaya': biaya,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      final response = await HttpService.put(
        'pemeliharaan.php/$id',
        requestData,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final pemeliharaan = Pemeliharaan.fromJson(jsonData['data']);
          return ApiResponse<Pemeliharaan>(
            status: 'success',
            message: 'Data pemeliharaan berhasil diupdate',
            data: pemeliharaan,
          );
        } else {
          return ApiResponse<Pemeliharaan>(
            status: 'error',
            message:
                jsonData['message'] ?? 'Gagal mengupdate data pemeliharaan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengupdate data pemeliharaan',
        );
      }
    } catch (e) {
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data pemeliharaan
  static Future<ApiResponse<bool>> deletePemeliharaan(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final response = await HttpService.delete('pemeliharaan.php/$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          return ApiResponse<bool>(
            status: 'success',
            message: 'Data pemeliharaan berhasil dihapus',
            data: true,
          );
        } else {
          return ApiResponse<bool>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menghapus data pemeliharaan',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<bool>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menghapus data pemeliharaan',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Method untuk validasi data pemeliharaan
  static String? validatePemeliharaanData({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
  }) {
    if (kebunId <= 0) {
      return 'Pilih kebun terlebih dahulu';
    }

    if (kegiatan.isEmpty) {
      return 'Jenis kegiatan harus diisi';
    }

    if (satuan != null && satuan.isNotEmpty) {
      if (!PemeliharaanConstants.satuanOptions.contains(satuan)) {
        return 'Satuan harus berupa ${PemeliharaanConstants.satuanOptions.join(" atau ")}';
      }
    }

    final dateError = validateDateFormat(tanggal);
    if (dateError != null) {
      return dateError;
    }

    if (jumlah <= 0) {
      return 'Jumlah harus lebih dari 0';
    }

    if (biaya < 0) {
      return 'Biaya tidak boleh negatif';
    }

    return null; // Valid
  }

  // Helper method untuk validasi format tanggal
  static String? validateDateFormat(String dateString) {
    if (dateString.isEmpty) {
      return 'Tanggal harus diisi';
    }

    // Check DD-MM-YYYY format
    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(dateString)) {
      return 'Format tanggal harus DD-MM-YYYY';
    }

    try {
      final parts = dateString.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate components
      if (month < 1 || month > 12) {
        return 'Bulan tidak valid (1-12)';
      }

      if (day < 1 || day > 31) {
        return 'Tanggal tidak valid (1-31)';
      }

      // Validate complete date
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Tanggal tidak valid';
      }

      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }
}
