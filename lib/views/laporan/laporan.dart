import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/widgets/buttom_navigation/buttom_navigation.dart';
import 'package:project_taniapp_ta/widgets/laporan/laporan_konten.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewsModels/laporan_view_models.dart';
import '../../viewsModels/login_view_models.dart';
import '../../models/app_constants.dart';
import '../../widgets/skeleton/skeleton_screen.dart';
import '../../widgets/theme/tema_utama.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  bool _isLoading = true;
  int _currentIndex = 4;
  bool _isFirstLoad = true;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    _loadData(shouldReset: true);
  }

  Future<void> _loadInitialData() async {
    await _checkToken();
    if (mounted) {
      await _loadData(shouldReset: true);
    }
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

    if (token == null || token.isEmpty || !isLoggedIn) {
      if (mounted) {
        await prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
  }

  Future<void> _loadData({bool shouldReset = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vm = Provider.of<LaporanViewModel>(context, listen: false);
      final needsReset = shouldReset || _isFirstLoad || vm.needsDataReload;
      await vm.initialize(shouldReset: needsReset);
      _isFirstLoad = false;
    } catch (e) {
      print('💥 [LAPORAN_PAGE] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstLoad && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(shouldReset: true);
      });
    }
  }

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/kebun');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/pemeliharaan');
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? Stack(
                children: [
                  AuthBackgroundCore(child: Container()),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        bottom: 110 + bottomPadding,
                      ),
                      child: const SkeletonScreen(
                        type: SkeletonType.list,
                        itemCount: 4,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomPadding + 10,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 1),
                      child: CustomBottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: _handleNavigation,
                      ),
                    ),
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadData(shouldReset: true);
                },
                color: const Color(AppColors.primaryGreen),
                child: Stack(
                  children: [
                    AuthBackgroundCore(child: Container()),

                    // Full screen scroll view
                    Positioned.fill(
                      child: Consumer<LaporanViewModel>(
                        builder: (context, viewModel, child) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 12,
                              bottom: 110 + bottomPadding,
                            ),
                            child: Column(
                              children: [
                                // Header terpisah (tanpa container)
                                _buildHeader(viewModel),

                                const SizedBox(height: 16),

                                // Content area
                                LaporanContentWidget(viewModel: viewModel),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Navigation (Fixed at bottom)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomPadding + 10,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 1),
                        child: CustomBottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: _handleNavigation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(LaporanViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.assessment_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Analisa performa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //  Tombol Filter
                IconButton(
                  onPressed: () => _showFilterModal(viewModel),
                  icon: Icon(
                    Icons.tune_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(),
                ),
                // ✅ Divider vertikal
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                // Tombol Download
                IconButton(
                  onPressed: viewModel.hasData && !viewModel.isDownloadingPdf
                      ? () => _handleDownloadPdf(viewModel)
                      : null,
                  icon: viewModel.isDownloadingPdf
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.cloud_download_outlined,
                          color: viewModel.hasData
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          size: 24,
                        ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(LaporanViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // ✅ TAMBAHKAN StatefulBuilder
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header (tetap sama)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pilih kebun dan periode untuk analisa',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Kebun Dropdown (tetap sama)
                const Text(
                  'Pilih Kebun',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C5F2D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: viewModel.isLoadingKebun
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          value: viewModel.selectedKebun?.id,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            isDense: false,
                          ),
                          hint: Text(
                            'Pilih kebun untuk analisa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: Colors.grey.shade600,
                          ),
                          items: viewModel.availableKebun.map((kebun) {
                            return DropdownMenuItem<int>(
                              value: kebun.id,
                              child: Text(
                                kebun.nama,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              final selectedKebun = viewModel.availableKebun
                                  .firstWhere((kebun) => kebun.id == value);
                              viewModel.setSelectedKebun(selectedKebun);
                              setModalState(() {}); // ✅ Update modal state
                            }
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Period Section
                Row(
                  children: [
                    const Text(
                      'Periode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C5F2D),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        // ✅ PERBAIKAN: Tambahkan await dan setModalState
                        await _selectDateRange(viewModel);
                        setModalState(
                          () {},
                        ); // ✅ Update modal state setelah pilih tanggal
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pilih Tanggal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Quick Date Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickDateButton(
                        'Bulan Ini',
                        viewModel.isFilterActive &&
                            viewModel.dateRangeText.contains('Bulan'),
                        () {
                          viewModel.setThisMonth();
                          setModalState(() {}); // ✅ Update modal state
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickDateButton(
                        'Tahun Ini',
                        viewModel.isFilterActive &&
                            viewModel.dateRangeText.contains('Tahun'),
                        () {
                          viewModel.setThisYear();
                          setModalState(() {}); // ✅ Update modal state
                        },
                      ),
                    ),
                  ],
                ),

                // ✅ PERBAIKAN: Custom Date Display dengan real-time update
                if (viewModel.tanggalDari != null &&
                    viewModel.tanggalSampai != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatDate(viewModel.tanggalDari!)} - ${_formatDate(viewModel.tanggalSampai!)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2C5F2D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // ✅ PERBAIKAN: Clear date filter DAN update modal state
                            viewModel.clearDateFilter();
                            setModalState(
                              () {},
                            ); // ✅ CRITICAL: Rebuild modal UI
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          viewModel.clearAllFilters();
                          viewModel.reloadSummaryKeseluruhan();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Filter telah direset'),
                                ],
                              ),
                              backgroundColor: Color(0xFF4CAF50),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text(
                          'Hapus Filter',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFFF5722)),
                          foregroundColor: const Color(0xFFFF5722),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (viewModel.canGenerateReport) {
                            _generateReport(viewModel);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                        ),
                        child: const Text(
                          'Terapkan Filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickDateButton(
    String text,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFF4CAF50), width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(LaporanViewModel viewModel) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          viewModel.tanggalDari != null && viewModel.tanggalSampai != null
          ? DateTimeRange(
              start: viewModel.tanggalDari!,
              end: viewModel.tanggalSampai!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(AppColors.primaryGreen),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _generateReport(LaporanViewModel viewModel) async {
    final success = await viewModel.generateLaporan();

    if (!mounted) return;

    if (success) {
      //Customized SnackBar dengan positioning dan duration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Data laporan berhasil dimuat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(AppColors.successGreen),

          //  DURASI: Berapa lama ditampilkan
          duration: const Duration(seconds: 2),

          behavior: SnackBarBehavior.floating,

          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.12,
            left: 16,
            right: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          elevation: 6,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ ${viewModel.errorMessage}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(AppColors.errorRed),
          duration: const Duration(seconds: 3), // Error lebih lama
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.12,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 6,
        ),
      );
    }
  }

  Future<void> _handleDownloadPdf(LaporanViewModel viewModel) async {
    // ✅ VALIDASI 1: Cek ada data atau tidak
    if (!viewModel.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tidak ada data laporan untuk didownload',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // ✅ VALIDASI 2: Tampilkan confirmation dialog
    final bool? shouldDownload = await _showDownloadConfirmation(
      context,
      viewModel,
    );

    // ✅ Jika user klik "Batal" atau close modal
    if (shouldDownload != true) {
      print('🚫 [LAPORAN_PAGE] Download cancelled by user');
      return;
    }

    // ✅ PROSES DOWNLOAD
    print('📥 [LAPORAN_PAGE] User confirmed download, starting...');

    final result = await viewModel.downloadPdf();

    if (!mounted) return;

    if (result['success']) {
      // ✅ Success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PDF Berhasil Diunduh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['fileName'],
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Cek folder Download',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // ✅ Error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(result['message'])),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<bool?> _showDownloadConfirmation(
    BuildContext context,
    LaporanViewModel viewModel,
  ) {
    // Get laporan info
    final kebunName = viewModel.currentLaporan?.kebun.nama ?? 'Laporan';
    final periode = viewModel.dateRangeText;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Icon(
              Icons.cloud_download_outlined,
              size: 64,
              color: Colors.blue.shade400,
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Unduh Laporan PDF?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Subtitle with details
            Column(
              children: [
                Text(
                  'Laporan "$kebunName" akan diunduh',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  periode,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Statistics summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDownloadStatItem(
                        icon: Icons.agriculture,
                        label: 'Panen',
                        value: '${viewModel.totalPanenRecords}',
                        color: const Color(0xFF4CAF50),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.blue.shade200,
                      ),
                      _buildDownloadStatItem(
                        icon: Icons.grass,
                        label: 'Pemeliharaan',
                        value: '${viewModel.totalPemeliharaanRecords}',
                        color: const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batal', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
