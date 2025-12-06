import 'dart:convert';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';

import '../models/panen_models.dart';
import '../models/api_response.dart';
import 'http_service.dart';

class PanenService {
  // GET - Ambil semua data panen
  static Future<ApiResponse<Map<String, dynamic>>> getAllPanen() async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final response = await HttpService.get('panen.php');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // ✅ Parse panen list
          final List<dynamic> panenList = jsonData['data']['panen'] ?? [];
          final List<Panen> panens = panenList
              .map((item) => Panen.fromJson(item))
              .toList();

          // ✅ Parse metadata dari backend
          PanenMetadata? metadata;
          if (jsonData['data']['metadata'] != null) {
            metadata = PanenMetadata.fromJson(jsonData['data']['metadata']);
            print('📊 [PANEN_SERVICE] Backend Statistics:');
            print('   - Total Kg: ${metadata.totalKg}');
            print('   - Total Nilai: ${metadata.totalNilai}');
            print('   - Rata-rata Harga: ${metadata.rataRataHarga}');
          }

          return ApiResponse<Map<String, dynamic>>(
            status: 'success',
            message: 'Data berhasil diambil',
            data: {'panen': panens, 'metadata': metadata},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengambil data panen',
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data panen berdasarkan Kebun ID
  static Future<ApiResponse<Map<String, dynamic>>> getPanenByKebunId(
    int kebunId,
  ) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      print('🌾 [PANEN_SERVICE] Getting panen for kebun_id: $kebunId');

      // Request dengan query parameter kebun_id
      final response = await HttpService.get('panen.php?kebun_id=$kebunId');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Parse panen list
          final List<dynamic> panenList = jsonData['data']['panen'] ?? [];
          final List<Panen> panens = panenList
              .map((item) => Panen.fromJson(item))
              .toList();

          // Parse metadata dari backend
          PanenMetadata? metadata;
          if (jsonData['data']['metadata'] != null) {
            metadata = PanenMetadata.fromJson(jsonData['data']['metadata']);
            print('📊 [PANEN_SERVICE] Kebun Statistics:');
            print('   - Kebun ID: ${metadata.userId}');
            print('   - Total Kg: ${metadata.totalKg}');
            print('   - Total Nilai: ${metadata.totalNilai}');
            print('   - Rata-rata Harga: ${metadata.rataRataHarga}');
          }

          return ApiResponse<Map<String, dynamic>>(
            status: 'success',
            message: 'Data panen untuk kebun berhasil diambil',
            data: {'panen': panens, 'metadata': metadata},
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengambil data panen',
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // GET - Ambil data panen berdasarkan ID
  static Future<ApiResponse<Panen>> getPanenById(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Panen>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      // Sesuaikan dengan HttpService yang ada
      final response = await HttpService.get('panen.php?id=$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final panen = Panen.fromJson(jsonData['data']);
          return ApiResponse<Panen>(
            status: 'success',
            message: 'Data berhasil diambil',
            data: panen,
          );
        } else {
          return ApiResponse<Panen>(
            status: 'error',
            message: jsonData['message'] ?? 'Data panen tidak ditemukan',
          );
        }
      } else {
        return ApiResponse<Panen>(
          status: 'error',
          message: 'Gagal terhubung ke server',
        );
      }
    } catch (e) {
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // POST - Tambah data panen baru
  static Future<ApiResponse<Panen>> createPanen({
    required int kebunId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Panen>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'tanggal': tanggal,
        'jumlah': jumlah,
        'harga': harga,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      final response = await HttpService.post('panen.php', requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final panen = Panen.fromJson(jsonData['data']);
          return ApiResponse<Panen>(
            status: 'success',
            message: 'Data panen berhasil ditambahkan',
            data: panen,
          );
        } else {
          return ApiResponse<Panen>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menambah data panen',
          );
        }
      } else if (response.statusCode == 400) {
        // Handle error response dengan detail limit info
        final jsonData = json.decode(response.body);

        // Check if it's monthly limit exceeded error
        if (jsonData['error_code'] == 'MONTHLY_LIMIT_EXCEEDED') {
          String detailMessage =
              jsonData['message'] ?? 'Limit bulanan terlampaui';

          // Extract limit info if available
          if (jsonData['data'] != null &&
              jsonData['data']['limit_info'] != null) {
            final limitInfo = jsonData['data']['limit_info'];
            detailMessage =
                'Maksimal ${limitInfo['maksimal_per_bulan']} data panen per bulan per kebun.\n'
                'Kebun "${limitInfo['nama_kebun']}" di bulan ${limitInfo['bulan']} sudah memiliki ${limitInfo['jumlah_saat_ini']} data.\n'
                'Hapus salah satu data yang ada untuk menambah data baru.';
          }

          return ApiResponse<Panen>(
            status: 'error',
            message: detailMessage,
            errorCode: 'MONTHLY_LIMIT_EXCEEDED',
          );
        }

        return ApiResponse<Panen>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambah data panen',
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Panen>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menambah data panen',
        );
      }
    } catch (e) {
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // PUT - Update data panen
  static Future<ApiResponse<Panen>> updatePanen({
    required int id,
    required int kebunId,
    required String tanggal,
    required int jumlah,
    required int harga,
    String? catatan,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Panen>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      final Map<String, dynamic> requestData = {
        'kebun_id': kebunId,
        'tanggal': tanggal,
        'jumlah': jumlah,
        'harga': harga,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      };

      // Kirim ID sebagai bagian dari path, bukan query parameter
      final response = await HttpService.put('panen.php/$id', requestData);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final panen = Panen.fromJson(jsonData['data']);
          return ApiResponse<Panen>(
            status: 'success',
            message: 'Data panen berhasil diupdate',
            data: panen,
          );
        } else {
          return ApiResponse<Panen>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal mengupdate data panen',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Panen>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal mengupdate data panen',
        );
      }
    } catch (e) {
      return ApiResponse<Panen>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // DELETE - Hapus data panen
  static Future<ApiResponse<bool>> deletePanen(int id) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<bool>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      //Delete juga menggunakan path ID
      final response = await HttpService.delete('panen.php/$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          return ApiResponse<bool>(
            status: 'success',
            message: 'Data panen berhasil dihapus',
            data: true,
          );
        } else {
          return ApiResponse<bool>(
            status: 'error',
            message: jsonData['message'] ?? 'Gagal menghapus data panen',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<bool>(
          status: 'error',
          message: jsonData['message'] ?? 'Gagal menghapus data panen',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> checkMonthlyLimit({
    required int kebunId,
    required String tanggal, // Format DD-MM-YYYY
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Token tidak ditemukan',
        );
      }

      // Convert tanggal ke format yang diperlukan untuk pengecekan
      DateTime date;
      try {
        final parts = tanggal.split('-');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Format tanggal tidak valid',
        );
      }

      // Simulasi pengecekan dengan mendapatkan data panen untuk bulan tersebut
      final response = await HttpService.get('panen.php');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final List<dynamic> panenList = jsonData['data']['panen'] ?? [];

          // Filter data untuk kebun dan bulan yang sama
          final monthlyData = panenList.where((item) {
            if (item['kebun_id'] != kebunId) return false;

            try {
              final itemDate = DateTime.parse(item['tanggal']);
              return itemDate.year == date.year && itemDate.month == date.month;
            } catch (e) {
              return false;
            }
          }).toList();

          return ApiResponse<Map<String, dynamic>>(
            status: 'success',
            message: 'Data limit berhasil diambil',
            data: {
              'current_count': monthlyData.length,
              'max_limit': 2,
              'can_add': monthlyData.length < 2,
              'month_year':
                  '${date.month.toString().padLeft(2, '0')}-${date.year}',
              'existing_data': monthlyData,
            },
          );
        }
      }

      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Gagal mengecek limit bulanan',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  static String? validatePanenData({
    required int kebunId,
    required String tanggal,
    required int jumlah,
    required int harga,
  }) {
    if (kebunId <= 0) {
      return 'Pilih kebun terlebih dahulu';
    }

    // USE new date validation
    final dateError = validateDateFormat(tanggal);
    if (dateError != null) {
      return dateError;
    }

    if (jumlah <= 0) {
      return 'Jumlah panen harus lebih dari 0';
    }

    if (harga < 0) {
      return 'Harga tidak boleh negatif';
    }

    return null;
  }

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
