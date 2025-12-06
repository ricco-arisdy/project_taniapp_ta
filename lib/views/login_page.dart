import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/services/token_monitor_service.dart';
import 'package:project_taniapp_ta/views/register_page.dart';
import 'package:project_taniapp_ta/views/reset_password/request_reset_page.dart';
import 'package:project_taniapp_ta/viewsModels/login_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/reset_password_view_models.dart';

import 'package:project_taniapp_ta/widgets/auth/custom_text_field.dart';
import 'package:project_taniapp_ta/widgets/auth/floating_elements.dart';
import 'package:project_taniapp_ta/widgets/auth/gradient_background.dart';
import 'package:project_taniapp_ta/widgets/auth/gradient_button.dart';
import 'package:project_taniapp_ta/widgets/auth/logo_section.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Hanya animation yang tetap di View
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Reset token monitoring saat masuk halaman login
    TokenMonitorService.resetMonitoring();
    print('🔄 [LOGIN_PAGE] Token monitoring reset on page init');

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
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
      create: (_) => LoginViewModel(),
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
                    const SizedBox(height: 30),
                    LogoSection(
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      title: 'Selamat Datang',
                      subtitle: 'Mulai bertani dengan mudah',
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 30),
                    _buildLoginForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<LoginViewModel>(
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
                  // Row with "Remember Me" and "Forgot Password"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: viewModel.rememberMe,
                            onChanged: viewModel.setRememberMe,
                            activeColor: const Color(0xFF4CAF50),
                          ),
                          const Text(
                            'Ingat Saya',
                            style: TextStyle(
                              color: Color(0xFF6B8E23),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (_) => ResetPasswordViewModel(),
                                child: const RequestResetView(),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Lupa Sandi?',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Masuk',
                    icon: Icons.login,
                    isLoading: viewModel.isLoading, // From BaseViewModel
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            // Validate form
                            if (!viewModel.formKey.currentState!.validate()) {
                              return;
                            }

                            // Call login method dengan parameter lengkap
                            final success = await viewModel.login(
                              email: viewModel.emailController.text.trim(),
                              password: viewModel.passwordController.text
                                  .trim(),
                              rememberMe: viewModel.rememberMe,
                            );

                            if (success && mounted) {
                              print(
                                '✅ [LOGIN_PAGE] Login success, navigating to home...',
                              );

                              // Navigate to home
                              Navigator.pushReplacementNamed(context, '/home');
                            } else if (!success && mounted) {
                              // Error sudah di-handle di ViewModel (setError)
                              print(
                                '❌ [LOGIN_PAGE] Login failed: ${viewModel.errorMessage}',
                              );
                            }
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
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
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
                        'Belum punya akun?',
                        style: TextStyle(
                          color: Color(0xFF6B8E23),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar',
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
