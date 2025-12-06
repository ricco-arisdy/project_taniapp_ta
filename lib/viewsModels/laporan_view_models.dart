import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/repositories/laporan_repo.dart';
import '../models/laporan_models.dart';
import '../models/kebun_models.dart';

class LaporanViewModel extends ChangeNotifier {
  final LaporanRepository _laporanRepository = LaporanRepository();

  // State variables
  LaporanData? _currentLaporan;
  List<Kebun> _availableKebun = [];
  SummaryKeseluruhan? _summaryKeseluruhan;

  bool _isLoading = false;
  bool _isLoadingKebun = false;
  bool _isLoadingSummary = false;
  String _errorMessage = '';
  bool _needsDataReload = false;

  // PDF export state
  bool _isDownloadingPdf = false;
  String _downloadErrorMessage = '';

  // PDF getters
  bool get isDownloadingPdf => _isDownloadingPdf;
  String get downloadErrorMessage => _downloadErrorMessage;

  // Filter state
  Kebun? _selectedKebun;
  DateTime? _tanggalDari;
  DateTime? _tanggalSampai;
  bool _isFilterActive = false;

  // Pagination state for summary card
  int _summaryCurrentPage = 0;

  // Form controllers for date pickers
  final TextEditingController tanggalDariController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();

  // Getters
  LaporanData? get currentLaporan => _currentLaporan;
  List<Kebun> get availableKebun => _availableKebun;
  SummaryKeseluruhan? get summaryKeseluruhan => _summaryKeseluruhan;

  bool get isLoading => _isLoading;
  bool get isLoadingKebun => _isLoadingKebun;
  bool get isLoadingSummary => _isLoadingSummary;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get hasData => _currentLaporan != null;
  bool get hasSummary => _summaryKeseluruhan != null;
  bool get needsDataReload => _needsDataReload;

  bool get hasLaporanData =>
      _currentLaporan != null &&
      _laporanRepository.hasLaporanData(_currentLaporan!);

  // Filter getters
  Kebun? get selectedKebun => _selectedKebun;
  DateTime? get tanggalDari => _tanggalDari;
  DateTime? get tanggalSampai => _tanggalSampai;
  bool get isFilterActive => _isFilterActive;
  bool get canGenerateReport => _selectedKebun != null;

  // Pagination getters
  int get summaryCurrentPage => _summaryCurrentPage;
  int get summaryTotalPages => _calculateTotalPages();

  // Summary getters (safe access)
  String get summaryText => _currentLaporan != null
      ? _laporanRepository.getSummaryText(_currentLaporan!)
      : hasSummary
      ? 'Ringkasan dari ${_summaryKeseluruhan!.totalKebun} kebun'
      : 'Belum ada data laporan';

  String get performanceCategory => _currentLaporan?.summary != null
      ? _laporanRepository.getPerformanceCategory(_currentLaporan!.summary)
      : hasSummary
      ? _getOverallPerformanceCategory()
      : 'Belum ada data';

  String get dateRangeText => _laporanRepository.getDateRangeText(
    _tanggalDari != null ? _formatDateForDisplay(_tanggalDari!) : null,
    _tanggalSampai != null ? _formatDateForDisplay(_tanggalSampai!) : null,
  );

  // Get display summary - prioritas filtered summary, fallback ke keseluruhan
  Map<String, dynamic> get displaySummary {
    Map<String, dynamic> result = {};

    if (_currentLaporan != null) {
      final summary = _currentLaporan!.summary;
      // final pemeliharaan = _currentLaporan!.pemeliharaan;
      // final panen = _currentLaporan!.panen;
      String luasKebun = _currentLaporan!.kebun.luas;
      if (!luasKebun.toLowerCase().contains('ha')) {
        luasKebun = '$luasKebun Ha';
      }

      result = {
        'totalBiayaPemeliharaan': summary.totalBiayaPemeliharaan,
        'totalPendapatan': summary.totalPendapatan,
        'totalKeuntungan': summary.totalKeuntungan,
        'persentaseKeuntungan': summary.persentaseKeuntungan,
        'isUntung': summary.isUntung,
        'totalPemeliharaan': _currentLaporan!.pemeliharaan.totalRecords,
        'totalPanen': _currentLaporan!.panen.totalRecords,
        'isFiltered': true,
        'kebunName': _currentLaporan!.kebun.nama,
        'kebunLokasi': _currentLaporan!.kebun.lokasi,
        'totalKebun': 1,
        'luasKebun': luasKebun,
        'totalPemeliharaanRecords': _currentLaporan!.pemeliharaan.totalRecords,
        'totalJumlahKg': _currentLaporan!.panen.totalJumlahKg,
        'rataRataBiaya': _currentLaporan!.pemeliharaan.rataRataBiaya,
        'hargaRataPerKg': _currentLaporan!.panen.hargaRataPerKg,
      };
    } else if (_summaryKeseluruhan != null) {
      // Jika belum ada filter, gunakan summary keseluruhan
      result = {
        'totalBiayaPemeliharaan': _summaryKeseluruhan!.totalBiayaPemeliharaan,
        'totalPendapatan': _summaryKeseluruhan!.totalPendapatan,
        'totalKeuntungan': _summaryKeseluruhan!.totalKeuntungan,
        'persentaseKeuntungan': _summaryKeseluruhan!.persentaseKeuntungan,
        'isUntung': _summaryKeseluruhan!.isUntung,
        'totalPemeliharaan': _summaryKeseluruhan!.totalPemeliharaanRecords,
        'totalPanen': _summaryKeseluruhan!.totalPanenRecords,
        'totalKebun': _summaryKeseluruhan!.totalKebun,
        'isFiltered': false,
        'kebunLokasi': '',
        'luasKebun': _summaryKeseluruhan!.totalLuasKebun,
        'totalPemeliharaanRecords':
            _summaryKeseluruhan!.totalPemeliharaanRecords,
        'rataRataBiaya': 0.0,
        'totalJumlahKg': _summaryKeseluruhan!.totalKg,
        'hargaRataPerKg': _summaryKeseluruhan!.hargaPerKg,
      };
    } else {
      // Fallback jika tidak ada data
      result = {
        'totalBiayaPemeliharaan': 0,
        'totalPendapatan': 0,
        'totalKeuntungan': 0,
        'persentaseKeuntungan': 0.0,
        'isUntung': false,
        'totalPemeliharaan': 0,
        'totalPanen': 0,
        'totalKebun': 0,
        'isFiltered': false,
        'kebunLokasi': '',
        'luasKebun': '0 Ha',
        'totalPemeliharaanRecords': 0,
        'totalJumlahKg': 0,
        'rataRataBiaya': 0.0,
        'hargaRataPerKg': 0.0,
      };
    }

    return result;
  }

  // Calculate total pages for summary pagination

  int _calculateTotalPages() {
    // Debug print
    print(
      '🔍 [VM] Calculating total pages - hasData: $hasData, hasSummary: $hasSummary',
    );

    // 🎯 Logic untuk 2 halaman
    if (hasSummary || hasData) {
      print('🔍 [VM] Has data, returning 2 pages');
      return 2; // KEUANGAN + DETAIL
    } else {
      print('🔍 [VM] No data, returning 1 page');
      return 1; // Hanya KEUANGAN
    }
  }

  // Set summary page for paginationvm.displaySummary
  void setSummaryPage(int page) {
    print('🔍 [VM] setSummaryPage called with page: $page');
    print(
      '🔍 [VM] Current page: $_summaryCurrentPage, Total pages: ${_calculateTotalPages()}',
    );

    final totalPages = _calculateTotalPages();
    if (page >= 0 && page < totalPages) {
      _summaryCurrentPage = page;
      print('🔍 [VM] Page set to: $_summaryCurrentPage');
      notifyListeners();
    } else {
      print('🔍 [VM] Invalid page: $page, valid range: 0-${totalPages - 1}');
    }
  }

  // Reset laporan data tapi pertahankan summary keseluruhan
  void resetLaporanData() {
    print('🔄 [LAPORAN_VM] Resetting laporan data...');

    _currentLaporan = null;
    _selectedKebun = null;
    _tanggalDari = null;
    _tanggalSampai = null;
    _isFilterActive = false;
    _errorMessage = '';
    _summaryCurrentPage = 0; // Reset pagination

    // Clear form controllers
    tanggalDariController.clear();
    tanggalSampaiController.clear();

    notifyListeners();
    print('✅ [LAPORAN_VM] Laporan data reset completed');
  }

  // Initialize dengan summary keseluruhan
  Future<void> initialize({bool shouldReset = false}) async {
    print(
      '🚀 [LAPORAN_VM] Initialize laporan view model (reset: $shouldReset)',
    );

    if (shouldReset) {
      resetLaporanData();
    }

    _setLoading(true);
    _clearError();

    try {
      // Load available kebun
      await _loadAvailableKebun();

      // Load summary keseluruhan
      await _loadSummaryKeseluruhan();

      _needsDataReload = false;
      print('✅ [LAPORAN_VM] Initialize completed successfully');
    } catch (e) {
      print('💥 [LAPORAN_VM] Initialize error: $e');
      _setError('Gagal memuat data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load summary keseluruhan
  Future<void> _loadSummaryKeseluruhan() async {
    print('📊 [LAPORAN_VM] Loading overall summary...');

    _setLoadingSummary(true);

    try {
      final response = await _laporanRepository.getSummaryKeseluruhan();

      if (response.isSuccess && response.data != null) {
        _summaryKeseluruhan = response.data!;
        print('✅ [LAPORAN_VM] Summary keseluruhan loaded successfully');
        print('   - Total Kebun: ${_summaryKeseluruhan!.totalKebun}');
        print(
          '   - Total Biaya: ${_summaryKeseluruhan!.totalBiayaPemeliharaan}',
        );
        print('   - Total Pendapatan: ${_summaryKeseluruhan!.totalPendapatan}');
        print('   - Total Keuntungan: ${_summaryKeseluruhan!.totalKeuntungan}');
      } else {
        print('❌ [LAPORAN_VM] Failed to load summary: ${response.message}');
        // Don't set error for summary failure, just log it
      }
    } catch (e) {
      print('💥 [LAPORAN_VM] Error loading summary: $e');
    } finally {
      _setLoadingSummary(false);
    }
  }

  // Load available kebun for selection
  Future<void> _loadAvailableKebun() async {
    print('📋 [LAPORAN_VM] Loading available kebun...');

    _setLoadingKebun(true);

    try {
      final response = await _laporanRepository.getAvailableKebun();

      if (response.isSuccess && response.data != null) {
        _availableKebun = response.data!;
        print(
          '✅ [LAPORAN_VM] Successfully loaded ${_availableKebun.length} kebun',
        );
      } else {
        _setError(response.message ?? 'Gagal memuat daftar kebun');
        print('❌ [LAPORAN_VM] Failed to load kebun: ${response.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [LAPORAN_VM] Error loading kebun: $e');
    } finally {
      _setLoadingKebun(false);
    }
  }

  // Reload summary keseluruhan (untuk refresh)
  Future<void> reloadSummaryKeseluruhan() async {
    await _loadSummaryKeseluruhan();
  }

  // Generate laporan dengan filter
  Future<bool> generateLaporan() async {
    if (!canGenerateReport) {
      _setError('Pilih kebun untuk generate laporan');
      return false;
    }

    print('📊 [LAPORAN_VM] Generating laporan...');
    print('   - Kebun: ${_selectedKebun!.nama}');
    print(
      '   - Tanggal: ${_tanggalDari?.toString()} - ${_tanggalSampai?.toString()}',
    );

    _setLoading(true);
    _clearError();

    try {
      final response = await _laporanRepository.getLaporanData(
        kebunId: _selectedKebun!.id,
        tanggalDari: _tanggalDari,
        tanggalSampai: _tanggalSampai,
      );

      if (response.isSuccess && response.data != null) {
        _currentLaporan = response.data!;
        _isFilterActive = _tanggalDari != null && _tanggalSampai != null;
        _summaryCurrentPage = 0; // Reset to first page when new data loaded

        print('✅ [LAPORAN_VM] Successfully generated laporan');
        print('   - Kebun: ${_currentLaporan!.kebun.nama}');
        print(
          '   - Pemeliharaan: ${_currentLaporan!.pemeliharaan.totalRecords} records',
        );
        print('   - Panen: ${_currentLaporan!.panen.totalRecords} records');
        print('   - Keuntungan: ${_currentLaporan!.summary.totalKeuntungan}');

        return true;
      } else {
        _setError(response.message ?? 'Gagal generate laporan');
        print('❌ [LAPORAN_VM] Failed to generate laporan: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      print('💥 [LAPORAN_VM] Error generating laporan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh current laporan
  Future<void> refreshLaporan() async {
    if (_selectedKebun != null) {
      await generateLaporan();
    } else {
      // Refresh summary keseluruhan jika tidak ada filter
      await reloadSummaryKeseluruhan();
    }
  }

  // Filter methods
  void setSelectedKebun(Kebun? kebun) {
    if (_selectedKebun != kebun) {
      _selectedKebun = kebun;
      _currentLaporan = null; // Clear current laporan when kebun changes
      _summaryCurrentPage = 0; // Reset pagination
      _clearError();
      notifyListeners();
      print('📊 [LAPORAN_VM] Selected kebun: ${kebun?.nama ?? 'None'}');
    }
  }

  void setDateRange(DateTime? dari, DateTime? sampai) {
    if (_laporanRepository.isValidDateRange(dari, sampai)) {
      _tanggalDari = dari;
      _tanggalSampai = sampai;

      // Update controllers
      tanggalDariController.text = dari != null
          ? _formatDateForDisplay(dari)
          : '';
      tanggalSampaiController.text = sampai != null
          ? _formatDateForDisplay(sampai)
          : '';

      _clearError();
      notifyListeners();
      print('📊 [LAPORAN_VM] Date range set: $dari to $sampai');
    } else {
      _setError('Rentang tanggal tidak valid');
    }
  }

  void clearDateFilter() {
    _tanggalDari = null;
    _tanggalSampai = null;
    tanggalDariController.clear();
    tanggalSampaiController.clear();
    _isFilterActive = false;
    _clearError();
    notifyListeners();
    print('📊 [LAPORAN_VM] Date filter cleared');
  }

  void clearAllFilters() {
    _selectedKebun = null;
    _currentLaporan = null;
    _summaryCurrentPage = 0;
    clearDateFilter();
    _clearError();
    notifyListeners();
    print('📊 [LAPORAN_VM] All filters cleared');
  }

  // Quick date range methods
  void setThisMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Pastikan tidak melebihi hari ini
    final endDate = lastDayOfMonth.isAfter(now) ? now : lastDayOfMonth;

    setDateRange(firstDayOfMonth, endDate);
  }

  void setThisYear() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);

    // Gunakan hari ini sebagai batas akhir, bukan 31 Desember
    setDateRange(firstDayOfYear, now);
  }

  void setLast30Days() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    setDateRange(thirtyDaysAgo, now);
  }

  void setLast3Months() {
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    setDateRange(threeMonthsAgo, now);
  }

  // Helper methods untuk kategori performa keseluruhan
  //Persentase Keuntungan = (Keuntungan / Biaya Pemeliharaan) × 100%
  String _getOverallPerformanceCategory() {
    if (_summaryKeseluruhan == null) return 'Belum ada data';

    final summary = _summaryKeseluruhan!;
    if (summary.totalBiayaPemeliharaan == 0 && summary.totalPendapatan == 0) {
      return 'Belum ada aktivitas';
    }

    if (summary.isUntung) {
      if (summary.persentaseKeuntungan >= 50) {
        return 'Sangat menguntungkan';
      } else if (summary.persentaseKeuntungan >= 20) {
        return 'Menguntungkan';
      } else {
        return 'Cukup menguntungkan';
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

  // Helper methods for UI
  String formatCurrency(int amount) {
    return _laporanRepository.formatCurrency(amount);
  }

  Color getSummaryStatusColor() {
    // Prioritas: filtered summary -> overall summary
    bool isUntung = false;

    if (_currentLaporan != null) {
      isUntung = _currentLaporan!.summary.isUntung;
    } else if (_summaryKeseluruhan != null) {
      isUntung = _summaryKeseluruhan!.isUntung;
    }

    return isUntung ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  }

  IconData getSummaryStatusIcon() {
    // Prioritas: filtered summary -> overall summary
    bool isUntung = false;

    if (_currentLaporan != null) {
      isUntung = _currentLaporan!.summary.isUntung;
    } else if (_summaryKeseluruhan != null) {
      isUntung = _summaryKeseluruhan!.isUntung;
    }

    return isUntung ? Icons.trending_up : Icons.trending_down;
  }

  // Format date for display (DD-MM-YYYY)
  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Validation methods
  String? validateDateRange() {
    if (_tanggalDari != null && _tanggalSampai != null) {
      if (_tanggalDari!.isAfter(_tanggalSampai!)) {
        return 'Tanggal dari tidak boleh lebih besar dari tanggal sampai';
      }
      if (_tanggalSampai!.isAfter(DateTime.now())) {
        return 'Tanggal sampai tidak boleh melebihi hari ini';
      }
    }
    return null;
  }

  // Statistics getters for UI - dengan fallback ke summary keseluruhan
  int get totalPemeliharaanRecords =>
      _currentLaporan?.pemeliharaan.totalRecords ??
      _summaryKeseluruhan?.totalPemeliharaanRecords ??
      0;

  int get totalPanenRecords =>
      _currentLaporan?.panen.totalRecords ??
      _summaryKeseluruhan?.totalPanenRecords ??
      0;

  int get totalBiayaPemeliharaan =>
      _currentLaporan?.summary.totalBiayaPemeliharaan ??
      _summaryKeseluruhan?.totalBiayaPemeliharaan ??
      0;

  int get totalPendapatan =>
      _currentLaporan?.summary.totalPendapatan ??
      _summaryKeseluruhan?.totalPendapatan ??
      0;

  int get totalKeuntungan =>
      _currentLaporan?.summary.totalKeuntungan ??
      _summaryKeseluruhan?.totalKeuntungan ??
      0;

  double get persentaseKeuntungan =>
      _currentLaporan?.summary.persentaseKeuntungan ??
      _summaryKeseluruhan?.persentaseKeuntungan ??
      0.0;

  bool get isUntung =>
      _currentLaporan?.summary.isUntung ??
      _summaryKeseluruhan?.isUntung ??
      false;

  // Export/Print methods placeholder
  Future<void> exportToPDF() async {
    print('📊 [LAPORAN_VM] Export to PDF requested');
    // TODO: Implement PDF export functionality
  }

  Future<void> printLaporan() async {
    print('📊 [LAPORAN_VM] Print laporan requested');
    // TODO: Implement print functionality
  }

  Future<Map<String, dynamic>> downloadPdf() async {
    if (_currentLaporan == null) {
      return {
        'success': false,
        'message': 'Tidak ada data laporan untuk didownload',
      };
    }

    try {
      _isDownloadingPdf = true;
      _downloadErrorMessage = '';
      notifyListeners();

      print('📥 [LAPORAN_VM] Starting PDF download...');

      // Download via repository
      final result = await _laporanRepository.downloadPdf(
        laporanData: _currentLaporan!,
        tanggalDari: _tanggalDari,
        tanggalSampai: _tanggalSampai,
      );

      if (result['success']) {
        print('✅ [LAPORAN_VM] PDF downloaded: ${result['fileName']}');
      }

      return result;
    } catch (e) {
      _downloadErrorMessage = 'Gagal mendownload PDF: ${e.toString()}';
      print('❌ [LAPORAN_VM] Download error: $e');

      return {'success': false, 'message': _downloadErrorMessage};
    } finally {
      _isDownloadingPdf = false;
      notifyListeners();
    }
  }

  void shareLaporan() {
    print('📊 [LAPORAN_VM] Share laporan requested');
    // TODO: Implement share functionality
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingKebun(bool loading) {
    _isLoadingKebun = loading;
    notifyListeners();
  }

  void _setLoadingSummary(bool loading) {
    _isLoadingSummary = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Method to check if we have enough data for meaningful report
  bool get hasMinimumDataForReport {
    if (_currentLaporan != null) {
      return _currentLaporan!.pemeliharaan.totalRecords > 0 ||
          _currentLaporan!.panen.totalRecords > 0;
    }

    // Check dari summary keseluruhan
    if (_summaryKeseluruhan != null) {
      return _summaryKeseluruhan!.totalPemeliharaanRecords > 0 ||
          _summaryKeseluruhan!.totalPanenRecords > 0;
    }

    return false;
  }

  // Get period text for display
  String get periodText {
    if (_currentLaporan?.periode != null) {
      final periode = _currentLaporan!.periode;
      if (periode.tanggalDari != null && periode.tanggalSampai != null) {
        return 'Periode: ${periode.tanggalDari} s/d ${periode.tanggalSampai}';
      }
    }
    return 'Periode: Semua waktu';
  }

  // Get current summary type for UI indicators
  String get summaryType {
    if (_currentLaporan != null) {
      return 'Laporan Kebun: ${_currentLaporan!.kebun.nama}';
    } else if (_summaryKeseluruhan != null) {
      return 'Ringkasan ${_summaryKeseluruhan!.totalKebun} Kebun';
    }
    return 'Belum ada data';
  }

  @override
  void dispose() {
    tanggalDariController.dispose();
    tanggalSampaiController.dispose();
    super.dispose();
  }
}
