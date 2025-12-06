import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/models/pemeliharaan_models.dart';
import 'package:project_taniapp_ta/views/pemeliharaan/pemeliharaan_form_page.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/pemeiharaan_view_models.dart';
import 'package:project_taniapp_ta/widgets/buttom_navigation/buttom_navigation.dart';
import 'package:project_taniapp_ta/widgets/pemeliharaan/pemeliharaan_card.dart';
import 'package:project_taniapp_ta/widgets/skeleton/Skeleton_Screen.dart';
import 'package:project_taniapp_ta/widgets/theme/tema_utama.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemeliharaanPage extends StatefulWidget {
  const PemeliharaanPage({Key? key}) : super(key: key);

  @override
  State<PemeliharaanPage> createState() => _PemeliharaanPageState();
}

class _PemeliharaanPageState extends State<PemeliharaanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 3; // Pemeliharaan page index
  // String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();

    //Delay initial operations (sama seperti panen_page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      print('🔄 [PEMELIHARAAN_PAGE] Login state changed - reloading data...');

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [PEMELIHARAAN_PAGE] Login state changed - reloading data...');
    _loadData();
  }

  Future<void> _loadInitialData() async {
    await _checkToken();
    if (mounted) {
      await _loadKebunData();
      await _loadData();
    }
  }

  Future<void> _loadKebunData() async {
    if (!mounted) return;

    try {
      final kebunVm = Provider.of<KebunViewModel>(context, listen: false);
      // Load kebun list untuk dropdown filter
      if (kebunVm.kebunList.isEmpty) {
        print('🌿 [PEMELIHARAAN_PAGE] Loading kebun list for dropdown...');
        await kebunVm.loadAllKebun();
        print(
          '✅ [PEMELIHARAAN_PAGE] Loaded ${kebunVm.kebunList.length} kebun for dropdown',
        );
      }
    } catch (e) {
      print('💥 [PEMELIHARAAN_PAGE] Error loading kebun data: $e');
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

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vm = Provider.of<PemeliharaanViewModel>(context, listen: false);

      // Load dengan filter yang aktif (jika ada)
      await vm.loadAllPemeliharaan(
        filterKebunId: vm.selectedKebunIdFilter,
        filterKegiatan: vm.selectedKegiatan == 'Semua'
            ? null
            : vm.selectedKegiatan,
      );
    } catch (e) {
      print('💥 [PEMELIHARAAN_PAGE] Error loading data: $e');
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
    _searchController.dispose();
    super.dispose();
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
                  AuthBackgroundCore(
                    child: Container(),
                  ), // ✅ Gunakan tema_utama
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
                        // ✅ FIX: Nama class yang benar
                        currentIndex: _currentIndex,
                        onTap: _handleNavigation,
                      ),
                    ),
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadData();
                },
                color: const Color(0xFF4CAF50),
                child: Stack(
                  children: [
                    AuthBackgroundCore(child: Container()),
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 12,
                          bottom: 110 + bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildSearchAndFilterSection(),
                            const SizedBox(height: 20),
                            _buildStatisticsCard(),
                            const SizedBox(height: 20),
                            _buildPemeliharaanContent(),
                            const SizedBox(height: 20),
                          ],
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
                ),
              ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 80 + bottomPadding),
          child: PemeliharaanFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.grass_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Pemeliharaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Catat kegiatan pemeliharaan kebun',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Consumer2<PemeliharaanViewModel, KebunViewModel>(
      builder: (context, vm, kebunVm, child) {
        // ✅ Tentukan apakah filter aktif
        final bool isFilterActive =
            vm.selectedKebunIdFilter != null || vm.selectedKegiatan != 'Semua';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            children: [
              // ✅ Search Bar - Expanded untuk mengambil ruang tersisa
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Cari pemeliharaan...',
                      hintStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ Filter Button - Background berubah saat filter aktif
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  // ✅ Background hijau tua saat filter aktif
                  color: isFilterActive
                      ? const Color(0xFF2E7D32) // Hijau tua saat aktif
                      : Colors.white.withOpacity(
                          0.2,
                        ), // Transparan saat tidak aktif
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isFilterActive
                        ? const Color(0xFF2E7D32) // Border hijau tua saat aktif
                        : Colors.white.withOpacity(
                            0.3,
                          ), // Border putih saat tidak aktif
                    width: 1,
                  ),
                  // ✅ Tambahkan shadow saat filter aktif untuk efek elevated
                  boxShadow: isFilterActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFilterDialog(vm, kebunVm),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.tune,
                          // ✅ Icon putih terang untuk visibility yang lebih baik
                          color: isFilterActive
                              ? Colors
                                    .white // Putih saat aktif
                              : Colors.white.withOpacity(
                                  0.9,
                                ), // Semi-transparan saat tidak aktif
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ TAMBAH: Method untuk menampilkan filter dialog
  void _showFilterDialog(PemeliharaanViewModel vm, KebunViewModel kebunVm) {
    showModalBottomSheet(
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
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
                        'Filter Pemeliharaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih filter untuk menyaring data',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Filter Kebun Section
            const Text(
              'Filter Kebun',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_activity_outlined,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: kebunVm.isLoading
                        ? const SizedBox(
                            height: 20,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: vm.selectedKebunIdFilter,
                              isDense: true,
                              isExpanded: true,
                              hint: const Text(
                                'Pilih Kebun',
                                style: TextStyle(fontSize: 14),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Semua Kebun'),
                                ),
                                ...kebunVm.kebunList.map((kebun) {
                                  return DropdownMenuItem<int?>(
                                    value: kebun.id,
                                    child: Text(
                                      kebun.nama,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                vm.setFilterKebun(value);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter Kegiatan Section
            const Text(
              'Filter Kegiatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.grass_outlined,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: vm.selectedKegiatan,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: 'Semua',
                            child: Text('Semua Kegiatan'),
                          ),
                          ...PemeliharaanConstants.jenisKegiatanOptions.map((
                            kegiatan,
                          ) {
                            return DropdownMenuItem(
                              value: kegiatan,
                              child: Text(kegiatan),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            vm.setFilterKegiatan(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Clear Filter Button
                if (vm.selectedKebunIdFilter != null ||
                    vm.selectedKegiatan != 'Semua')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.clearAllFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.clear_all,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          const Text('Hapus Filter'),
                        ],
                      ),
                    ),
                  ),

                if (vm.selectedKebunIdFilter != null ||
                    vm.selectedKegiatan != 'Semua')
                  const SizedBox(width: 12),

                // Apply Filter Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Filter sudah otomatis applied melalui dropdown onChanged
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Terapkan',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Consumer2<PemeliharaanViewModel, KebunViewModel>(
      builder: (context, vm, kebunVm, child) {
        // ✅ Gunakan metadata langsung dari backend
        final totalPemeliharaan = vm.totalPemeliharaan;
        final totalBiaya = vm.totalBiaya;
        final kegiatanTerbanyak = vm.kegiatanTerbanyak;

        String formatNumber(int number) {
          final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
          return number.toString().replaceAllMapped(
            formatter,
            (Match m) => '${m[1]}.',
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Data',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Data pemeliharaan Anda dalam satu tampilan',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ✅ UBAH: Layout 3 item dalam row seperti panen
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.handyman_outlined,
                        label: 'Pemeliharaan',
                        value: totalPemeliharaan.toString(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Total Biaya',
                        value: 'Rp ${formatNumber(totalBiaya)}',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.trending_up,
                        label: 'Terbanyak',
                        value: kegiatanTerbanyak ?? 'Belum Ada',
                      ),
                    ),
                  ],
                ),

                // ✅ TAMBAH: Status filter dalam container memanjang (jika ada filter aktif)
                if (vm.selectedKebunIdFilter != null ||
                    vm.selectedKegiatan != 'Semua') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter: ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _buildFilterStatusText(vm, kebunVm),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ TAMBAH: Method untuk compact stat item (sama seperti panen)
  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _buildFilterStatusText(
    PemeliharaanViewModel vm,
    KebunViewModel kebunVm,
  ) {
    List<String> filters = [];

    if (vm.selectedKebunIdFilter != null) {
      final kebun = kebunVm.kebunList.firstWhere(
        (k) => k.id == vm.selectedKebunIdFilter,
        orElse: () => Kebun(
          id: 0,
          userId: 0,
          nama: 'Kebun',
          lokasi: '',
          luas: '',
          titikTanam: 0,
          waktuBeli: '',
          statusKepemilikan: '',
          statusKebun: '',
        ),
      );
      filters.add(kebun.nama);
    }

    if (vm.selectedKegiatan != 'Semua') {
      filters.add(vm.selectedKegiatan);
    }

    return filters.join(' | ');
  }

  Widget _buildPemeliharaanContent() {
    return Consumer<PemeliharaanViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (vm.hasError) {
          return _buildErrorSection(vm);
        }

        // ✅ Data sudah filtered dari backend, hanya apply search query di client
        final displayedPemeliharaan = _searchQuery.isEmpty
            ? vm.pemeliharaanList
            : vm.pemeliharaanList.where((pemeliharaan) {
                final query = _searchQuery.toLowerCase();
                final kegiatan = pemeliharaan.kegiatan.toLowerCase();
                final namaKebun = (pemeliharaan.namaKebun ?? '').toLowerCase();
                final lokasi = (pemeliharaan.lokasiKebun ?? '').toLowerCase();
                return kegiatan.contains(query) ||
                    namaKebun.contains(query) ||
                    lokasi.contains(query);
              }).toList();

        if (displayedPemeliharaan.isEmpty) {
          return _buildEmptySection();
        }

        return _buildPemeliharaanList(displayedPemeliharaan);
      },
    );
  }

  Widget _buildErrorSection(PemeliharaanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              vm.errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadAllPemeliharaan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToForm(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada data pemeliharaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catat kegiatan pemeliharaan pertama Anda',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add, color: Color(0xFF4CAF50), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPemeliharaanList(List<Pemeliharaan> filteredPemeliharaan) {
    print(
      '🔍 [PEMELIHARAAN_PAGE] Displaying ${filteredPemeliharaan.length} pemeliharaan',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredPemeliharaan.asMap().entries.map((entry) {
            Pemeliharaan pemeliharaan = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PemeliharaanCard(
                pemeliharaan: pemeliharaan,
                onTap: () => _showPemeliharaanDetail(pemeliharaan),
                onEdit: () => _handleEdit(context, pemeliharaan),
                onDelete: () => _handleDelete(context, pemeliharaan),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Pemeliharaan? pemeliharaan}) {
    final vm = Provider.of<PemeliharaanViewModel>(context, listen: false);

    if (pemeliharaan == null) {
      vm.clearForm();
    } else {
      vm.setSelectedPemeliharaan(pemeliharaan);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PemeliharaanFormPage(pemeliharaan: pemeliharaan),
      ),
    ).then((_) {
      _loadData();
      vm.clearForm();
    });
  }

  void _showPemeliharaanDetail(Pemeliharaan pemeliharaan) {
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    String formatDate(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    DateTime tanggalPemeliharaan;
    try {
      tanggalPemeliharaan = DateTime.parse(pemeliharaan.tanggal);
    } catch (e) {
      tanggalPemeliharaan = DateTime.now();
    }

    showModalBottomSheet(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Pemeliharaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pemeliharaan.kegiatan,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Kebun', pemeliharaan.namaKebun ?? '-'),
            _buildDetailRow('Lokasi', pemeliharaan.lokasiKebun ?? '-'),
            _buildDetailRow('Tanggal', formatDate(tanggalPemeliharaan)),
            _buildDetailRow(
              'Jumlah',
              '${pemeliharaan.jumlah.toString()}${pemeliharaan.satuan != null ? ' ${pemeliharaan.satuan}' : ''}',
            ),
            _buildDetailRow('Biaya', 'Rp ${formatNumber(pemeliharaan.biaya)}'),
            if (pemeliharaan.catatan != null &&
                pemeliharaan.catatan!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Catatan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  pemeliharaan.catatan!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, Pemeliharaan pemeliharaan) async {
    final bool? shouldDelete = await _showDeleteConfirmation(
      context,
      pemeliharaan,
    );

    if (shouldDelete == true) {
      final vm = Provider.of<PemeliharaanViewModel>(context, listen: false);
      final success = await vm.deletePemeliharaan(pemeliharaan.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pemeliharaan berhasil dihapus'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        }
      }
    }
  }

  // ✅ TAMBAH: Handler untuk edit dengan confirmation
  void _handleEdit(BuildContext context, Pemeliharaan pemeliharaan) async {
    // ✅ Tampilkan confirmation dialog
    final bool? shouldEdit = await _showEditConfirmation(context, pemeliharaan);

    if (shouldEdit == true) {
      // ✅ Navigasi ke form edit
      _navigateToForm(context, pemeliharaan: pemeliharaan);
    }
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    Pemeliharaan pemeliharaan,
  ) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.delete_forever_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Pemeliharaan?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pemeliharaan "${pemeliharaan.kegiatan}" akan dihapus permanen',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                      backgroundColor: Colors.red.shade600,
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

  // Edit confirmation dialog (setelah _showDeleteConfirmation)
  Future<bool?> _showEditConfirmation(
    BuildContext context,
    Pemeliharaan pemeliharaan,
  ) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.edit_outlined,
              size: 64,
              color: Color(AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Pemeliharaan?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda akan mengedit data pemeliharaan "${pemeliharaan.kegiatan}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                      backgroundColor: Color(AppColors.primaryGreen),
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
        break; // Current page
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

// FAB untuk pemeliharaan
class PemeliharaanFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PemeliharaanFloatingActionButton({Key? key, this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(AppColors.primaryGreen),
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
