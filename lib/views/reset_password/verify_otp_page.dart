import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/views/reset_password/new_passowrd_page.dart';
import 'package:project_taniapp_ta/viewsModels/reset_password_view_models.dart';
import 'package:project_taniapp_ta/widgets/reset_password/custom_button.dart';
import 'package:project_taniapp_ta/widgets/reset_password/otp_input_field.dart';
import 'package:provider/provider.dart';

class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(AppColors.darkGreen),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<ResetPasswordViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: viewModel.otpFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Icon
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(
                          AppColors.primaryGreen,
                        ).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 50,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Verifikasi Kode OTP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.darkGreen),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Masukkan 6 digit kode OTP yang telah dikirim ke',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.emailController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.primaryGreen),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // OTP Input Fields
                    OtpInputField(
                      controller: viewModel.otpController,
                      length: ResetPasswordConstants.otpLength,
                      validator: viewModel.validateOtp,
                      onCompleted: (otp) {
                        // Auto verify when all digits entered
                        print('🔐 OTP Completed: $otp');
                      },
                    ),
                    const SizedBox(height: 24),

                    // OTP Timer/Expiry & Attempts Info
                    if (viewModel.otpResponse != null) ...[
                      // ✅ Expiry Timer
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: viewModel.isOtpExpired
                              ? const Color(AppColors.errorRed).withOpacity(0.1)
                              : const Color(
                                  AppColors.infoBlue,
                                ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              viewModel.isOtpExpired
                                  ? Icons.error_outline
                                  : Icons.access_time,
                              color: viewModel.isOtpExpired
                                  ? const Color(AppColors.errorRed)
                                  : const Color(AppColors.infoBlue),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.isOtpExpired
                                  ? 'Kode OTP kadaluarsa'
                                  : 'Kode berlaku: ${viewModel.otpExpiryTime}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: viewModel.isOtpExpired
                                    ? const Color(AppColors.errorRed)
                                    : const Color(AppColors.infoBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ NEW: Remaining Attempts Info
                      if (viewModel.otpAttempts > 0 &&
                          viewModel.remainingAttempts > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: viewModel.remainingAttempts <= 2
                                ? const Color(
                                    AppColors.errorRed,
                                  ).withOpacity(0.1)
                                : const Color(
                                    AppColors.warningOrange,
                                  ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: viewModel.remainingAttempts <= 2
                                    ? const Color(AppColors.errorRed)
                                    : const Color(AppColors.warningOrange),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sisa percobaan: ${viewModel.remainingAttempts} kali',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: viewModel.remainingAttempts <= 2
                                      ? const Color(AppColors.errorRed)
                                      : const Color(AppColors.warningOrange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],

                    // Error Message
                    if (viewModel.hasError)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.errorRed,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              AppColors.errorRed,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(AppColors.errorRed),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage,
                                style: const TextStyle(
                                  color: Color(AppColors.errorRed),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (viewModel.hasError) const SizedBox(height: 24),

                    // Verify Button
                    CustomButton(
                      text: 'Verifikasi Kode',
                      onPressed: viewModel.isOtpExpired
                          ? () {}
                          : () => _handleVerifyOtp(context, viewModel),
                      isLoading: viewModel.isLoading,
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(height: 16),

                    // Resend OTP Button
                    CustomButton(
                      text: viewModel.canResend
                          ? 'Kirim Ulang Kode OTP'
                          : 'Kirim Ulang (${viewModel.resendCountdown}s)',
                      onPressed: () {
                        // ✅ Check cooldown first
                        if (viewModel.isInCooldown) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tunggu ${viewModel.cooldownTimeFormatted} sebelum request kode baru',
                              ),
                              backgroundColor: const Color(
                                AppColors.warningOrange,
                              ),
                            ),
                          );
                          return;
                        }

                        if (!viewModel.canResend) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tunggu ${viewModel.resendCountdown} detik lagi',
                              ),
                              backgroundColor: const Color(
                                AppColors.warningOrange,
                              ),
                            ),
                          );
                          return;
                        }

                        _handleResendOtp(context, viewModel);
                      },
                      isLoading: false,
                      isOutlined: true,
                      icon: Icons.refresh,
                      color: viewModel.canResend && !viewModel.isInCooldown
                          ? const Color(AppColors.primaryGreen)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 24),

                    // Back to Request Screen
                    TextButton(
                      onPressed: () {
                        viewModel.resetToRequestScreen();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Gunakan Email Lain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(AppColors.primaryGreen),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleVerifyOtp(
    BuildContext context,
    ResetPasswordViewModel viewModel,
  ) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await viewModel.verifyOtp();

    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Kode OTP valid!', style: TextStyle(fontSize: 14)),
            ],
          ),
          backgroundColor: Color(AppColors.successGreen),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to New Password screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: viewModel,
            child: const NewPasswordView(),
          ),
        ),
      );
    }
  }

  Future<void> _handleResendOtp(
    BuildContext context,
    ResetPasswordViewModel viewModel,
  ) async {
    final success = await viewModel.resendOtp();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Kode OTP baru telah dikirim!',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: Color(AppColors.successGreen),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
