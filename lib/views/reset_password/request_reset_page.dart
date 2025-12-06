import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/views/reset_password/verify_otp_page.dart';
import 'package:project_taniapp_ta/viewsModels/reset_password_view_models.dart';
import 'package:project_taniapp_ta/widgets/reset_password/custom_button.dart';
import 'package:project_taniapp_ta/widgets/reset_password/custom_text_field.dart';
import 'package:provider/provider.dart';

class RequestResetView extends StatelessWidget {
  const RequestResetView({super.key});

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
                key: viewModel.requestFormKey,
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
                        Icons.lock_reset,
                        size: 50,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Lupa Kata Sandi?',
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
                      'Masukkan email Anda dan kami akan mengirimkan kode OTP untuk mereset Sandi Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    CustomTextField(
                      controller: viewModel.emailController,
                      label: 'Email',
                      hint: 'Masukkan email Anda',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: viewModel.validateEmail,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),

                    // ✅ NEW: Rate Limit Cooldown Warning
                    if (viewModel.isInCooldown) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.warningOrange,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              AppColors.warningOrange,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Color(AppColors.warningOrange),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tunggu ${viewModel.cooldownTimeFormatted} sebelum request kembali',
                                style: const TextStyle(
                                  color: Color(AppColors.warningOrange),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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

                    // Send OTP Button
                    CustomButton(
                      text: 'Kirim Kode OTP',
                      onPressed: () => _handleRequestReset(context, viewModel),
                      isLoading: viewModel.isLoading,
                      icon: Icons.send,
                    ),
                    const SizedBox(height: 24),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah ingat kata sandi? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(AppColors.primaryGreen),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _handleRequestReset(
    BuildContext context,
    ResetPasswordViewModel viewModel,
  ) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await viewModel.requestReset();

    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kode OTP telah dikirim ke ${viewModel.emailController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(AppColors.successGreen),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: viewModel,
            child: const VerifyOtpView(),
          ),
        ),
      );
    }
  }
}
