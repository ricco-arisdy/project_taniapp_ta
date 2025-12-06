import 'package:project_taniapp_ta/models/pemeliharaan_models.dart';
import 'package:project_taniapp_ta/services/pemeliharaan_service.dart';

import '../models/api_response.dart';

class PemeliharaanRepository {
  Future<ApiResponse<Map<String, dynamic>>> getAllPemeliharaan({
    int? kebunId,
    String? kegiatan,
  }) async {
    try {
      print('🌿 [PEMELIHARAAN_REPO] Getting pemeliharaan with filters...');
      print('🌿 [PEMELIHARAAN_REPO] - Kebun ID: $kebunId');
      print('🌿 [PEMELIHARAAN_REPO] - Kegiatan: $kegiatan');

      final response = await PemeliharaanService.getAllPemeliharaan(
        kebunId: kebunId,
        kegiatan: kegiatan,
      );

      if (response.isSuccess && response.data != null) {
        final pemeliharaanList =
            response.data!['pemeliharaan'] as List<Pemeliharaan>;
        final metadata = response.data!['metadata'] as PemeliharaanMetadata?;

        print(
          '✅ [PEMELIHARAAN_REPO] Got ${pemeliharaanList.length} pemeliharaan',
        );
        if (metadata != null) {
          print('📊 [PEMELIHARAAN_REPO] Backend Stats:');
          print('   - Total Records: ${metadata.totalRecords}');
          print('   - Total Biaya: ${metadata.totalBiaya}');
          print('   - Kegiatan Terbanyak: ${metadata.kegiatanTerbanyak}');
        }

        return response;
      } else {
        print('❌ [PEMELIHARAAN_REPO] Failed: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_REPO] Error: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data pemeliharaan berdasarkan ID
  Future<ApiResponse<Pemeliharaan>> getPemeliharaanById(int id) async {
    try {
      print('🌿 [PEMELIHARAAN_REPO] Getting pemeliharaan by ID: $id');

      final response = await PemeliharaanService.getPemeliharaanById(id);

      if (response.isSuccess) {
        print(
          '✅ [PEMELIHARAAN_REPO] Successfully got pemeliharaan: ${response.data?.id}',
        );
        return response;
      } else {
        print(
          '❌ [PEMELIHARAAN_REPO] Failed to get pemeliharaan: ${response.message}',
        );
        return response;
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_REPO] Error getting pemeliharaan by ID: $e');
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data pemeliharaan baru
  Future<ApiResponse<Pemeliharaan>> createPemeliharaan({
    required int kebunId,
    required String kegiatan,
    required String tanggal,
    required int jumlah,
    String? satuan,
    required int biaya,
    String? catatan,
  }) async {
    try {
      print('🌿 [PEMELIHARAAN_REPO] Creating pemeliharaan for kebun: $kebunId');

      // Validasi data sebelum mengirim ke service
      final validationError = PemeliharaanService.validatePemeliharaanData(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
      );

      if (validationError != null) {
        print('❌ [PEMELIHARAAN_REPO] Validation error: $validationError');
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PemeliharaanService.createPemeliharaan(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
          '✅ [PEMELIHARAAN_REPO] Successfully created pemeliharaan: ${response.data?.id}',
        );
        return response;
      } else {
        print(
          '❌ [PEMELIHARAAN_REPO] Failed to create pemeliharaan: ${response.message}',
        );
        return response;
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_REPO] Error creating pemeliharaan: $e');
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update data pemeliharaan
  Future<ApiResponse<Pemeliharaan>> updatePemeliharaan({
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
      print('🌿 [PEMELIHARAAN_REPO] Updating pemeliharaan ID: $id');

      // Validasi data sebelum mengirim ke service
      final validationError = PemeliharaanService.validatePemeliharaanData(
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
      );

      if (validationError != null) {
        print('❌ [PEMELIHARAAN_REPO] Validation error: $validationError');
        return ApiResponse<Pemeliharaan>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PemeliharaanService.updatePemeliharaan(
        id: id,
        kebunId: kebunId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        jumlah: jumlah,
        satuan: satuan,
        biaya: biaya,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
          '✅ [PEMELIHARAAN_REPO] Successfully updated pemeliharaan: ${response.data?.id}',
        );
        return response;
      } else {
        print(
          '❌ [PEMELIHARAAN_REPO] Failed to update pemeliharaan: ${response.message}',
        );
        return response;
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_REPO] Error updating pemeliharaan: $e');
      return ApiResponse<Pemeliharaan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data pemeliharaan
  Future<ApiResponse<bool>> deletePemeliharaan(int id) async {
    try {
      print('🌿 [PEMELIHARAAN_REPO] Deleting pemeliharaan ID: $id');

      final response = await PemeliharaanService.deletePemeliharaan(id);

      if (response.isSuccess) {
        print(
          '✅ [PEMELIHARAAN_REPO] Successfully deleted pemeliharaan ID: $id',
        );
        return response;
      } else {
        print(
          '❌ [PEMELIHARAAN_REPO] Failed to delete pemeliharaan: ${response.message}',
        );
        return response;
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_REPO] Error deleting pemeliharaan: $e');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }
}
