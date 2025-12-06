import '../models/panen_models.dart';
import '../models/api_response.dart';
import '../services/panen_service.dart';

class PanenRepository {
  // GET - Ambil semua data panen
  Future<ApiResponse<Map<String, dynamic>>> getAllPanen() async {
    try {
      print('🌾 [PANEN_REPO] Getting all panen...');

      final response = await PanenService.getAllPanen();

      if (response.isSuccess && response.data != null) {
        final panenList = response.data!['panen'] as List<Panen>;
        final metadata = response.data!['metadata'] as PanenMetadata?;

        print('✅ [PANEN_REPO] Got ${panenList.length} panen');
        if (metadata != null) {
          print('📊 [PANEN_REPO] Backend Stats:');
          print('   - Total Records: ${metadata.totalRecords}');
          print('   - Total Kg: ${metadata.totalKg}');
          print('   - Total Nilai: ${metadata.totalNilai}');
          print('   - Rata-rata Harga: ${metadata.rataRataHarga}');
        }

        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to get panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting all panen: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data panen berdasarkan ID
  Future<ApiResponse<Panen>> getPanenById(int id) async {
    try {
      print('🌾 [PANEN_REPO] Getting panen by ID: $id');

      final response = await PanenService.getPanenById(id);

      if (response.isSuccess) {
        print('✅ [PANEN_REPO] Successfully got panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to get panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting panen by ID: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data panen baru
  Future<ApiResponse<Panen>> createPanen({
    required int kebunId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      print('🌾 [PANEN_REPO] Creating panen for kebun: $kebunId');

      // Validasi data sebelum mengirim ke service
      final validationError = PanenService.validatePanenData(
        kebunId: kebunId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
      );

      if (validationError != null) {
        print('❌ [PANEN_REPO] Validation error: $validationError');
        return ApiResponse<Panen>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PanenService.createPanen(
        kebunId: kebunId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PANEN_REPO] Successfully created panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to create panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error creating panen: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // PUT - Update data panen
  Future<ApiResponse<Panen>> updatePanen({
    required int id,
    required int kebunId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      print('🌾 [PANEN_REPO] Updating panen ID: $id');

      // Validasi data sebelum mengirim ke service
      final validationError = PanenService.validatePanenData(
        kebunId: kebunId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
      );

      if (validationError != null) {
        print('❌ [PANEN_REPO] Validation error: $validationError');
        return ApiResponse<Panen>(
          status: 'error',
          message: validationError,
        );
      }

      final response = await PanenService.updatePanen(
        id: id,
        kebunId: kebunId,
        tanggal: tanggal,
        jumlah: jumlah,
        harga: harga,
        catatan: catatan,
      );

      if (response.isSuccess) {
        print(
            '✅ [PANEN_REPO] Successfully updated panen: ${response.data?.id}');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to update panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error updating panen: $e');
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data panen
  Future<ApiResponse<bool>> deletePanen(int id) async {
    try {
      print('🌾 [PANEN_REPO] Deleting panen ID: $id');

      final response = await PanenService.deletePanen(id);

      if (response.isSuccess) {
        print('✅ [PANEN_REPO] Successfully deleted panen ID: $id');
        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to delete panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error deleting panen: $e');
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // method - Ambil panen berdasarkan kebun ID
  Future<ApiResponse<Map<String, dynamic>>> getPanenByKebunId(
      int kebunId) async {
    try {
      print('🌾 [PANEN_REPO] Getting panen by kebun ID: $kebunId');

      // ✅ Gunakan service method yang baru
      final response = await PanenService.getPanenByKebunId(kebunId);

      if (response.isSuccess && response.data != null) {
        final panenList = response.data!['panen'] as List<Panen>;
        final metadata = response.data!['metadata'] as PanenMetadata?;

        print(
            '✅ [PANEN_REPO] Found ${panenList.length} panen for kebun $kebunId');

        if (metadata != null) {
          print('📊 [PANEN_REPO] Kebun Statistics:');
          print('   - Total Records: ${metadata.totalRecords}');
          print('   - Total Kg: ${metadata.totalKg}');
          print('   - Total Nilai: ${metadata.totalNilai}');
          print('   - Rata-rata Harga: ${metadata.rataRataHarga}');
        }

        return response;
      } else {
        print('❌ [PANEN_REPO] Failed to get panen: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [PANEN_REPO] Error getting panen by kebun ID: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  // Helper method - Validasi apakah kebun memiliki panen
  Future<bool> hasAnyPanen(int kebunId) async {
    try {
      final response = await getPanenByKebunId(kebunId);
      return response.isSuccess && (response.data?.isNotEmpty ?? false);
    } catch (e) {
      print('💥 [PANEN_REPO] Error checking panen existence: $e');
      return false;
    }
  }
}
