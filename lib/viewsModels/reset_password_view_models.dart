import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/reset_password_models.dart';
import 'package:project_taniapp_ta/services/reset_password_service.dart';
import 'package:project_taniapp_ta/viewsmodels/base_view_models.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();

  // Form keys
  final GlobalKey<FormState> requestFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State
  OtpResponse? _otpResponse;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _canResend = false;
  int _resendCountdown = 0;
  int _otpAttempts = 0;
  Timer? _countdownTimer;
  Timer? _expiryTimer;
  Timer? _cooldownTimer;

  // Getters
  OtpResponse? get otpResponse => _otpResponse;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get canResend => _canResend;
  int get resendCountdown => _resendCountdown;
  int get otpAttempts => _otpAttempts;
  int get remainingAttempts =>
      ResetPasswordConstants.maxOtpAttempts - _otpAttempts;
  bool get isOtpExpired => _otpResponse?.isExpired ?? true;

  //Check if in cooldown period
  bool get isInCooldown => _otpResponse?.isInCooldown ?? false;

  // Get formatted cooldown time
  String get cooldownTimeFormatted => _otpResponse?.cooldownTimeFormatted ?? '';

  String get otpExpiryTime {
    if (_otpResponse == null) return '';
    final remaining = _otpResponse!.remainingTime;
    if (remaining.inSeconds <= 0) return 'Expired';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================
  // PASSWORD VISIBILITY TOGGLES
  // ============================================
  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // ============================================
  // VALIDATORS
  // ============================================
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ResetPasswordConstants.emptyEmailError;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return ResetPasswordConstants.invalidEmailError;
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return ResetPasswordConstants.emptyOtpError;
    }

    // Clean and validate
    final cleanedOtp = value.trim().replaceAll(RegExp(r'\s+'), '');

    if (cleanedOtp.length != ResetPasswordConstants.otpLength) {
      return ResetPasswordConstants.invalidOtpError;
    }

    // Validate digits only
    if (!RegExp(r'^\d{6}$').hasMatch(cleanedOtp)) {
      return 'Kode OTP harus berisi 6 digit angka';
    }

    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return ResetPasswordConstants.weakPasswordError;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != newPasswordController.text) {
      return ResetPasswordConstants.passwordMismatchError;
    }
    return null;
  }

  // ============================================
  // STEP 1: REQUEST RESET PASSWORD (SEND OTP)
  // ============================================
  Future<bool> requestReset() async {
    if (!requestFormKey.currentState!.validate()) {
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final response = await _resetPasswordService.requestReset(
        emailController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        _otpResponse = response.data;
        _otpAttempts = 0;
        _startResendCountdown();
        _startExpiryTimer();
        _startCooldownTimer();
        setLoading(false);
        return true;
      } else {
        // Handle rate limit error
        if (response.errorCode == 'RATE_LIMIT_EXCEEDED') {
          setError(response.message);

          // If we have cooldown info, start monitoring
          if (_otpResponse != null && _otpResponse!.isInCooldown) {
            _startCooldownTimer();
          }
        } else {
          setError(response.message);
        }
        return false;
      }
    } catch (e) {
      setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  // ============================================
  // STEP 2: VERIFY OTP
  // ============================================
  Future<bool> verifyOtp() async {
    if (!otpFormKey.currentState!.validate()) {
      return false;
    }

    // Check if OTP expired
    if (isOtpExpired) {
      setError('Kode OTP telah kadaluarsa. Silakan minta kode baru.');
      return false;
    }

    //Check if max attempts reached
    if (_otpAttempts >= ResetPasswordConstants.maxOtpAttempts) {
      setError(
        'Anda telah melebihi batas percobaan. Silakan minta kode OTP baru.',
      );
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final response = await _resetPasswordService.verifyOtp(
        emailController.text.trim(),
        otpController.text.trim(),
      );

      if (response.isSuccess && response.data == true) {
        _otpAttempts = 0;
        setLoading(false);
        return true;
      } else {
        _otpAttempts++;

        // Update error message with remaining attempts
        final remaining = ResetPasswordConstants.maxOtpAttempts - _otpAttempts;

        if (_otpAttempts >= ResetPasswordConstants.maxOtpAttempts) {
          setError(
            'Anda telah melewati batas maksimal percobaan. Silakan minta kode OTP baru.',
          );
        } else {
          setError(response.message);
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  // ============================================
  // STEP 3: RESET PASSWORD
  // ============================================
  Future<bool> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) {
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final response = await _resetPasswordService.resetPassword(
        emailController.text.trim(),
        otpController.text.trim(),
        newPasswordController.text,
        confirmPasswordController.text,
      );

      if (response.isSuccess && response.data == true) {
        setLoading(false);
        return true;
      } else {
        setError(response.message);
        return false;
      }
    } catch (e) {
      setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  // ============================================
  // RESEND OTP
  // ============================================
  Future<bool> resendOtp() async {
    // Check rate limit cooldown first
    if (isInCooldown) {
      setError(
        'Mohon tunggu ${cooldownTimeFormatted} sebelum request kode baru',
      );
      return false;
    }

    if (!_canResend) {
      setError('Tunggu ${_resendCountdown} detik sebelum mengirim ulang');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final response = await _resetPasswordService.requestReset(
        emailController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        _otpResponse = response.data;
        _otpAttempts = 0;
        otpController.clear();
        _startResendCountdown();
        _startExpiryTimer();
        _startCooldownTimer();
        setLoading(false);
        return true;
      } else {
        // Handle rate limit error
        if (response.errorCode == 'RATE_LIMIT_EXCEEDED') {
          setError(response.message);

          // Restart cooldown timer
          if (_otpResponse != null) {
            _startCooldownTimer();
          }
        } else {
          setError(response.message);
        }
        return false;
      }
    } catch (e) {
      setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  // ============================================
  // COUNTDOWN TIMERS
  // ============================================
  void _startResendCountdown() {
    _canResend = false;
    _resendCountdown = ResetPasswordConstants.otpResendCooldown.inSeconds;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpResponse?.isExpired ?? true) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  // Monitor rate limit cooldown
  void _startCooldownTimer() {
    _cooldownTimer?.cancel();

    if (_otpResponse == null || !_otpResponse!.isInCooldown) {
      return;
    }

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();

      // Stop when cooldown finished
      if (!(_otpResponse?.isInCooldown ?? false)) {
        timer.cancel();
      }
    });
  }

  // ============================================
  // RESET STATE
  // ============================================
  void resetToRequestScreen() {
    emailController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _otpResponse = null;
    _otpAttempts = 0;
    _canResend = false;
    _resendCountdown = 0;
    _countdownTimer?.cancel();
    _expiryTimer?.cancel();
    _cooldownTimer?.cancel();
    clearError();
    notifyListeners();
  }

  // ============================================
  // DISPOSE
  // ============================================
  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    _expiryTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
