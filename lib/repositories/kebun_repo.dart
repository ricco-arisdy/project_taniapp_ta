

import 'package:project_taniapp_ta/models/api_response.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/services/kebun_service.dart';

class KebunRepository {
  final KebunService _kebunService = KebunService();
  Future<ApiResponse<Map<String, dynamic>>> getAllKebun() async {
    try {
      print('📦 [KEBUN_REPO] Getting all kebun...');
      final response = await _kebunService.getAllKebun();
      if (response.isSuccess && response.data != null) {
        final kebunList = response.data!['kebun'] as List<Kebun>;
        final metadata = response.data!['metadata'] as KebunMetadata?;

        print('📦 [KEBUN_REPO] Successfully got ${kebunList.length} kebun');
        if (metadata != null) {
          print('📊 [KEBUN_REPO] Backend Statistics:');
          print('   - Total Luas: ${metadata.totalLuas}');
          print('   - Total Titik Tanam: ${metadata.totalTitikTanam}');
        }
      }

      return response;
    } catch (e) {
      print('💥 [KEBUN_REPO] Get all kebun error: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengambil data kebun',
      );
    }
  }

  // Get kebun by ID
  Future<ApiResponse<Kebun>> getKebunById(int id) async {
    try {
      print('📦 [KEBUN_REPO] Getting kebun by ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<Kebun>(
          status: 'error',
          message: 'ID kebun tidak valid',
        );
      }

      return await _kebunService.getKebunById(id);
    } catch (e) {
      print('💥 [KEBUN_REPO] Get kebun by ID error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengambil detail kebun',
      );
    }
  }

  // Create new kebun with validation
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
      print('📦 [KEBUN_REPO] Creating kebun: $nama');

      // Validate input
      final validation = _validateKebunInput(
        nama: nama,
        lokasi: lokasi,
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );

      if (validation != null) {
        return ApiResponse<Kebun>(
          status: 'error',
          message: validation,
        );
      }

      return await _kebunService.createKebun(
        nama: nama.trim(),
        lokasi: lokasi.trim(),
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );
    } catch (e) {
      print('💥 [KEBUN_REPO] Create kebun error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan saat menambahkan kebun',
      );
    }
  }

  // Update kebun with validation
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
      print('📦 [KEBUN_REPO] Updating kebun ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<Kebun>(
          status: 'error',
          message: 'ID kebun tidak valid',
        );
      }

      // Validate input
      final validation = _validateKebunInput(
        nama: nama,
        lokasi: lokasi,
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );

      if (validation != null) {
        return ApiResponse<Kebun>(
          status: 'error',
          message: validation,
        );
      }

      return await _kebunService.updateKebun(
        id: id,
        nama: nama.trim(),
        lokasi: lokasi.trim(),
        luas: luas,
        titikTanam: titikTanam,
        waktuBeli: waktuBeli,
        statusKepemilikan: statusKepemilikan,
        statusKebun: statusKebun,
      );
    } catch (e) {
      print('💥 [KEBUN_REPO] Update kebun error: $e');
      return ApiResponse<Kebun>(
        status: 'error',
        message: 'Terjadi kesalahan saat mengupdate kebun',
      );
    }
  }

  // Delete kebun with confirmation
  Future<ApiResponse<void>> deleteKebun(int id) async {
    try {
      print('📦 [KEBUN_REPO] Deleting kebun ID: $id');

      // Validate ID
      if (id <= 0) {
        return ApiResponse<void>(
          status: 'error',
          message: 'ID kebun tidak valid',
        );
      }

      return await _kebunService.deleteKebun(id);
    } catch (e) {
      print('💥 [KEBUN_REPO] Delete kebun error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Terjadi kesalahan saat menghapus kebun',
      );
    }
  }

  // Private method for input validation
  String? _validateKebunInput({
    required String nama,
    required String lokasi,
    required String luas,
    required int titikTanam,
    required String waktuBeli,
    required String statusKepemilikan,
    required String statusKebun,
  }) {
    if (nama.trim().isEmpty) {
      return 'Nama kebun tidak boleh kosong';
    }

    if (nama.trim().length < 3) {
      return 'Nama kebun minimal 3 karakter';
    }

    if (lokasi.trim().isEmpty) {
      return 'Lokasi kebun tidak boleh kosong';
    }

    if (luas.isEmpty) {
      return 'Luas kebun tidak boleh kosong';
    }

    // Validate luas is numeric
    final luasDouble = double.tryParse(luas.replaceAll(',', '.'));
    if (luasDouble == null || luasDouble <= 0) {
      return 'Luas kebun harus berupa angka positif';
    }

    if (titikTanam <= 0) {
      return 'Titik tanam harus lebih dari 0';
    }

    if (waktuBeli.isEmpty) {
      return 'Waktu beli tidak boleh kosong';
    }

    if (statusKepemilikan.isEmpty) {
      return 'Status kepemilikan tidak boleh kosong';
    }

    if (statusKebun.isEmpty) {
      return 'Status kebun tidak boleh kosong';
    }

    return null; // All validations passed
  }
}
