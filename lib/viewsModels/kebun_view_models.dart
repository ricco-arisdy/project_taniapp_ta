import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/repositories/kebun_repo.dart';
import 'package:project_taniapp_ta/viewsModels/base_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';

class KebunViewModel extends BaseViewModel {
  late final VoidCallback _loginStateListener;
  final KebunRepository _kebunRepository = KebunRepository();

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController luasController = TextEditingController();
  final TextEditingController titikTanamController = TextEditingController();
  final TextEditingController waktuBeliController = TextEditingController();

  // State variables
  List<Kebun> _kebunList = [];
  Kebun? _selectedKebun;
  String _selectedStatusKepemilikan = '';
  String _selectedStatusKebun = '';
  String _selectedLuas = '';
  bool _isCustomLuas = false;
  DateTime? _selectedDate;
  KebunMetadata? _metadata;

  // Getters
  List<Kebun> get kebunList => _kebunList;
  Kebun? get selectedKebun => _selectedKebun;
  String get selectedStatusKepemilikan => _selectedStatusKepemilikan;
  String get selectedStatusKebun => _selectedStatusKebun;
  String get selectedLuas => _selectedLuas;
  bool get isCustomLuas => _isCustomLuas;
  DateTime? get selectedDate => _selectedDate;
  KebunMetadata? get metadata => _metadata;

  // Statistics
  int get totalKebun => _metadata?.totalRecords ?? 0;
  double get totalLuas => _metadata?.totalLuas ?? 0.0;
  int get totalTitikTanam => _metadata?.totalTitikTanam ?? 0;

  KebunViewModel() {
    _loginStateListener = _handleLoginStateChange;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    print('🔧 [KEBUN_VM] Setting up login listener...');

    // HANYA satu listener - menggunakan reference
    LoginViewModel.logoutNotifier.addListener(_loginStateListener);
  }

  void _handleLoginStateChange() {
    print('🔄 [KEBUN_VM] Handling login state change...');

    // Check if disposed sebelum operasi
    if (!mounted) {
      // Gunakan mounted dari BaseViewModel
      print('⚠️ [KEBUN_VM] Already disposed, skipping state change');
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return; 
      loadAllKebun();
    });
  }

  // void _handleLogout() {
  //   print('🧹 [KEBUN_VM] Handling logout - clearing all state...');

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // Clear all data
  //     _kebunList.clear();
  //     _selectedKebun = null;

  //     // Clear form
  //     clearForm();

  //     // Clear error state
  //     clearError();

  //     // Reset loading state
  //     setLoading(false);

  //     print('✅ [KEBUN_VM] All state cleared after logout');
  //     notifyListeners();
  //   });
  // }

  // Get all kebun
  Future<void> loadAllKebun() async {
    //Early exit if disposed
    if (!mounted) {
      print('⚠️ [KEBUN_VM] Cannot load kebun - ViewModel disposed');
      return;
    }

    print('🌱 [KEBUN_VM] Loading all kebun...');

    final response = await executeAsync(() => _kebunRepository.getAllKebun());

    // Check mounted sebelum update state
    if (!mounted) {
      print(
          '⚠️ [KEBUN_VM] Data loaded but ViewModel disposed - skipping update');
      return;
    }

    if (response?.isSuccess == true && response?.data != null) {
      _kebunList = response!.data!['kebun'] as List<Kebun>? ?? [];
      _metadata = response.data!['metadata'] as KebunMetadata?;

      print('✅ [KEBUN_VM] Successfully loaded ${_kebunList.length} kebun');

      if (_metadata != null) {
        print('📊 [KEBUN_VM] Metadata:');
        print('   - Total: ${_metadata!.totalRecords}');
        print('   - Luas: ${_metadata!.totalLuas}');
      }

      if (hasError) {
        clearError();
      }
    } else {
      _kebunList = [];
      _metadata = null;
      print('❌ [KEBUN_VM] Failed to load kebun: ${response?.message}');
    }

    notifyListeners();
  }

  // Get kebun by ID
  Future<void> loadKebunById(int id) async {
    print('🌱 [KEBUN_VM] Loading kebun by ID: $id');

    final response =
        await executeAsync(() => _kebunRepository.getKebunById(id));
    if (response?.isSuccess == true && response?.data != null) {
      _selectedKebun = response!.data;
      _populateFormFields(_selectedKebun!);
      print('✅ [KEBUN_VM] Successfully loaded kebun: ${_selectedKebun!.nama}');
    } else {
      setError(response?.message ?? 'Gagal memuat detail kebun');
    }
  }

  // Create new kebun
  Future<bool> createKebun() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    print('🌱 [KEBUN_VM] Creating new kebun...');

    String titikTanamValue = titikTanamController.text.replaceAll('.', '');

    final response = await executeAsync(() => _kebunRepository.createKebun(
          nama: namaController.text.trim(),
          lokasi: lokasiController.text.trim(),
          luas: _getFinalLuasValue(),
          titikTanam: int.parse(titikTanamValue),
          waktuBeli: waktuBeliController.text,
          statusKepemilikan: _selectedStatusKepemilikan,
          statusKebun: _selectedStatusKebun,
        ));

    if (response?.isSuccess == true) {
      await loadAllKebun(); // Refresh list
      clearForm();
      print('✅ [KEBUN_VM] Successfully created kebun');
      return true;
    } else {
      setError(response?.message ?? 'Gagal menambahkan kebun');
      return false;
    }
  }

  // Update existing kebun
  Future<bool> updateKebun(int id) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    print('🌱 [KEBUN_VM] Updating kebun ID: $id');

    String titikTanamValue = titikTanamController.text.replaceAll('.', '');

    final response = await executeAsync(() => _kebunRepository.updateKebun(
          id: id,
          nama: namaController.text.trim(),
          lokasi: lokasiController.text.trim(),
          luas: _getFinalLuasValue(),
          titikTanam: int.parse(titikTanamValue),
          waktuBeli: waktuBeliController.text,
          statusKepemilikan: _selectedStatusKepemilikan,
          statusKebun: _selectedStatusKebun,
        ));

    if (response?.isSuccess == true) {
      await loadAllKebun(); // Refresh list
      print('✅ [KEBUN_VM] Successfully updated kebun');
      return true;
    } else {
      setError(response?.message ?? 'Gagal mengupdate kebun');
      return false;
    }
  }

  // Delete kebun
  Future<bool> deleteKebun(int id) async {
    print('🌱 [KEBUN_VM] Deleting kebun ID: $id');

    final response = await executeAsync(() => _kebunRepository.deleteKebun(id));

    if (response?.isSuccess == true) {
      await loadAllKebun();
      print('✅ [KEBUN_VM] Successfully deleted kebun');
      return true;
    } else {
      setError(response?.message ?? 'Gagal menghapus kebun');
      return false;
    }
  }

  void setSelectedKebun(Kebun kebun) {
    print('🔄 [KEBUN_VM] Setting selected kebun: ${kebun.nama}');
    _selectedKebun = kebun;

    namaController.text = kebun.nama;
    lokasiController.text = kebun.lokasi;
    titikTanamController.text = _formatNumber(kebun.titikTanam);

    // ✅ Handle waktu beli
    if (kebun.waktuBeli.isNotEmpty) {
      waktuBeliController.text = kebun.waktuBeli;

      try {
        String dateString = kebun.waktuBeli;
        List<String> parts;

        if (dateString.contains('-')) {
          parts = dateString.split('-');
        } else if (dateString.contains('/')) {
          parts = dateString.split('/');
          waktuBeliController.text = '${parts[0]}-${parts[1]}-${parts[2]}';
        } else {
          throw Exception('Format tanggal tidak valid');
        }

        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        print('⚠️ [KEBUN_VM] Error parsing date: $e');
        _selectedDate = null;
      }
    } else {
      waktuBeliController.clear();
      _selectedDate = null;
    }

    _selectedStatusKepemilikan = kebun.statusKepemilikan;
    _selectedStatusKebun = kebun.statusKebun;

    //Handle luas dengan lebih aman
    final luasValue = kebun.luas.trim();

    print('🔍 [KEBUN_VM] Processing luas value: "$luasValue"');

    if (KebunConstants.luasOptions.contains(luasValue)) {
      // Value ada di predefined options
      _selectedLuas = luasValue;
      _isCustomLuas = false;
      luasController.clear();
      print('✅ [KEBUN_VM] Luas found in predefined options: $luasValue');
    } else {
      // Value custom (tidak ada di options)
      _selectedLuas = 'Lainnya';
      _isCustomLuas = true;
      luasController.text = luasValue;
      print('✅ [KEBUN_VM] Luas set as custom: $luasValue');
    }

    print('✅ [KEBUN_VM] Selected kebun set successfully');
    print('   - Selected Luas: $_selectedLuas');
    print('   - Is Custom: $_isCustomLuas');
    print('   - Controller Value: ${luasController.text}');

    notifyListeners();
  }

  // Form field setters
  void setStatusKepemilikan(String? status) {
    _selectedStatusKepemilikan = status ?? '';
    notifyListeners();
  }

  void setStatusKebun(String? status) {
    _selectedStatusKebun = status ?? '';
    notifyListeners();
  }

  void setLuas(String? luas) {
    _selectedLuas = luas ?? '';
    _isCustomLuas = luas == 'Lainnya';

    if (!_isCustomLuas && luas != null && luas != 'Lainnya') {
    } else if (_isCustomLuas) {
    }

    notifyListeners();
  }

  // Date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(AppColors.primaryGreen),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      // Format tanggal ke DD-MM-YYYY dengan dash
      waktuBeliController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      notifyListeners();
    }
  }

  // Clear form
  void clearForm() {
    print('🧹 [KEBUN_VM] Clearing form...');

    namaController.clear();
    lokasiController.clear();
    luasController.clear();
    titikTanamController.clear();
    waktuBeliController.clear();
    _selectedStatusKepemilikan = '';
    _selectedStatusKebun = '';
    _selectedLuas = '';
    _isCustomLuas = false;
    _selectedDate = null;
    _selectedKebun = null;
    clearError();

    print('✅ [KEBUN_VM] Form cleared successfully');
    notifyListeners();
  }

  void resetForm() {
    clearForm(); 
  }

  // Private methods
  void _populateFormFields(Kebun kebun) {
    namaController.text = kebun.nama;
    lokasiController.text = kebun.lokasi;

    // Check if luas is in predefined options
    if (KebunConstants.luasOptions.contains(kebun.luas)) {
      _selectedLuas = kebun.luas;
      _isCustomLuas = false;
      luasController.clear(); 
    } else {
      _selectedLuas = 'Lainnya';
      _isCustomLuas = true;
      luasController.text = kebun.luas;
    }

    titikTanamController.text = kebun.titikTanam.toString();
    _selectedStatusKepemilikan = kebun.statusKepemilikan;
    _selectedStatusKebun = kebun.statusKebun;

    // Handle waktu beli dengan format DD-MM-YYYY (sama seperti setSelectedKebun)
    if (kebun.waktuBeli.isNotEmpty) {
      try {
        String dateString = kebun.waktuBeli;
        List<String> parts;

        // Support kedua format: DD-MM-YYYY dan DD/MM/YYYY
        if (dateString.contains('-')) {
          parts = dateString.split('-');
          waktuBeliController.text = dateString; 
        } else if (dateString.contains('/')) {
          parts = dateString.split('/');
          // Convert format lama ke format baru
          waktuBeliController.text = '${parts[0]}-${parts[1]}-${parts[2]}';
        } else {
          throw Exception('Format tanggal tidak valid');
        }

        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('⚠️ [KEBUN_VM] Error parsing date: $e');
        waktuBeliController.text = kebun.waktuBeli;
        _selectedDate = null;
      }
    } else {
      waktuBeliController.clear();
      _selectedDate = null;
    }

    notifyListeners();
  }

  String formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      List<String> parts;

      // Support kedua format
      if (dateString.contains('-')) {
        return dateString; 
      } else if (dateString.contains('/')) {
        parts = dateString.split('/');
        return '${parts[0]}-${parts[1]}-${parts[2]}'; 
      }

      return dateString;
    } catch (e) {
      print('⚠️ [KEBUN_VM] Error formatting date: $e');
      return dateString;
    }
  }

  String _getFinalLuasValue() {
    return _isCustomLuas ? luasController.text.trim() : _selectedLuas;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void dispose() {
    // Clear metadata saat dispose
    _metadata = null;
    LoginViewModel.logoutNotifier.removeListener(_loginStateListener);
    namaController.dispose();
    lokasiController.dispose();
    luasController.dispose();
    titikTanamController.dispose();
    waktuBeliController.dispose();
    super.dispose();
  }
}
