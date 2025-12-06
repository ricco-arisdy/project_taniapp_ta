import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_taniapp_ta/services/activity_tracker_service.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';
import 'package:project_taniapp_ta/views/home_page.dart';
import 'package:project_taniapp_ta/views/kebun/kebun_page.dart';
import 'package:project_taniapp_ta/views/laporan/laporan.dart';
import 'package:project_taniapp_ta/views/login_page.dart';
import 'package:project_taniapp_ta/views/panen/panen_page.dart';
import 'package:project_taniapp_ta/views/pemeliharaan/pemeliharaan_page.dart';
import 'package:project_taniapp_ta/views/register_page.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/laporan_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/panen_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/pemeiharaan_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/register_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/reset_password_view_models.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => KebunViewModel()),
        ChangeNotifierProvider(create: (_) => PanenViewModel()),
        ChangeNotifierProvider(create: (_) => PemeliharaanViewModel()),
        ChangeNotifierProvider(create: (_) => LaporanViewModel()),
        ChangeNotifierProvider(create: (_) => ResetPasswordViewModel()),
      ],
      child: MaterialApp(
        title: 'TA Project',
        debugShowCheckedModeBanner: false,
        home: const AuthChecker(),
        routes: {
          '/home': (context) => const HomePage(),
          '/kebun': (context) => const KebunPage(),
          '/panen': (context) => const PanenPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/pemeliharaan': (context) => const PemeliharaanPage(),
          '/laporan': (context) => const LaporanPageWrapper(),
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  SizedBox(height: 16),
                  Text(
                    'Memeriksa sesi...',
                    style: TextStyle(color: Color(0xFF6B8E23), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<bool> _checkAuthStatus() async {
    try {
      print('🔐 [AUTH_CHECKER] Checking authentication status...');

      // Check 1: Token max lifetime (24 hours - security hard limit)
      final isTokenExpired = await SharedPreferencesService.isTokenExpired();
      if (isTokenExpired) {
        print('❌ [AUTH_CHECKER] Token expired (24-hour max), clearing data...');
        await SharedPreferencesService.clearAuthData();
        return false;
      }

      // Check 2: User inactivity (1 hour - UX)
      final wasInactive = await ActivityTrackerService.checkInactivity();
      if (wasInactive) {
        print('❌ [AUTH_CHECKER] User inactive for 1+ hour, clearing data...');
        await SharedPreferencesService.clearAuthData();
        return false;
      }

      // Check 3: Login status
      final isLoggedIn = await SharedPreferencesService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ [AUTH_CHECKER] Not logged in');
        return false;
      }

      print('✅ [AUTH_CHECKER] Authentication valid');
      print('✅ [AUTH_CHECKER] Token OK (24h max) + Activity OK (1h idle)');
      return true;
    } catch (e) {
      print('💥 [AUTH_CHECKER] Error: $e');
      return false;
    }
  }
}

class LaporanPageWrapper extends StatelessWidget {
  const LaporanPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Reset laporan data setiap kali route dipanggil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final laporanVm = Provider.of<LaporanViewModel>(context, listen: false);
      laporanVm.resetLaporanData();
    });

    return const LaporanPage();
  }
}
