import 'dart:convert';

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/services/http_service.dart';

class KebunService {
  // GET - Fetch all kebun
  Future<ApiResponse<Map<String, dynamic>>> getAllKebun() async {
    try {
      print('🌱 [KEBUN] Getting all kebun...');

      final response = await HttpService.get(ApiEndpoints.kebun);
      print('📊 [KEBUN] Raw Response: ${response.body}');
      print('📊 [KEBUN] Status Code: ${response.statusCode}');

      // ✅ Handle 401 specifically
      if (response.statusCode == 401) {
        print('🚨 [KEBUN] 401 Unauthorized - Session expired');
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Sesi telah berakhir, silakan login kembali',
        );
      }

      if (response.statusCode != 200) {
        print('⚠️ [KEBUN] HTTP Status: ${response.statusCode}');
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Gagal mengambil data kebun',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('📊 [KEBUN] JSON Data: $jsonData');

      if (jsonData['status'] == 'success') {
        // Parse kebun list
        List<dynamic> kebunJsonList = [];
        if (jsonData['data'] != null && jsonData['data']['kebun'] != null) {
          kebunJsonList = jsonData['data']['kebun'];
        }

        final List<Kebun> kebunList = kebunJsonList
            .map((json) => Kebun.fromJson(json))
            .toList();

        // Parse metadata dari backend
        KebunMetadata? metadata;
        if (jsonData['data'] != null && jsonData['data']['metadata'] != null) {
          metadata = KebunMetadata.fromJson(jsonData['data']['metadata']);
          print('📊 [KEBUN] Backend Statistics:');
          print('   - Total Luas: ${metadata.totalLuas}');
          print('   - Total Titik Tanam: ${metadata.totalTitikTanam}');
        }

        print(' [KEBUN] Successfully got ${kebunList.length} kebun');

        //  Return both kebun list and metadata
        return ApiResponse<Map<String, dynamic>>(
          status: 'success',
          message: 'Data kebun berhasil diambil',
          data: {'kebun': kebunList, 'metadata': metadata},
        );
      } else {
        print('❌ [KEBUN] API Error: ${jsonData['message']}');
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: jsonData['message'],
        );
      }
    } catch (e, stackTrace) {
      print('💥 [KEBUN] Get all kebun error: $e');
      print('📚 [KEBUN] Stack trace: $stackTrace');

      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Create new kebun
  Future<ApiResponse<Kebun>> createKebun({
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) async {
    try {
      print('🌱 [KEBUN] Creating kebun: $nama');

      final data = {
        'nama': nama,
        'lokasi': lokasi,
        'luas': luas,
        'titik_tanam': titikTanam,
        'waktu_beli': waktuBeli,
        'status_kepemilikan': statusKepemilikan,
        'status_kebun': statusKebun,
      };

      print('📤 [KEBUN] Sending data: ${json.encode(data)}');
      print('📅 [KEBUN] Date format being sent: $waktuBeli');

      final response = await HttpService.post(ApiEndpoints.kebun, data);

      print('📥 [KEBUN] Response status: ${response.statusCode}');
      print('📥 [KEBUN] Response body: ${response.body}');
      // ✅ Handle 500 error specifically
      if (response.statusCode == 500) {
        print('🚨 [KEBUN] Server error 500');
        return ApiResponse<Kebun>(
          status: 'error',
          message: 'Server mengalami kesalahan internal. Silakan coba lagi.',
        );
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success' && response.statusCode == 201) {
        final kebun = Kebun.fromJson(jsonData['data']);
        print('✅ [KEBUN] Successfully created kebun: ${kebun.nama}');

        return ApiResponse<Kebun>(
          status: 'success',
          message: jsonData['message'],
          data: kebun,
        );
      } else {
        print('❌ [KEBUN] Create failed: ${jsonData['message']}');
        return ApiResponse<Kebun>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambahkan kebun',
        );
      }
    } catch (e) {
      print('💥 [KEBUN] Create kebun error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update kebun
  Future<ApiResponse<Kebun>> updateKebun({
    required int id,
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) async {
    try {
      print('🌱 [KEBUN] Updating kebun ID: $id');

      final data = {
        'nama': nama,
        'lokasi': lokasi,
        'luas': luas,
        'titik_tanam': titikTanam,
        'waktu_beli': waktuBeli,
        'status_kepemilikan': statusKepemilikan,
        'status_kebun': statusKebun,
      };

      final response = await HttpService.put('${ApiEndpoints.kebun}/$id', data);
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        final kebun = Kebun.fromJson(jsonData['data']);
        print('✅ [KEBUN] Successfully updated kebun: ${kebun.nama}');

        return ApiResponse<Kebun>(
          status: 'success',
          message: jsonData['message'],
          data: kebun,
        );
      } else {
        print('❌ [KEBUN] Update failed: ${jsonData['message']}');
        return ApiResponse<Kebun>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengupdate kebun',
        );
      }
    } catch (e) {
      print('💥 [KEBUN] Update kebun error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Get kebun by ID
  Future<ApiResponse<Kebun>> getKebunById(int id) async {
    try {
      print('🌱 [KEBUN] Getting kebun by ID: $id');

      final response = await HttpService.get('${ApiEndpoints.kebun}/$id');
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success' && response.statusCode == 200) {
        final kebun = Kebun.fromJson(jsonData['data']);
        print('✅ [KEBUN] Successfully got kebun: ${kebun.nama}');

        return ApiResponse<Kebun>(
          status: 'success',
          message: jsonData['message'],
          data: kebun,
        );
      } else {
        print('❌ [KEBUN] Get by ID failed: ${jsonData['message']}');
        return ApiResponse<Kebun>(
          status: 'error',
          message: jsonData['message'] ?? 'Kebun tidak ditemukan',
        );
      }
    } catch (e) {
      print('💥 [KEBUN] Get kebun by ID error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Delete kebun
  Future<ApiResponse<void>> deleteKebun(int id) async {
    try {
      print('🌱 [KEBUN] Deleting kebun ID: $id');

      final response = await HttpService.delete('${ApiEndpoints.kebun}/$id');
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        print('✅ [KEBUN] Successfully deleted kebun ID: $id');

        return ApiResponse<void>(
          status: 'success',
          message: jsonData['message'],
        );
      } else {
        print('❌ [KEBUN] Delete failed: ${jsonData['message']}');
        return ApiResponse<void>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menghapus kebun',
        );
      }
    } catch (e) {
      print('💥 [KEBUN] Delete kebun error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }
}
