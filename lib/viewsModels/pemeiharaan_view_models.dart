import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/repositories/pemeliharaan_repo.dart';
import '../models/pemeliharaan_models.dart';

class PemeliharaanViewModel extends ChangeNotifier {
  final PemeliharaanRepository _pemeliharaanRepository =
      PemeliharaanRepository();

  // State variables
  List<Pemeliharaan> _pemeliharaanList = [];
  Pemeliharaan? _selectedPemeliharaan;
  PemeliharaanMetadata? _metadata;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _statistics = {};

  String _selectedKegiatan = 'Semua';
  int? _selectedKebunId;

  // Form state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController biayaController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  int? _selectedKebunIdForm;
  String? _selectedSatuan;
  bool _isFormLoading = false;

  // Getters
  List<Pemeliharaan> get pemeliharaanList => _pemeliharaanList;
  Pemeliharaan? get selectedPemeliharaan => _selectedPemeliharaan;
  PemeliharaanMetadata? get metadata => _metadata;
  bool get isLoading => _isLoading;
  bool get isFormLoading => _isFormLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  int? get selectedKebunId => _selectedKebunIdForm;
  String? get selectedSatuan => _selectedSatuan;

  // TAMBAH: Filter getters
  String get selectedKegiatan => _selectedKegiatan;
  int? get selectedKebunIdFilter => _selectedKebunId;

  // Statistics getters
  int get totalPemeliharaan => _metadata?.totalRecords ?? 0;
  int get totalBiaya => _metadata?.totalBiaya ?? 0;
  double get rataRataBiaya => (_metadata?.rataRataBiaya ?? 0).toDouble();
  String? get kegiatanTerbanyak => _metadata?.kegiatanTerbanyak;

  // Private setters
  Future<void> loadAllPemeliharaan({
    int? filterKebunId,
    String? filterKegiatan,
  }) async {
    print(
      '🌿 [PEMELIHARAAN_VM] Filters - Kebun: $filterKebunId, Kegiatan: $filterKegiatan',
    );

    _setLoading(true);
    _clearError();

    try {
      final response = await _pemeliharaanRepository.getAllPemeliharaan(
        kebunId: filterKebunId,
        kegiatan: filterKegiatan,
      );

      if (response.isSuccess && response.data != null) {
        print(
          '🔍 [PEMELIHARAAN_VM] Response data keys: ${response.data!.keys}',
        );
        print('🔍 [PEMELIHARAAN_VM] Response data: ${response.data}');
        //  Parse pemeliharaan list dengan debug
        final pemeliharaanData = response.data!['pemeliharaan'];
        print(
          '🔍 [PEMELIHARAAN_VM] Pemeliharaan data type: ${pemeliharaanData.runtimeType}',
        );
        if (pemeliharaanData is List<Pemeliharaan>) {
          _pemeliharaanList = pemeliharaanData;
          print(
            '✅ [PEMELIHARAAN_VM] Direct assignment: ${_pemeliharaanList.length} items',
          );
        } else if (pemeliharaanData is List) {
          print(
            '⚠️ [PEMELIHARAAN_VM] List is not List<Pemeliharaan>, converting...',
          );
          _pemeliharaanList = pemeliharaanData.cast<Pemeliharaan>();
          print(
            '✅ [PEMELIHARAAN_VM] After cast: ${_pemeliharaanList.length} items',
          );
        } else {
          print('❌ [PEMELIHARAAN_VM] Unexpected data type!');
          _pemeliharaanList = [];
        }

        // Debug setiap item
        for (var i = 0; i < _pemeliharaanList.length; i++) {
          final item = _pemeliharaanList[i];
          print(
            '📋 [ITEM $i] ID: ${item.id}, Kegiatan: ${item.kegiatan}, Biaya: ${item.biaya}',
          );
        }

        // ✅ Parse metadata
        if (response.data!['metadata'] != null) {
          try {
            final metadataJson = response.data!['metadata'];
            print('🔍 [PEMELIHARAAN_VM] Metadata JSON: $metadataJson');

            if (metadataJson is PemeliharaanMetadata) {
              _metadata = metadataJson;
            } else if (metadataJson is Map<String, dynamic>) {
              _metadata = PemeliharaanMetadata.fromJson(metadataJson);
            }

            print('📊 [PEMELIHARAAN_VM] Metadata: $_metadata');
          } catch (e) {
            print('❌ [PEMELIHARAAN_VM] Error parsing metadata: $e');
            _metadata = null;
          }
        } else {
          _metadata = null;
        }

        _sortPemeliharaanByDateDesc();

        print(
          '✅ [PEMELIHARAAN_VM] Final list: ${_pemeliharaanList.length} pemeliharaan',
        );
        print('🌿 [PEMELIHARAAN_VM] ========== END LOADING ==========');
        _setLoading(false);
      } else {
        print('❌ [PEMELIHARAAN_VM] Response failed: ${response.message}');
        _setError(response.message ?? 'Gagal memuat data pemeliharaan');
        _pemeliharaanList = [];
        _metadata = null;
        _setLoading(false);
      }
    } catch (e, stackTrace) {
      print('💥 [PEMELIHARAAN_VM] Exception: $e');
      print('📚 [PEMELIHARAAN_VM] Stack trace: $stackTrace');
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      _pemeliharaanList = [];
      _metadata = null;
      _setLoading(false);
    }
  }

  // Method untuk set filter kegiatan
  void setFilterKegiatan(String kegiatan) {
    if (_selectedKegiatan != kegiatan) {
      _selectedKegiatan = kegiatan;
      print('🔍 [PEMELIHARAAN_VM] Filter kegiatan changed to: $kegiatan');
      notifyListeners();

      // Reload data dengan filter baru
      loadAllPemeliharaan(
        filterKebunId: _selectedKebunId,
        filterKegiatan: kegiatan == 'Semua' ? null : kegiatan,
      );
    }
  }

  // Method untuk set filter kebun
  void setFilterKebun(int? kebunId) {
    if (_selectedKebunId != kebunId) {
      _selectedKebunId = kebunId;
      print('🔍 [PEMELIHARAAN_VM] Filter kebun changed to: $kebunId');
      notifyListeners();

      // Reload data dengan filter baru
      loadAllPemeliharaan(
        filterKebunId: kebunId,
        filterKegiatan: _selectedKegiatan == 'Semua' ? null : _selectedKegiatan,
      );
    }
  }

  //Method untuk clear semua filter
  void clearAllFilters() {
    _selectedKegiatan = 'Semua';
    _selectedKebunId = null;
    print('🔄 [PEMELIHARAAN_VM] Clearing all filters');
    notifyListeners();

    loadAllPemeliharaan();
  }

  // method untuk set satuan
  void setSelectedSatuan(String? satuan) {
    if (satuan != null &&
        PemeliharaanConstants.satuanOptions.contains(satuan)) {
      _selectedSatuan = satuan;
    } else {
      _selectedSatuan = null;
    }
    notifyListeners();
  }

  // Sort pemeliharaan by date descending
  void _sortPemeliharaanByDateDesc() {
    _pemeliharaanList.sort((a, b) => a.compareByDateAndId(b));
    print(
      '🔄 [PEMELIHARAAN_VM] Sorted ${_pemeliharaanList.length} pemeliharaan',
    );
  }

  // Get pemeliharaan by ID
  Future<void> getPemeliharaanById(int id) async {
    print('🌿 [PEMELIHARAAN_VM] Getting pemeliharaan by ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _pemeliharaanRepository.getPemeliharaanById(id);

      if (response.isSuccess && response.data != null) {
        _selectedPemeliharaan = response.data!;
        _populateFormFromPemeliharaan(_selectedPemeliharaan!);
        print(
          '✅ [PEMELIHARAAN_VM] Successfully got pemeliharaan: ${_selectedPemeliharaan!.id}',
        );
      } else {
        _setError(response.message ?? 'Pemeliharaan tidak ditemukan');
        print(
          '❌ [PEMELIHARAAN_VM] Failed to get pemeliharaan: ${response.message}',
        );
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      print('💥 [PEMELIHARAAN_VM] Error getting pemeliharaan by ID: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new pemeliharaan
  Future<bool> createPemeliharaan() async {
    print('🌿 [PEMELIHARAAN_VM] Creating new pemeliharaan...');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      String jumlahValue = jumlahController.text.replaceAll('.', '');
      String biayaValue = biayaController.text.replaceAll('.', '');

      final response = await _pemeliharaanRepository.createPemeliharaan(
        kebunId: _selectedKebunIdForm!, // ✅ Gunakan form field
        kegiatan: kegiatanController.text.trim(),
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahValue),
        satuan: _selectedSatuan,
        biaya: int.parse(biayaValue),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print('✅ [PEMELIHARAAN_VM] Successfully created pemeliharaan');
        clearForm();

        // Reload dengan filter yang aktif
        await loadAllPemeliharaan(
          filterKebunId: _selectedKebunId,
          filterKegiatan: _selectedKegiatan == 'Semua'
              ? null
              : _selectedKegiatan,
        );

        return true;
      } else {
        _setError(response.message ?? 'Gagal menambahkan pemeliharaan');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Update pemeliharaan
  Future<bool> updatePemeliharaan(int id) async {
    print('🌿 [PEMELIHARAAN_VM] Updating pemeliharaan ID: $id');

    if (!_validateForm()) {
      return false;
    }

    _setFormLoading(true);
    _clearError();

    try {
      String jumlahValue = jumlahController.text.replaceAll('.', '');
      String biayaValue = biayaController.text.replaceAll('.', '');

      final response = await _pemeliharaanRepository.updatePemeliharaan(
        id: id,
        kebunId: _selectedKebunIdForm!,
        kegiatan: kegiatanController.text.trim(),
        tanggal: tanggalController.text.trim(),
        jumlah: int.parse(jumlahValue),
        satuan: _selectedSatuan,
        biaya: int.parse(biayaValue),
        catatan: catatanController.text.trim().isNotEmpty
            ? catatanController.text.trim()
            : null,
      );

      if (response.isSuccess) {
        print('✅ [PEMELIHARAAN_VM] Successfully updated pemeliharaan');
        clearForm();

        // Reload dengan filter yang aktif
        await loadAllPemeliharaan(
          filterKebunId: _selectedKebunId,
          filterKegiatan: _selectedKegiatan == 'Semua'
              ? null
              : _selectedKegiatan,
        );

        return true;
      } else {
        _setError(response.message ?? 'Gagal mengupdate pemeliharaan');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      return false;
    } finally {
      _setFormLoading(false);
    }
  }

  // Delete pemeliharaan
  Future<bool> deletePemeliharaan(int id) async {
    print('🌿 [PEMELIHARAAN_VM] Deleting pemeliharaan ID: $id');

    _setLoading(true);
    _clearError();

    try {
      final response = await _pemeliharaanRepository.deletePemeliharaan(id);

      if (response.isSuccess) {
        print('✅ [PEMELIHARAAN_VM] Successfully deleted pemeliharaan');

        // Reload dengan filter yang aktif
        await loadAllPemeliharaan(
          filterKebunId: _selectedKebunId,
          filterKegiatan: _selectedKegiatan == 'Semua'
              ? null
              : _selectedKegiatan,
        );

        return true;
      } else {
        _setError(response.message ?? 'Gagal menghapus pemeliharaan');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan sistem: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Form methods
  void setSelectedKebun(int? kebunId) {
    _selectedKebunIdForm = kebunId;
    print('🔧 [PEMELIHARAAN_VM] Selected kebun for form: $kebunId');
    notifyListeners();
  }

  void setSelectedPemeliharaan(Pemeliharaan pemeliharaan) {
    _selectedPemeliharaan = pemeliharaan;
    _populateFormFromPemeliharaan(pemeliharaan);
    notifyListeners();
  }

  void _populateFormFromPemeliharaan(Pemeliharaan pemeliharaan) {
    kegiatanController.text = pemeliharaan.kegiatan;

    try {
      final date = DateTime.parse(pemeliharaan.tanggal);
      tanggalController.text =
          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      tanggalController.text = pemeliharaan.tanggal;
    }

    jumlahController.text = _formatNumber(pemeliharaan.jumlah);
    biayaController.text = _formatNumber(pemeliharaan.biaya);
    catatanController.text = pemeliharaan.catatan ?? '';
    _selectedKebunIdForm = pemeliharaan.kebunId;

    if (pemeliharaan.satuan != null) {
      final normalizedSatuan = PemeliharaanConstants.satuanOptions.firstWhere(
        (option) => option.toLowerCase() == pemeliharaan.satuan!.toLowerCase(),
        orElse: () => '',
      );

      _selectedSatuan = normalizedSatuan.isNotEmpty ? normalizedSatuan : null;
    } else {
      _selectedSatuan = null;
    }
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void clearForm() {
    kegiatanController.clear();
    tanggalController.clear();
    jumlahController.clear();
    biayaController.clear();
    catatanController.clear();
    _selectedKebunIdForm = null;
    _selectedKebunId = null;
    _selectedSatuan = null;
    _selectedPemeliharaan = null;
    _clearError();
    notifyListeners();
  }

  bool _validateForm() {
    if (_selectedKebunIdForm == null || _selectedKebunIdForm! <= 0) {
      _setError('Pilih kebun terlebih dahulu');
      return false;
    }

    if (kegiatanController.text.trim().isEmpty) {
      _setError('Jenis kegiatan harus diisi');
      return false;
    }

    if (tanggalController.text.trim().isEmpty) {
      _setError('Tanggal pemeliharaan harus diisi');
      return false;
    }

    if (jumlahController.text.trim().isEmpty) {
      _setError('Jumlah harus diisi');
      return false;
    }

    String jumlahValue = jumlahController.text.replaceAll('.', '');
    final jumlah = int.tryParse(jumlahValue);
    if (jumlah == null || jumlah <= 0) {
      _setError('Jumlah harus berupa angka positif');
      return false;
    }

    if (biayaController.text.trim().isEmpty) {
      _setError('Biaya harus diisi');
      return false;
    }

    String biayaValue = biayaController.text.replaceAll('.', '');
    final biaya = int.tryParse(biayaValue);
    if (biaya == null || biaya < 0) {
      _setError('Biaya harus berupa angka yang valid');
      return false;
    }

    // Validate date format
    try {
      final tanggalStr = tanggalController.text.trim();

      // Check if format is DD-MM-YYYY
      final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
      if (!datePattern.hasMatch(tanggalStr)) {
        _setError('Format tanggal harus DD-MM-YYYY');
        return false;
      }

      // Parse DD-MM-YYYY format
      final parts = tanggalStr.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate date components
      if (month < 1 || month > 12) {
        _setError('Bulan tidak valid (1-12)');
        return false;
      }

      if (day < 1 || day > 31) {
        _setError('Tanggal tidak valid (1-31)');
        return false;
      }

      // Create DateTime to validate complete date
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        _setError('Tanggal tidak valid');
        return false;
      }
    } catch (e) {
      _setError('Format tanggal tidak valid. Gunakan DD-MM-YYYY');
      return false;
    }

    return true;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    print('🔄 [PEMELIHARAAN_VM] Loading state changed to: $loading');
    notifyListeners();
  }

  void _setFormLoading(bool loading) {
    _isFormLoading = loading;
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

  // Method untuk mendapatkan pemeliharaan terbaru untuk kebun tertentu
  List<Pemeliharaan> getRecentPemeliharaanByKebun(
    int kebunId, {
    int limit = 3,
  }) {
    final filtered = _pemeliharaanList
        .where((pemeliharaan) => pemeliharaan.kebunId == kebunId)
        .toList();

    // Sort by date descending
    filtered.sort(
      (a, b) => DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)),
    );

    return filtered.take(limit).toList();
  }

  // Method untuk mendapatkan total biaya pemeliharaan per kebun
  int getTotalBiayaByKebun(int kebunId) {
    return _pemeliharaanList
        .where((pemeliharaan) => pemeliharaan.kebunId == kebunId)
        .fold(0, (sum, pemeliharaan) => sum + pemeliharaan.biaya);
  }

  @override
  void dispose() {
    _metadata = null;
    formKey.currentState?.dispose();
    kegiatanController.dispose();
    tanggalController.dispose();
    jumlahController.dispose();
    biayaController.dispose();
    catatanController.dispose();
    super.dispose();
  }
}
