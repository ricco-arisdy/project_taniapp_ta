import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/activity_tracker_service.dart';
import 'package:project_taniapp_ta/services/auth_login_service.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';
import 'package:project_taniapp_ta/services/token_monitor_service.dart';
import 'package:project_taniapp_ta/viewsmodels/base_view_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginViewModel extends BaseViewModel {
  final AuthLoginService _authLoginService = AuthLoginService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  User? _currentUser;

  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  User? get currentUser => _currentUser;

  // Constructor - Load saved credentials saat ViewModel dibuat
  LoginViewModel() {
    _loadSavedCredentials();
  }

  // Method untuk load saved credentials
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await SharedPreferencesService.getSavedCredentials();

      emailController.text = credentials['email'];
      passwordController.text = credentials['password'];
      _rememberMe = credentials['rememberMe'];

      notifyListeners();
    } catch (e) {
      setError('Gagal memuat data tersimpan: ${e.toString()}');
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<bool> validateToken() async {
    try {
      final token = await SharedPreferencesService.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      // Test token validity dengan call ke profile endpoint
      final response = await _authLoginService.testTokenValidity();

      if (!response.isSuccess) {
        // Token invalid, clear session
        await SharedPreferencesService.clearAuthData();
        return false;
      }

      return true;
    } catch (e) {
      print('💥 [LOGIN_VM] Token validation error: $e');
      return false;
    }
  }

  static final ValueNotifier<bool> logoutNotifier = ValueNotifier<bool>(false);

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    setLoading(true);
    clearError();

    try {
      print('🔐 [LOGIN_VM] Attempting login for: $email');

      // ✅ FIX: Gunakan _authLoginService.login() bukan AuthService.login()
      final response = await _authLoginService.login(
        email.trim(),
        password.trim(),
      );

      if (!response.isSuccess || response.data == null) {
        print('❌ [LOGIN_VM] Login failed: ${response.message}');
        setError(response.message);
        setLoading(false);
        return false;
      }

      final user = response.data!;
      _currentUser = user; // ✅ Set current user

      // ✅ FIX: Proper null check untuk token
      if (user.token == null || user.token!.isEmpty) {
        print('❌ [LOGIN_VM] TOKEN IS NULL OR EMPTY!');
        setError('Token tidak ditemukan dari server');
        setLoading(false);
        return false;
      }

      final token = user.token!;

      print('✅ [LOGIN_VM] Login successful');
      print('👤 [LOGIN_VM] User: ${user.nama}');
      print('🔑 [LOGIN_VM] Token: ${token.substring(0, 20)}...');

      // ✅ Save token and user data
      await SharedPreferencesService.saveAuthData(
        token: token,
        rememberMe: rememberMe,
        userId: jsonEncode(user.toJson()),
      );

      // Save credentials if rememberMe is true
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.savedEmailKey, email);
        await prefs.setString(AppConstants.savedPasswordKey, password);
        await prefs.setBool(AppConstants.rememberMeKey, true);
        print('💾 [LOGIN_VM] Credentials saved');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.savedEmailKey);
        await prefs.remove(AppConstants.savedPasswordKey);
        await prefs.setBool(AppConstants.rememberMeKey, false);
      }

      // Token monitoring
      TokenMonitorService.resetMonitoring();
      TokenMonitorService.startMonitoring();

      // Start activity tracking
      ActivityTrackerService.resetTracking();
      ActivityTrackerService.startTracking();
      print('🔄 [LOGIN_VM] Token monitoring started');

      // ✅ Notify login success
      _notifyLoginSuccess();

      setLoading(false);
      return true;
    } catch (e) {
      print('💥 [LOGIN_VM] Login error: $e');
      setError('Terjadi kesalahan: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // method logout
  Future<void> logout() async {
    try {
      print('🚪 [LOGIN_VM] Logging out...');

      // Stop monitoring dan reset
      TokenMonitorService.resetMonitoring();
      // Stop activity tracking
      ActivityTrackerService.resetTracking();
      print('🛑 [LOGIN_VM] Token monitoring stopped');

      // Clear current user
      _currentUser = null;
      clearError();

      // Clear auth data
      await SharedPreferencesService.clearAuthData();

      // Check if should clear credentials
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;

      if (!rememberMe) {
        await SharedPreferencesService.clearSavedCredentials();
        print('🗑️ [LOGIN_VM] Credentials cleared');
      }

      // Notify LAST (after cleanup)
      await Future.delayed(const Duration(milliseconds: 100));

      logoutNotifier.value =
          !logoutNotifier.value; // Toggle untuk trigger listeners
      print('📢 [LOGIN_VM] Logout notification sent');

      print('✅ [LOGIN_VM] Logout completed');
    } catch (e) {
      print('💥 [LOGIN_VM] Logout error: $e');
      setError('Gagal logout: ${e.toString()}');
    }
  }

  void _notifyLoginSuccess() {
    // Trigger semua listener untuk reload data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        logoutNotifier.value = !logoutNotifier.value;
        print('📢 [LOGIN_VM] Login success notification sent');
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
