import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/panen_models.dart';
import 'package:project_taniapp_ta/views/panen/panen_form_page.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/panen_view_models.dart';
import 'package:project_taniapp_ta/widgets/buttom_navigation/buttom_navigation.dart';
import 'package:project_taniapp_ta/widgets/panen/panen_card.dart';
import 'package:project_taniapp_ta/widgets/skeleton/Skeleton_Screen.dart';
import 'package:project_taniapp_ta/widgets/theme/tema_utama.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanenPage extends StatefulWidget {
  const PanenPage({Key? key}) : super(key: key);

  @override
  State<PanenPage> createState() => _PanenPageState();
}

class _PanenPageState extends State<PanenPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 2; // Panen page index
  String _selectedFilter = 'Semua'; // Filter untuk kebun

  @override
  void initState() {
    super.initState();

    //Delay initial operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(() {
      print('🔄 [PANEN_PAGE] Login state changed - reloading data...');

      //Safe state update
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [PANEN_PAGE] Login state changed - reloading data...');
    _loadData();
  }

  Future<void> _loadInitialData() async {
    await _checkToken();
    if (mounted) {
      await _loadData();
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

    final panenVm = Provider.of<PanenViewModel>(context, listen: false);
    final kebunVm = Provider.of<KebunViewModel>(context, listen: false);

    // Load kebun data untuk dropdown filter dan mapping nama
    await kebunVm.loadAllKebun();
    // Load panen data
    await panenVm.loadAllPanen();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
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
        break; // Stay on panen page
      case 3:
        Navigator.pushReplacementNamed(context, '/pemeliharaan');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
    }
  }

  //Method untuk mendapatkan data panen yang sudah difilter
  List<Panen> _getFilteredPanen(List<Panen> allPanen, List kebunList) {
    return allPanen.where((panen) {
      bool matchesSearch = true;
      bool matchesFilter = true;

      if (_searchQuery.isNotEmpty) {
        final kebunName = _getKebunName(panen.kebunId, kebunList);

        // Search by jumlah panen
        final jumlahStr = panen.jumlah.toString();
        final formattedJumlah = _formatNumberWithDots(panen.jumlah);

        matchesSearch =
            kebunName.toLowerCase().contains(_searchQuery) ||
            panen.catatan?.toLowerCase().contains(_searchQuery) == true ||
            // Search by jumlah (support format asli & format dengan titik)
            jumlahStr.contains(_searchQuery) ||
            formattedJumlah.contains(_searchQuery);
      }

      // Kebun filter
      if (_selectedFilter != 'Semua') {
        matchesFilter = panen.kebunId.toString() == _selectedFilter;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  //Method untuk mendapatkan data panen yang sudah difilter
  Map<String, dynamic> _calculateFilteredStatistics(List<Panen> filteredPanen) {
    if (filteredPanen.isEmpty) {
      return {
        'totalPanen': 0,
        'totalJumlah': 0,
        'totalNilai': 0,
        'rataRataHarga': 0.0,
      };
    }

    final totalPanen = filteredPanen.length;
    final totalJumlah = filteredPanen.fold<int>(
      0,
      (sum, panen) => sum + panen.jumlah,
    );
    final totalNilai = filteredPanen.fold<int>(
      0,
      (sum, panen) => sum + (panen.jumlah * panen.harga),
    );
    final rataRataHarga = totalJumlah > 0 ? totalNilai / totalJumlah : 0.0;
    return {
      'totalPanen': totalPanen,
      'totalJumlah': totalJumlah,
      'totalNilai': totalNilai,
      'rataRataHarga': rataRataHarga,
    };
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
                        type: SkeletonType.list, // Gunakan skeleton yang sama
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
                            _buildPanenContent(),
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
          child: PanenFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // PANEN-SPECIFIC: Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.agriculture_outlined,
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
                  'Kelola Panen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Catat hasil panen pertanian Anda',
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
    return Consumer<KebunViewModel>(
      builder: (context, kebunVm, child) {
        final bool isFilterActive = _selectedFilter != 'Semua';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            children: [
              // Search Bar - Expanded untuk mengambil ruang tersisa
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24), // Bentuk pill
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
                      hintText: 'Cari panen...',
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
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  // Background hijau tua saat filter aktif
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
                  // shadow saat filter aktif untuk efek elevated
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
                    onTap: () => _showFilterDialog(kebunVm),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.tune,
                          // Icon putih terang untuk visibility yang lebih baik
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

  //Method untuk menampilkan filter dialog
  void _showFilterDialog(KebunViewModel kebunVm) {
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
                        'Filter Panen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih kebun untuk menyaring data panen',
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
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              isDense: true,
                              isExpanded: true,
                              hint: const Text(
                                'Pilih Kebun',
                                style: TextStyle(fontSize: 14),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: 'Semua',
                                  child: Text('Semua Kebun'),
                                ),
                                ...kebunVm.kebunList.map((kebun) {
                                  return DropdownMenuItem<String>(
                                    value: kebun.id.toString(),
                                    child: Text(
                                      kebun.nama,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilter = value ?? 'Semua';
                                });
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
                if (_selectedFilter != 'Semua')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'Semua';
                        });
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

                if (_selectedFilter != 'Semua') const SizedBox(width: 12),

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
    return Consumer2<PanenViewModel, KebunViewModel>(
      builder: (context, panenVm, kebunVm, child) {
        final filteredPanen = _getFilteredPanen(
          panenVm.panenList,
          kebunVm.kebunList,
        );
        final filteredStats = _calculateFilteredStatistics(filteredPanen);

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
                    // Total Panen Section
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
                                'Data panen Anda dalam satu tampilan',
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.agriculture_outlined,
                        label: 'Panen',
                        value: filteredStats['totalPanen'].toString(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.scale_outlined,
                        label: 'Total Kg',
                        value: formatNumber(filteredStats['totalJumlah']),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.trending_up,
                        label: 'Rata Harga',
                        value: filteredStats['rataRataHarga'] > 0
                            ? 'Rp ${formatNumber((filteredStats['rataRataHarga'] as double).round())}'
                            : 'Rp 0',
                      ),
                    ),
                  ],
                ),

                // Total Nilai dalam container memanjang
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
                          Icons.monetization_on_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Nilai: ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rp ${formatNumber(filteredStats['totalNilai'])}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk compact stat item (diperkecil untuk 3 item)
  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 2,
      ), // Padding lebih kecil
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

  // PANEN-SPECIFIC: Panen content
  Widget _buildPanenContent() {
    return Consumer2<PanenViewModel, KebunViewModel>(
      builder: (context, panenVm, kebunVm, child) {
        print(
          '🔍 [PANEN_CONTENT] Loading: ${panenVm.isLoading}, Error: ${panenVm.hasError}',
        );
        print('🔍 [PANEN_CONTENT] Data count: ${panenVm.panenList.length}');

        if (panenVm.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (panenVm.hasError) {
          return _buildErrorSection(panenVm);
        }

        // method terpusat untuk filtering
        final filteredPanen = _getFilteredPanen(
          panenVm.panenList,
          kebunVm.kebunList,
        );

        if (filteredPanen.isEmpty) {
          return _buildEmptySection();
        }

        return _buildPanenList(filteredPanen, kebunVm.kebunList);
      },
    );
  }

  // Helper method untuk mendapatkan nama kebun
  String _getKebunName(int kebunId, List kebunList) {
    try {
      final kebun = kebunList.firstWhere((k) => k.id == kebunId);
      return kebun.nama;
    } catch (e) {
      return 'Kebun ID: $kebunId';
    }
  }

  // PANEN-SPECIFIC: Error section
  Widget _buildErrorSection(PanenViewModel vm) {
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
              onPressed: () => vm.loadAllPanen(),
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

  // PANEN-SPECIFIC: Empty section
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
                    Icons.agriculture_outlined,
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
                        'Belum ada data panen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catat hasil panen pertama Anda',
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

  // PANEN-SPECIFIC: Panen list
  Widget _buildPanenList(List<Panen> filteredPanen, List kebunList) {
    print('🔍 [PANEN_PAGE] Displaying ${filteredPanen.length} panen:');
    for (int i = 0; i < filteredPanen.length && i < 3; i++) {
      print(
        '  $i. ID: ${filteredPanen[i].id}, Date: ${filteredPanen[i].tanggal}',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredPanen.asMap().entries.map((entry) {
            int index = entry.key;
            Panen panen = entry.value;
            String kebunNama = _getKebunName(panen.kebunId, kebunList);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PanenCard(
                panen: panen,
                kebunNama: kebunNama,
                onTap: () => _showPanenDetail(panen, kebunNama),
                onEdit: () => _handleEdit(context, panen),
                onDelete: () => _handleDelete(context, panen),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToForm(BuildContext context, {Panen? panen}) {
    final panenVm = Provider.of<PanenViewModel>(context, listen: false);

    // Clear form state sebelum navigasi
    if (panen == null) {
      // Mode tambah baru - clear semua state
      panenVm.clearForm();
    } else {
      // Mode edit - set data panen
      panenVm.setSelectedPanen(panen);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PanenFormPage(panen: panen)),
    ).then((_) {
      // Refresh data setelah kembali
      _loadData();
      // Clear form setelah kembali dari form
      panenVm.clearForm();
    });
  }

  void _showPanenDetail(Panen panen, String kebunNama) {
    // Gunakan format manual
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    // Format: DD-MM-YYYY
    String formatDate(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
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
                    Icons.agriculture_outlined,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Panen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        kebunNama,
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

            // Detail content
            _buildDetailRow('Tanggal Panen', formatDate(tanggalPanen)),
            _buildDetailRow('Jumlah Panen', '${formatNumber(panen.jumlah)} Kg'),
            _buildDetailRow('Harga per Kg', 'Rp ${formatNumber(panen.harga)}'),
            _buildDetailRow(
              'Total Nilai',
              'Rp ${formatNumber(panen.totalNilai)}',
            ),

            if (panen.catatan != null && panen.catatan!.isNotEmpty) ...[
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
                  panen.catatan!,
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

  void _handleDelete(BuildContext context, Panen panen) async {
    // Tampilkan confirmation dialog
    final bool? shouldDelete = await _showDeleteConfirmation(context, panen);

    if (shouldDelete == true) {
      final vm = Provider.of<PanenViewModel>(context, listen: false);
      final success = await vm.deletePanen(panen.id);

      if (mounted) {
        if (success) {
          // Format tanggal manual
          DateTime tanggalPanen;
          try {
            tanggalPanen = DateTime.parse(panen.tanggal);
          } catch (e) {
            tanggalPanen = DateTime.now();
          }

          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des',
          ];
          String formattedDate =
              '${tanggalPanen.day} ${months[tanggalPanen.month - 1]} ${tanggalPanen.year}';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Panen tanggal $formattedDate berhasil dihapus'),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _handleEdit(BuildContext context, Panen panen) async {
    // Tampilkan confirmation dialog
    final bool? shouldEdit = await _showEditConfirmation(context, panen);

    if (shouldEdit == true) {
      // Navigasi ke form edit
      _navigateToForm(context, panen: panen);
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Panen panen) {
    // Format tanggal manual
    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
    }
    String formattedDate =
        '${tanggalPanen.day.toString().padLeft(2, '0')}-'
        '${tanggalPanen.month.toString().padLeft(2, '0')}-'
        '${tanggalPanen.year}';

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
              'Hapus Panen?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Panen tanggal $formattedDate akan dihapus permanen',
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

  Future<bool?> _showEditConfirmation(BuildContext context, Panen panen) {
    // Format tanggal manual
    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
    }

    String formattedDate =
        '${tanggalPanen.day.toString().padLeft(2, '0')}-'
        '${tanggalPanen.month.toString().padLeft(2, '0')}-'
        '${tanggalPanen.year}';

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
              'Edit Panen?', // ✅ Judul edit
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                const Text(
                  'Anda akan mengedit data panen tanggal',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
}

// Floating Action Button untuk panen
class PanenFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PanenFloatingActionButton({Key? key, this.onPressed}) : super(key: key);

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
