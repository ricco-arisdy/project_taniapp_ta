import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/models/panen_models.dart';
import 'package:project_taniapp_ta/models/pemeliharaan_models.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/activity_tracker_service.dart';
import 'package:project_taniapp_ta/services/kebun_service.dart';
import 'package:project_taniapp_ta/services/panen_service.dart';
import 'package:project_taniapp_ta/services/pemeliharaan_service.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';
import 'package:project_taniapp_ta/services/token_monitor_service.dart';
import 'package:project_taniapp_ta/views/kebun/kebun_page.dart';
import 'package:project_taniapp_ta/views/laporan/laporan.dart';
import 'package:project_taniapp_ta/views/panen/panen_page.dart';
import 'package:project_taniapp_ta/views/pemeliharaan/pemeliharaan_page.dart';
import 'package:project_taniapp_ta/views/profile/profile_page.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/profile_edit_view_models.dart';
import 'package:project_taniapp_ta/widgets/buttom_navigation/buttom_navigation.dart';
import 'package:project_taniapp_ta/widgets/home_card_kebun/card_kebun.dart';
import 'package:project_taniapp_ta/widgets/home_card_panen/card_panen.dart';
import 'package:project_taniapp_ta/widgets/home_card_pemeliharaan/card_pemeliharaan.dart';
import 'package:project_taniapp_ta/widgets/skeleton/Skeleton_Card.dart';
import 'package:project_taniapp_ta/widgets/skeleton/Skeleton_Screen.dart';
import 'package:project_taniapp_ta/widgets/theme/tema_utama.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  User? _currentUser;
  bool _isLoading = true;
  bool _isDashboardLoading = true;
  int _currentIndex = 0;
  bool _isDialogShowing = false;

  // Data statistics
  int _totalKebun = 0;
  int _totalPanen = 0;
  int _totalPemeliharaan = 0;
  double _totalLuas = 0.0;
  double _totalPendapatan = 0.0;
  double _totalBiayaPemeliharaan = 0.0;
  List<Kebun> _recentKebun = [];
  List<Panen> _recentPanen = [];
  List<Pemeliharaan> _recentPemeliharaan = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setupLoginListener();
      _setupProfileUpdateListener();
    });
    //  Token monitoring
    TokenMonitorService.resetMonitoring();
    TokenMonitorService.startMonitoring();
    TokenMonitorService.tokenExpiredNotifier.addListener(_onTokenExpired);

    //  ADD: Activity tracking
    ActivityTrackerService.resetTracking();
    ActivityTrackerService.startTracking();
    ActivityTrackerService.inactivityLogoutNotifier.addListener(
      _onInactivityTimeout,
    );

    print('🏠 [HOME] HomePage initialized with activity tracking');
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);

    // top monitoring and remove listener
    TokenMonitorService.tokenExpiredNotifier.removeListener(_onTokenExpired);
    TokenMonitorService.stopMonitoring();

    // Activity tracking
    ActivityTrackerService.inactivityLogoutNotifier.removeListener(
      _onInactivityTimeout,
    );
    ActivityTrackerService.stopTracking();

    // Remove profile update listener
    ProfileEditViewModel.profileUpdateNotifier.removeListener(
      _onProfileUpdated,
    );

    LoginViewModel.logoutNotifier.removeListener(_handleLoginStateChange);
    print('🏠 [HOME] HomePage disposed');
    super.dispose();
  }

  // Profile update listener setup
  void _setupProfileUpdateListener() {
    ProfileEditViewModel.profileUpdateNotifier.addListener(_onProfileUpdated);
  }

  // Handle profile update notification
  void _onProfileUpdated() {
    final updatedUser = ProfileEditViewModel.profileUpdateNotifier.value;
    if (updatedUser != null && mounted) {
      print('🔄 [HOME] Profile update detected - refreshing user data');
      setState(() {
        _currentUser = updatedUser;
      });

      // Also refresh dashboard if needed
      _loadDashboardData();
    }
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('📱 [HOME] App state changed: $state');

    if (state == AppLifecycleState.resumed) {
      _checkTokenOnResume();
      _checkInactivityOnResume();
    } else if (state == AppLifecycleState.paused) {
      print('⏸️ [HOME] App paused');
      ActivityTrackerService.recordActivity();
    }
  }

  Future<void> _checkInactivityOnResume() async {
    print('🔄 [HOME] Checking inactivity on resume...');

    final wasInactive = await ActivityTrackerService.checkInactivity();

    if (wasInactive && mounted && !_isDialogShowing) {
      print('❌ [HOME] User was inactive, showing logout dialog');
      _showInactivityLogoutDialog();
    } else if (!wasInactive) {
      print('✅ [HOME] User activity OK, restarting tracker');
      // Restart activity tracking
      ActivityTrackerService.resetTracking();
      ActivityTrackerService.startTracking();
    }
  }

  void _onInactivityTimeout() {
    if (ActivityTrackerService.inactivityLogoutNotifier.value &&
        mounted &&
        !_isDialogShowing) {
      print('❌ [HOME] Inactivity timeout notification received');
      _showInactivityLogoutDialog();
    }
  }

  Future<void> _checkTokenOnResume() async {
    print('🔄 [HOME] App resumed, checking token...');

    final isExpired = await TokenMonitorService.checkNow();

    if (isExpired && mounted) {
      print('❌ [HOME] Token expired on resume');
      _showSessionExpiredDialog();
    } else {
      print('✅ [HOME] Token still valid on resume');
      _refreshDashboard();
    }
  }

  // Handle token expiry notification
  void _onTokenExpired() {
    if (TokenMonitorService.tokenExpiredNotifier.value &&
        mounted &&
        !_isDialogShowing) {
      print('❌ [HOME] Token expired notification received');
      _showSessionExpiredDialog();
    }
  }

  void _showInactivityLogoutDialog() {
    if (_isDialogShowing) {
      print('⚠️ [HOME] Dialog already showing, skipping...');
      return;
    }

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  color: Color(0xFFFF8A00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sesi Tidak Aktif',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5F2D),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anda telah tidak aktif selama 1 jam. Untuk keamanan, sesi Anda telah berakhir.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Silakan login kembali untuk melanjutkan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  _isDialogShowing = false;
                  Navigator.of(context).pop();

                  // ✅ Reset both services
                  TokenMonitorService.resetMonitoring();
                  ActivityTrackerService.resetTracking();

                  await SharedPreferencesService.clearAuthData();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Login Kembali',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  //Refresh dashboard data & show dialog
  void _showSessionExpiredDialog() {
    if (_isDialogShowing) {
      print('⚠️ [HOME] Dialog already showing, skipping...');
      return;
    }

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFFF8A00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sesi Berakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5F2D),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sesi Anda telah berakhir karena tidak ada aktivitas selama 1 jam.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Silakan login kembali untuk melanjutkan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _isDialogShowing = false;
                  Navigator.of(context).pop();

                  TokenMonitorService.resetMonitoring();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Login Kembali',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _setupLoginListener() {
    LoginViewModel.logoutNotifier.addListener(_handleLoginStateChange);
  }

  void _handleLoginStateChange() {
    print('🔄 [HOME] Login state changed - reloading user data...');
    if (mounted) {
      // ✅ FIX: Reload user data AND dashboard data
      _loadUser().then((_) {
        if (mounted) {
          _loadDashboardData();
        }
      });
    }
  }

  Future<void> _loadInitialData() async {
    await _loadUser();
    if (mounted) {
      await _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isDashboardLoading = true;
    });

    try {
      //  Load kebun data
      final kebunService = KebunService();
      final kebunResponse = await kebunService.getAllKebun();

      //  Load panen data
      final panenResponse = await PanenService.getAllPanen();

      //  Load pemeliharaan data
      final pemeliharaanResponse =
          await PemeliharaanService.getAllPemeliharaan();
      if (mounted) {
        //Process kebun data dengan metadata
        int totalKebun = 0;
        double totalLuas = 0.0;
        List<Kebun> recentKebun = [];

        if (kebunResponse.isSuccess && kebunResponse.data != null) {
          final kebunList = kebunResponse.data!['kebun'] as List<Kebun>? ?? [];
          final kebunMetadata =
              kebunResponse.data!['metadata'] as KebunMetadata?;

          if (kebunMetadata != null) {
            totalKebun = kebunMetadata.totalRecords;
            totalLuas = kebunMetadata.totalLuas;
          } else {
            // Fallback jika metadata null
            totalKebun = kebunList.length;
            totalLuas = kebunList.fold(0.0, (sum, kebun) {
              final luas = double.tryParse(kebun.luas) ?? 0.0;
              return sum + luas;
            });
          }

          recentKebun = kebunList.take(3).toList();
        }

        //  Process panen data dengan metadata dari backend
        int totalPanen = 0;
        double totalPendapatan = 0.0;
        List<Panen> recentPanen = [];

        if (panenResponse.isSuccess && panenResponse.data != null) {
          final panenList = panenResponse.data!['panen'] as List<Panen>? ?? [];
          final panenMetadata =
              panenResponse.data!['metadata'] as PanenMetadata?;

          if (panenMetadata != null) {
            // ✅ Gunakan statistik dari backend
            totalPanen = panenMetadata.totalRecords;
            totalPendapatan = panenMetadata.totalNilai.toDouble();

            print('📊 [HOME] Panen stats from backend:');
            print('   - Total: $totalPanen');
            print('   - Total Kg: ${panenMetadata.totalKg}');
            print('   - Total Nilai: Rp $totalPendapatan');
          } else {
            // ✅ Fallback jika metadata null
            totalPanen = panenList.length;
            totalPendapatan = panenList.fold(
              0.0,
              (sum, panen) => sum + panen.totalNilai.toDouble(),
            );
          }

          // Sort by date (newest first)
          panenList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA);
            } catch (e) {
              return b.id.compareTo(a.id);
            }
          });

          recentPanen = panenList.take(3).toList();
        }
        int totalPemeliharaan = 0;
        double totalBiayaPemeliharaan = 0.0;
        List<Pemeliharaan> recentPemeliharaan = [];

        if (pemeliharaanResponse.isSuccess &&
            pemeliharaanResponse.data != null) {
          print('📊 [HOME] Processing pemeliharaan response...');
          print('📊 [HOME] Response data: ${pemeliharaanResponse.data}');
          final pemeliharaanList =
              pemeliharaanResponse.data!['pemeliharaan']
                  as List<Pemeliharaan>? ??
              [];
          final pemeliharaanMetadata =
              pemeliharaanResponse.data!['metadata'] as PemeliharaanMetadata?;
          print(
            '📊 [HOME] Pemeliharaan list length: ${pemeliharaanList.length}',
          );
          print('📊 [HOME] Metadata: $pemeliharaanMetadata');

          if (pemeliharaanMetadata != null) {
            // ✅ CRITICAL FIX: Gunakan statistik dari backend dengan logging
            totalPemeliharaan = pemeliharaanMetadata.totalRecords;
            totalBiayaPemeliharaan = pemeliharaanMetadata.totalBiaya.toDouble();

            print('📊 [HOME] Pemeliharaan stats from backend:');
            print('   - Total Records: $totalPemeliharaan');
            print('   - Total Biaya (int): ${pemeliharaanMetadata.totalBiaya}');
            print('   - Total Biaya (double): $totalBiayaPemeliharaan');
            print(
              '   - Rata-rata Biaya: ${pemeliharaanMetadata.rataRataBiaya}',
            );
            print(
              '   - Kegiatan Terbanyak: ${pemeliharaanMetadata.kegiatanTerbanyak}',
            );
          } else {
            // ✅ Fallback jika metadata null
            print('⚠️ [HOME] Metadata null, using fallback calculation');

            totalPemeliharaan = pemeliharaanList.length;
            totalBiayaPemeliharaan = pemeliharaanList.fold(
              0.0,
              (sum, pemeliharaan) => sum + pemeliharaan.biaya.toDouble(),
            );

            print('📊 [HOME] Fallback stats:');
            print('   - Total Records: $totalPemeliharaan');
            print('   - Total Biaya: $totalBiayaPemeliharaan');
          }

          // Sort pemeliharaan by date
          pemeliharaanList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.tanggal);
              final dateB = DateTime.parse(b.tanggal);
              return dateB.compareTo(dateA);
            } catch (e) {
              return b.id.compareTo(a.id);
            }
          });

          recentPemeliharaan = pemeliharaanList.take(3).toList();
        } else {
          print('❌ [HOME] Pemeliharaan response failed or null');
        }

        setState(() {
          // Kebun
          _totalKebun = totalKebun;
          _totalLuas = totalLuas;
          _recentKebun = recentKebun;

          // Panen
          _totalPanen = totalPanen;
          _totalPendapatan = totalPendapatan;
          _recentPanen = recentPanen;

          // Pemeliharaan
          _totalPemeliharaan = totalPemeliharaan;
          _totalBiayaPemeliharaan = totalBiayaPemeliharaan;
          _recentPemeliharaan = recentPemeliharaan;
          _isDashboardLoading = false;
        });

        print('✅ [HOME] Dashboard loaded with backend stats');
        print('   - Kebun: $totalKebun (${totalLuas}Ha)');
        print('   - Panen: $totalPanen (Rp ${totalPendapatan.toInt()})');
        print(
          '   - Pemeliharaan: $totalPemeliharaan (Rp ${totalBiayaPemeliharaan.toInt()})',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalKebun = 0;
          _totalLuas = 0.0;
          _recentKebun = [];
          _totalPanen = 0;
          _totalPendapatan = 0.0;
          _recentPanen = [];
          _totalPemeliharaan = 0;
          _totalBiayaPemeliharaan = 0.0;
          _recentPemeliharaan = [];
          _isDashboardLoading = false;
        });

        print('💥 [HOME] Dashboard error: $e');
      }
    }
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final userDataString = prefs.getString(AppConstants.userDataKey);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (mounted) {
          setState(() {
            _currentUser = User.fromJson(userData);
          });
        }
        print('✅ [HOME] User loaded: ${_currentUser?.nama}');
      } else {
        print('⚠️ [HOME] No user data found');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
    } catch (e) {
      print('💥 [HOME] Error loading user: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshDashboard() {
    print('🔄 [HOME] Refreshing dashboard data...');
    _loadDashboardData();
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KebunPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PanenPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PemeliharaanPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LaporanPage()),
        ).then((_) {
          _refreshDashboard();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // hilangkan abu-abu
        statusBarIconBrightness: Brightness.dark, // ikon hitam
      ),
    );

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
      // Record activity on any tap/drag
      onTap: () => ActivityTrackerService.recordActivity(),
      onPanDown: (_) => ActivityTrackerService.recordActivity(),
      onScaleStart: (_) => ActivityTrackerService.recordActivity(),

      behavior: HitTestBehavior.translucent,

      child: Scaffold(
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
                      child: const SkeletonScreen(type: SkeletonType.home),
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
                onRefresh: _loadDashboardData,
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
                            _buildSummaryCard(),
                            const SizedBox(height: 20),
                            _buildQuickActions(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: _navigateToProfile,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hallo,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _currentUser?.nama ?? 'Pengguna',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  Widget _buildSummaryCard() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const SkeletonCard(height: 160),
        ),
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
                // Total Pendapatan Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Total Pendapatan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatCurrency(_totalPendapatan)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lihat semua button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LaporanPage(),
                      ),
                    ).then((_) {
                      // Refresh dashboard when returning from laporan
                      _refreshDashboard();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ==== Statistics Grid ====
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.landscape_rounded,
                    label: 'Kebun',
                    value: _totalKebun.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.agriculture_rounded,
                    label: 'Panen',
                    value: _totalPanen.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.grass_rounded,
                    label: 'Pemeliharaan',
                    value: _totalPemeliharaan.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactStatItem(
                    icon: Icons.square_foot_rounded,
                    label: 'Luas',
                    value: '${_totalLuas.toStringAsFixed(1)}Ha',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk stat item yang compact sesuai wireframe
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

  Widget _buildQuickActions() {
    if (_isDashboardLoading) {
      return const Column(
        children: [
          SkeletonCard(height: 100),
          SizedBox(height: 20),
          SkeletonCard(height: 100),
          SizedBox(height: 20),
          SkeletonCard(height: 100),
        ],
      );
    }

    return Column(
      children: [
        _buildKebunSection(),
        const SizedBox(height: 20),
        _buildPanenSection(),
        const SizedBox(height: 20),
        _buildPemeliharaanSection(),
      ],
    );
  }

  Widget _buildKebunSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    return KebunHomeCard(
      totalKebun: _totalKebun,
      totalLuas: _totalLuas,
      recentKebun: _recentKebun,
      onTap: () => _handleNavigation(1),
    );
  }

  Widget _buildPanenSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    return _totalPanen > 0
        ? PanenHomeCard(
            totalPanen: _totalPanen,
            totalPendapatan: _totalPendapatan,
            recentPanen: _recentPanen,
            onTap: () => _handleNavigation(2),
          )
        : _buildEmptySection(
            title: 'Panen',
            subtitle: 'Belum ada data panen',
            icon: Icons.agriculture_outlined,
            onTap: () => _handleNavigation(2),
          );
  }

  Widget _buildPemeliharaanSection() {
    if (_isDashboardLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: const SkeletonCard(height: 120),
      );
    }

    // Tampilkan data pemeliharaan real atau empty state
    return _totalPemeliharaan > 0
        ? PemeliharaanHomeCard(
            totalPemeliharaan: _totalPemeliharaan,
            totalBiaya: _totalBiayaPemeliharaan.toInt(),
            recentPemeliharaan: _recentPemeliharaan,
            onTap: () => _handleNavigation(3),
          )
        : _buildEmptySection(
            title: 'Pemeliharaan',
            subtitle: 'Belum ada data pemeliharaan',
            icon: Icons.handyman_outlined,
            onTap: () => _handleNavigation(3),
          );
  }

  Widget _buildEmptySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tambah Data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return '0';

    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = amount.toStringAsFixed(0);
    return result.replaceAllMapped(formatter, (Match m) => '${m[1]}.');
  }
}
