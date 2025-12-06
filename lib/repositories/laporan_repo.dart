import 'package:pdf/widgets.dart' as pw;
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_taniapp_ta/services/laporan_pdf_service.dart';
import 'package:project_taniapp_ta/widgets/laporan/laporan_pdf.dart';
import '../models/api_response.dart';
import '../models/laporan_models.dart';
import '../models/kebun_models.dart';
import '../services/laporan_service.dart';

class LaporanRepository {
  static bool _localeInitialized = false;

  /// Get summary keseluruhan tanpa filter
  Future<ApiResponse<SummaryKeseluruhan>> getSummaryKeseluruhan() async {
    try {
      print('📊 [LAPORAN_REPO] Getting overall summary');

      final response = await LaporanService.getSummaryKeseluruhan();

      if (response.isSuccess) {
        print('✅ [LAPORAN_REPO] Successfully got overall summary');
        return response;
      } else {
        print('❌ [LAPORAN_REPO] Failed to get summary: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [LAPORAN_REPO] Error getting summary: $e');
      return ApiResponse<SummaryKeseluruhan>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  /// Get laporan data with validation and error handling
  Future<ApiResponse<LaporanData>> getLaporanData({
    required int kebunId,
    DateTime? tanggalDari,
    DateTime? tanggalSampai,
  }) async {
    try {
      print('📊 [LAPORAN_REPO] Getting laporan for kebun: $kebunId');

      // Convert DateTime to API format if provided
      String? apiTanggalDari;
      String? apiTanggalSampai;

      if (tanggalDari != null && tanggalSampai != null) {
        apiTanggalDari = LaporanService.dateTimeToApiFormat(tanggalDari);
        apiTanggalSampai = LaporanService.dateTimeToApiFormat(tanggalSampai);
      }

      // Validate request
      final validationError = LaporanService.validateLaporanRequest(
        kebunId: kebunId,
        tanggalDari: apiTanggalDari,
        tanggalSampai: apiTanggalSampai,
      );

      if (validationError != null) {
        print('❌ [LAPORAN_REPO] Validation error: $validationError');
        return ApiResponse<LaporanData>(
          status: 'error',
          message: validationError,
        );
      }

      // Call service
      final response = await LaporanService.getLaporanData(
        kebunId: kebunId,
        tanggalDari: apiTanggalDari,
        tanggalSampai: apiTanggalSampai,
      );

      if (response.isSuccess) {
        print('✅ [LAPORAN_REPO] Successfully got laporan data');
        return response;
      } else {
        print('❌ [LAPORAN_REPO] Failed to get laporan: ${response.message}');
        return response;
      }
    } catch (e) {
      print('💥 [LAPORAN_REPO] Error getting laporan: $e');
      return ApiResponse<LaporanData>(
        status: 'error',
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  /// Get available kebun for laporan selection
  Future<ApiResponse<List<Kebun>>> getAvailableKebun() async {
    try {
      print('📋 [LAPORAN_REPO] Getting available kebun for laporan');

      // Call LaporanService untuk get available kebun (lebih konsisten)
      final response = await LaporanService.getAvailableKebun();

      if (response.isSuccess && response.data != null) {
        // Convert dari Map ke Kebun objects
        final kebunList =
            response.data!.map((kebunMap) => Kebun.fromJson(kebunMap)).toList();

        print(
            '✅ [LAPORAN_REPO] Successfully converted ${kebunList.length} kebun');

        return ApiResponse<List<Kebun>>(
          status: response.status,
          message: response.message,
          data: kebunList,
        );
      } else {
        print('❌ [LAPORAN_REPO] Failed to get kebun: ${response.message}');
        return ApiResponse<List<Kebun>>(
          status: response.status,
          message: response.message ?? 'Gagal memuat daftar kebun',
        );
      }
    } catch (e) {
      print('💥 [LAPORAN_REPO] Error getting kebun list: $e');
      return ApiResponse<List<Kebun>>(
        status: 'error',
        message: 'Gagal memuat daftar kebun: ${e.toString()}',
      );
    }
  }

  /// Generate PDF document
  Future<pw.Document> generatePdfDocument(LaporanData laporanData) async {
    try {
      // Inisialisasi locale
      if (!_localeInitialized) {
        try {
          print('🌏 [LAPORAN_REPO] Initializing Indonesian locale...');
          await initializeDateFormatting('id_ID', null);
          _localeInitialized = true;
          print('✅ [LAPORAN_REPO] Indonesian locale initialized');
        } catch (localeError) {
          print('⚠️ [LAPORAN_REPO] Locale init warning: $localeError');
          // Tetap lanjutkan, karena beberapa platform mungkin sudah auto-init
        }
      }

      // Generate PDF
      return await LaporanPdfExport.generatePdfDocument(laporanData);
    } catch (e) {
      print('❌ [LAPORAN_REPO] Error generating PDF: $e');
      rethrow;
    }
  }

  /// Download PDF to device
  Future<Map<String, dynamic>> downloadPdf({
    required LaporanData laporanData,
    DateTime? tanggalDari,
    DateTime? tanggalSampai,
  }) async {
    try {
      print('📥 [LAPORAN_REPO] Starting PDF download...');

      // 1. Generate PDF document (dengan locale init di dalamnya)
      final pdf = await generatePdfDocument(laporanData);

      // 2. Generate file name
      final fileName = LaporanPdfService.generateFileName(
        kebunName: laporanData.kebun.nama,
        tanggalDari: tanggalDari,
        tanggalSampai: tanggalSampai,
      );

      print('📥 [LAPORAN_REPO] File name: $fileName');

      // 3. Download to Downloads folder
      final filePath = await LaporanPdfService.downloadPdf(
        pdf: pdf,
        fileName: fileName,
      );

      if (filePath != null) {
        print('✅ [LAPORAN_REPO] PDF downloaded to: $filePath');

        return {
          'success': true,
          'filePath': filePath,
          'fileName': fileName,
        };
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('❌ [LAPORAN_REPO] Error downloading PDF: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Helper method - Check if kebun has any data
  bool hasLaporanData(LaporanData laporan) {
    return laporan.pemeliharaan.totalRecords > 0 || laporan.panen.totalRecords > 0;
  }

  /// Helper method - Get summary text
  String getSummaryText(LaporanData laporan) {
    if (!hasLaporanData(laporan)) {
      return 'Belum ada data untuk kebun ini';
    }

    final summary = laporan.summary;
    if (summary.isUntung) {
      return 'Kebun ini menguntungkan dengan keuntungan ${formatCurrency(summary.totalKeuntungan)} (${summary.persentaseKeuntungan.toStringAsFixed(1)}%)';
    } else {
      return 'Kebun ini mengalami kerugian sebesar ${formatCurrency(summary.totalKeuntungan.abs())} (${summary.persentaseKeuntungan.toStringAsFixed(1)}%)';
    }
  }

  /// Helper method - Format currency to Rupiah (delegate to service)
  String formatCurrency(int amount) {
    return LaporanService.formatCurrency(amount);
  }

  /// Helper method - Check if date range is valid (delegate to service)
  bool isValidDateRange(DateTime? dari, DateTime? sampai) {
    if (dari == null || sampai == null) return true;

    // Convert to string format for service validation
    final tanggalDari = LaporanService.dateTimeToApiFormat(dari);
    final tanggalSampai = LaporanService.dateTimeToApiFormat(sampai);

    return LaporanService.isValidDateRange(tanggalDari, tanggalSampai);
  }

  /// Helper method - Get date range text (delegate to service)
  String getDateRangeText(String? tanggalDari, String? tanggalSampai) {
    return LaporanService.getDateRangeText(tanggalDari, tanggalSampai);
  }

  /// Helper method - Calculate profit/loss percentage
  double calculateProfitPercentage(SummaryLaporan summary) {
    if (summary.totalBiayaPemeliharaan == 0) return 0.0;
    return (summary.totalKeuntungan / summary.totalBiayaPemeliharaan) * 100;
  }

  /// Helper method - Get performance category
  String getPerformanceCategory(SummaryLaporan summary) {
    if (summary.totalBiayaPemeliharaan == 0 && summary.totalPendapatan == 0) {
      return 'Belum ada aktivitas';
    }

    if (summary.isUntung) {
      if (summary.persentaseKeuntungan >= 50) {
        return 'Sangat menguntungkan';
      } else if (summary.persentaseKeuntungan >= 20) {
        return 'Menguntungkan';
      } else {
        return 'Sedikit menguntungkan';
      }
    } else {
      if (summary.persentaseKeuntungan <= -50) {
        return 'Sangat merugikan';
      } else if (summary.persentaseKeuntungan <= -20) {
        return 'Merugikan';
      } else {
        return 'Sedikit merugikan';
      }
    }
  }

  /// Helper method - Get summary overview for summary keseluruhan
  String getSummaryOverview(SummaryKeseluruhan summary) {
    if (summary.totalKebun == 0) {
      return 'Belum ada kebun yang terdaftar';
    }

    final statusText = summary.isUntung ? 'menguntungkan' : 'merugikan';
    final keuntunganText = formatCurrency(summary.totalKeuntungan.abs());

    return 'Total ${summary.totalKebun} kebun dengan ${statusText} $keuntunganText (${summary.persentaseKeuntungan.toStringAsFixed(1)}%)';
  }

  /// Helper method - Get performance category for summary keseluruhan
  String getOverallPerformanceCategory(SummaryKeseluruhan summary) {
    if (summary.totalBiayaPemeliharaan == 0 && summary.totalPendapatan == 0) {
      return 'Belum ada aktivitas';
    }

    if (summary.isUntung) {
      if (summary.persentaseKeuntungan >= 50) {
        return 'Sangat menguntungkan';
      } else if (summary.persentaseKeuntungan >= 20) {
        return 'Menguntungkan';
      } else {
        return 'Sedikit menguntungkan';
      }
    } else {
      if (summary.persentaseKeuntungan <= -50) {
        return 'Sangat merugikan';
      } else if (summary.persentaseKeuntungan <= -20) {
        return 'Merugikan';
      } else {
        return 'Sedikit merugikan';
      }
    }
  }

  /// Helper method - Validate date range for summary request
  String? validateSummaryDateRange(DateTime? dari, DateTime? sampai) {
    if (dari == null || sampai == null) return null;

    // Convert to API format and validate
    final apiDari = LaporanService.dateTimeToApiFormat(dari);
    final apiSampai = LaporanService.dateTimeToApiFormat(sampai);

    return LaporanService.validateSummaryRequest(
      tanggalDari: apiDari,
      tanggalSampai: apiSampai,
    );
  }

  /// Helper method - Check if summary has meaningful data
  bool hasMeaningfulData(SummaryKeseluruhan summary) {
    return summary.totalPemeliharaanRecords > 0 ||
        summary.totalPanenRecords > 0 ||
        summary.totalBiayaPemeliharaan > 0 ||
        summary.totalPendapatan > 0;
  }

  /// Helper method - Get activity summary text
  String getActivitySummaryText(SummaryKeseluruhan summary) {
    if (!hasMeaningfulData(summary)) {
      return 'Belum ada aktivitas pemeliharaan atau panen';
    }

    final List<String> activities = [];

    if (summary.totalPemeliharaanRecords > 0) {
      activities.add('${summary.totalPemeliharaanRecords} pemeliharaan');
    }

    if (summary.totalPanenRecords > 0) {
      activities.add('${summary.totalPanenRecords} panen');
    }

    return 'Total ${activities.join(' dan ')} dari ${summary.totalKebun} kebun';
  }

  /// Helper method - Format large numbers with units (K, M, etc.)
  String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// Helper method - Get period text for display
  String getPeriodText(DateTime? dari, DateTime? sampai) {
    if (dari == null || sampai == null) {
      return 'Semua periode';
    }

    final apiDari = LaporanService.dateTimeToApiFormat(dari);
    final apiSampai = LaporanService.dateTimeToApiFormat(sampai);

    return LaporanService.getDateRangeText(apiDari, apiSampai);
  }

  /// Helper method - Check if laporan needs refresh based on last update
  bool needsRefresh(LaporanData laporan,
      {Duration maxAge = const Duration(minutes: 5)}) {
    try {
      final generatedAt = DateTime.parse(laporan.metadata.generatedAt);
      return DateTime.now().difference(generatedAt) > maxAge;
    } catch (e) {
      // If can't parse date, assume needs refresh
      return true;
    }
  }
}
