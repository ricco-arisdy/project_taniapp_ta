import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/views/kebun/kebun_form_page.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/widgets/buttom_navigation/buttom_navigation.dart';
import 'package:project_taniapp_ta/widgets/kebun/kebun_actions.dart';
import 'package:project_taniapp_ta/widgets/kebun/kebun_card.dart';
import 'package:project_taniapp_ta/widgets/skeleton/Skeleton_Screen.dart';
import 'package:project_taniapp_ta/widgets/theme/tema_utama.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KebunPage extends StatefulWidget {
  const KebunPage({Key? key}) : super(key: key);

  @override
  State<KebunPage> createState() => _KebunPageState();
}

class _KebunPageState extends State<KebunPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 1;

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
      print('🔄 [KEBUN_PAGE] Login state changed - reloading data...');

      // Safe state update
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      }
    });
  }

  void _handleLoginStateChange() {
    print('🔄 [KEBUN_PAGE] Login state changed - reloading data...');
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

    final vm = Provider.of<KebunViewModel>(context, listen: false);
    await vm.loadAllKebun();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
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
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/pemeliharaan');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/laporan');
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
                  final vm = Provider.of<KebunViewModel>(
                    context,
                    listen: false,
                  );
                  await vm.loadAllKebun();
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
                            _buildSearchSection(),
                            const SizedBox(height: 20),
                            _buildStatisticsCard(),
                            const SizedBox(height: 20),
                            _buildKebunContent(),
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
          child: KebunFloatingActionButton(
            onPressed: () => _navigateToForm(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // Header (same structure as HomePage header)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.local_activity_outlined,
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
                  'Kelola Kebun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Catatan kebun pertanian Anda',
                  style: TextStyle(
                    fontSize: 12,
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

  // Search section (compact version)
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10), // Slightly smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Lighter shadow
              blurRadius: 6, // Reduced blur
              offset: const Offset(0, 2), // Reduced offset
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14), // Smaller text
          decoration: const InputDecoration(
            hintText: 'Cari kebun...',
            hintStyle: TextStyle(fontSize: 14), // Smaller hint text
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              color: Color(0xFF4CAF50),
              size: 20, // Smaller icon
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 4,
            ), // Reduced padding
            isDense: true, // Makes the field more compact
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Consumer<KebunViewModel>(
      builder: (context, vm, child) {
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
                    // Total Kebun Section
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
                                'Seluruh kebun anda dalam satu tampilan',
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
                const SizedBox(height: 15),
                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.local_activity_outlined,
                        label: 'Kebun',
                        value: vm.totalKebun.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.square_foot_rounded,
                        label: 'Luas',
                        value: '${vm.totalLuas.toStringAsFixed(1)}Ha',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactStatItem(
                        icon: Icons.place_rounded,
                        label: 'Titik',
                        value: _formatNumberWithDots(vm.totalTitikTanam),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Content section (similar to HomePage quick actions)
  Widget _buildKebunContent() {
    return Consumer<KebunViewModel>(
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
        // Search dengan lebih banyak field
        final filteredKebun = vm.kebunList.where((kebun) {
          final query = _searchQuery.toLowerCase();

          // Search by nama kebun
          if (kebun.nama.toLowerCase().contains(query)) return true;

          // Search by lokasi
          if (kebun.lokasi.toLowerCase().contains(query)) return true;

          // Search by luas
          if (kebun.luas
              .toLowerCase()
              .replaceAll(' ', '')
              .contains(query.replaceAll(' ', '')))
            return true;

          // Search by status kepemilikan
          if (kebun.statusKepemilikan.toLowerCase().contains(query))
            return true;

          // Search by status kebun
          if (kebun.statusKebun.toLowerCase().contains(query)) return true;

          // Search by titik tanam
          final titikTanamStr = kebun.titikTanam.toString();
          final formattedTitikTanam = _formatNumberWithDots(kebun.titikTanam);
          if (titikTanamStr.contains(query) ||
              formattedTitikTanam.contains(query))
            return true;

          // Search by waktu beli
          if (kebun.waktuBeli.toLowerCase().contains(query)) return true;

          return false;
        }).toList();

        if (filteredKebun.isEmpty) {
          return _buildEmptySection();
        }

        return _buildKebunList(filteredKebun);
      },
    );
  }

  //Error section (similar to HomePage empty sections)
  Widget _buildErrorSection(KebunViewModel vm) {
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
              onPressed: () => vm.loadAllKebun(),
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

  // Empty section (same structure as HomePage empty sections)
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
                    Icons.grass_outlined,
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
                        'Belum ada kebun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5F2D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tambahkan kebun pertama Anda',
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

  // Kebun list (similar to HomePage content structure)
  Widget _buildKebunList(List<Kebun> filteredKebun) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          ...filteredKebun.asMap().entries.map((entry) {
            int index = entry.key;
            Kebun kebun = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KebunCard(
                kebun: kebun,
                // cardIndex: index, // Tambahkan parameter cardIndex
                onTap: () => _navigateToDetail(context, kebun.id),
                onEdit: () => _handleEdit(context, kebun),
                onDelete: () => _handleDelete(context, kebun),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Method _handleEdit yang hilang
  void _handleEdit(BuildContext context, Kebun kebun) {
    _navigateToForm(context, kebun: kebun);
  }

  //Method _handleDelete yang hilang
  void _handleDelete(BuildContext context, Kebun kebun) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kebun "${kebun.nama}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final vm = Provider.of<KebunViewModel>(context, listen: false);
                final success = await vm.deleteKebun(kebun.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Kebun berhasil dihapus'
                            : 'Gagal menghapus kebun: ${vm.errorMessage}',
                      ),
                      backgroundColor: success
                          ? const Color(AppColors.successGreen)
                          : const Color(AppColors.errorRed),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {Kebun? kebun}) {
    final vm = Provider.of<KebunViewModel>(context, listen: false);

    // Clear form state sebelum navigasi
    if (kebun == null) {
      // Mode tambah baru - clear semua state
      vm.clearForm();
    } else {
      // Mode  - set data kebun
      vm.setSelectedKebun(kebun);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KebunFormPage(kebun: kebun)),
    ).then((_) {
      // Refresh data setelah kembali
      vm.loadAllKebun();
      // Clear form setelah kembali dari form
      vm.clearForm();
    });
  }

  void _navigateToDetail(BuildContext context, int kebunId) {
    // Dari Navigator.push ke showModalBottomSheet
    final vm = Provider.of<KebunViewModel>(context, listen: false);
    final kebun = vm.kebunList.firstWhere((k) => k.id == kebunId);

    _showKebunDetail(kebun);
  }

  void _showKebunDetail(Kebun kebun) {
    // Format number dengan dots
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    // Format date
    String formatDate(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        String day = date.day.toString().padLeft(2, '0');
        String month = date.month.toString().padLeft(2, '0');
        return '$day-$month-${date.year}';
      } catch (e) {
        return dateString;
      }
    }

    // Get status color
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'aktif':
          return const Color(AppColors.successGreen);
        case 'tidak aktif':
          return const Color(AppColors.errorRed);
        case 'peremajaan':
          return const Color(AppColors.warningOrange);
        default:
          return Colors.grey;
      }
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
                    color: const Color(AppColors.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_activity_outlined,
                    color: Color(AppColors.primaryGreen),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Kebun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        kebun.nama,
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
            _buildDetailRow('Lokasi', kebun.lokasi),
            _buildDetailRow('Luas Kebun', '${kebun.luas} Hektar'),
            _buildDetailRow(
              'Titik Tanam',
              '${formatNumber(kebun.titikTanam)} Titik',
            ),
            _buildDetailRow('Waktu Beli/Sewa', formatDate(kebun.waktuBeli)),
            _buildDetailRow('Status Kepemilikan', kebun.statusKepemilikan),

            // Status kebun dengan warna
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Status Kebun',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const Text(': '),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(
                          kebun.statusKebun,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: getStatusColor(
                            kebun.statusKebun,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        kebun.statusKebun,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(kebun.statusKebun),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
            width: 120,
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
}
