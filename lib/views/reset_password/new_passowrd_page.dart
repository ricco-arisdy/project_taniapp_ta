import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/viewsModels/reset_password_view_models.dart';
import 'package:project_taniapp_ta/widgets/reset_password/custom_button.dart';
import 'package:project_taniapp_ta/widgets/reset_password/custom_text_field.dart';
import 'package:provider/provider.dart';

class NewPasswordView extends StatelessWidget {
  const NewPasswordView({super.key});

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
                key: viewModel.resetFormKey,
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
                        Icons.lock_open,
                        size: 50,
                        color: Color(AppColors.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Buat Kata Sandi Baru',
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
                      'Kata Sandi baru Anda harus berbeda dengan kata sandi sebelumnya',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // New Password Field
                    CustomTextField(
                      controller: viewModel.newPasswordController,
                      label: 'Kata Sandi Baru',
                      hint: 'Masukkan kata sandi baru',
                      prefixIcon: Icons.lock_outline,
                      obscureText: viewModel.obscureNewPassword,
                      validator: viewModel.validateNewPassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: viewModel.toggleNewPasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    CustomTextField(
                      controller: viewModel.confirmPasswordController,
                      label: 'Konfirmasi Kata Sandi',
                      hint: 'Masukkan ulang kata sandi baru',
                      prefixIcon: Icons.lock_outline,
                      obscureText: viewModel.obscureConfirmPassword,
                      validator: viewModel.validateConfirmPassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: viewModel.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(
                          AppColors.infoBlue,
                        ).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            AppColors.infoBlue,
                          ).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Persyaratan Kata Sandi:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildRequirement('Minimal 6 karakter'),
                          _buildRequirement(
                            'Kombinasi huruf dan angka direkomendasikan',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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

                    // Reset Password Button
                    CustomButton(
                      text: 'Reset Kata Sandi',
                      onPressed: () => _handleResetPassword(context, viewModel),
                      isLoading: viewModel.isLoading,
                      icon: Icons.check_circle,
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

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword(
    BuildContext context,
    ResetPasswordViewModel viewModel,
  ) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await viewModel.resetPassword();

    if (success && context.mounted) {
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(AppColors.successGreen).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Color(AppColors.successGreen),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password Berhasil Direset!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.darkGreen),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Password Anda telah berhasil direset. Silakan login dengan password baru Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Reset view model
                  viewModel.resetToRequestScreen();

                  // Pop all reset password screens and go to login
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
