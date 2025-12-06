import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/services/auth_register_service.dart';
import 'package:project_taniapp_ta/viewsmodels/base_view_models.dart';

class RegisterViewModel extends BaseViewModel {
  final AuthRegisterService _authRegisterService = AuthRegisterService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get agreeToTerms => _agreeToTerms;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setAgreeToTerms(bool? value) {
    _agreeToTerms = value ?? false;
    notifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  Future<bool> handleRegister() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!_agreeToTerms) {
      setError('Anda harus menyetujui syarat dan ketentuan');
      return false;
    }

    try {
      setLoading(true);
      clearError();

      final response = await _authRegisterService.register(
        nama: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        ulangiPassword: confirmPasswordController.text.trim(),
      );

      if (response.isSuccess) {
        print('✅ [REGISTER] Registration successful');
        setLoading(false);
        return true;
      } else {
        setError(response.message);
        return false;
      }
    } catch (e) {
      print('💥 [REGISTER] Registration error: ${e.toString()}');
      setError('Registrasi gagal: ${e.toString()}');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
