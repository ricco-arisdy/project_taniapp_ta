import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/viewsModels/register_view_models.dart';
import 'package:project_taniapp_ta/widgets/auth/custom_text_field.dart';
import 'package:project_taniapp_ta/widgets/auth/floating_elements.dart';
import 'package:project_taniapp_ta/widgets/auth/gradient_background.dart';
import 'package:project_taniapp_ta/widgets/auth/gradient_button.dart';
import 'package:project_taniapp_ta/widgets/auth/logo_section.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          child: Stack(
            children: [
              FloatingElements(animation: _floatingAnimation),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    LogoSection(
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      title: 'Buat Akun Baru',
                      subtitle: 'Mulai bertani dengan mudah',
                      icon: Icons.person_add_outlined,
                    ),
                    const SizedBox(height: 30),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: viewModel.nameController,
                    label: 'Nama Lengkap',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    validator: viewModel.validateName,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: viewModel.emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: viewModel.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: viewModel.passwordController,
                    label: 'Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: viewModel.obscurePassword,
                    validator: viewModel.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B8E23),
                      ),
                      onPressed: viewModel.togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: viewModel.confirmPasswordController,
                    label: 'Ulangi Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: viewModel.obscureConfirmPassword,
                    validator: viewModel.validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B8E23),
                      ),
                      onPressed: viewModel.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: viewModel.agreeToTerms,
                        onChanged: viewModel.setAgreeToTerms,
                        activeColor: const Color(0xFF4CAF50),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => viewModel
                              .setAgreeToTerms(!viewModel.agreeToTerms),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text(
                              'Saya setuju dengan syarat dan ketentuan',
                              style: TextStyle(
                                color: Color(0xFF6B8E23),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Daftar',
                    icon: Icons.person_add,
                    isLoading: viewModel.isLoading, 
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            // Use new handleRegister method
                            final success = await viewModel.handleRegister();

                            if (success && mounted) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Registrasi berhasil! Silakan login.'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Navigate to login
                              Navigator.pop(context);
                            }
                            // Error akan ditampilkan otomatis melalui error message
                          },
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.hasError) // From BaseViewModel
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage, // From BaseViewModel
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(
                          color: Color(0xFF6B8E23),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
