import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/viewsModels/profile_edit_view_models.dart';
import 'package:provider/provider.dart';

class ProfileEditPage extends StatefulWidget {
  final User user;

  const ProfileEditPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => ProfileEditViewModel()..setUser(widget.user),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8F4),
        body: SafeArea(
          child: Consumer<ProfileEditViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  _buildHeader(context, viewModel),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildForm(context, viewModel),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E293B),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Edit Profil",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (viewModel.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProfileEditViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildNameField(viewModel),
          const SizedBox(height: 24),
          _buildEmailField(),
          if (viewModel.hasError) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(viewModel.errorMessage),
          ],
          const SizedBox(height: 32),
          _buildSaveButton(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit Informasi Profil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Perbarui nama Anda di bawah ini",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(ProfileEditViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: viewModel.namaController,
        validator: viewModel.validateNama,
        decoration: const InputDecoration(
          labelText: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap Anda',
          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(color: Color(0xFF64748B)),
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        initialValue: widget.user.email,
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
        ),
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ProfileEditViewModel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () async {
                final success = await viewModel.updateProfile();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Profil berhasil diperbarui'),
                        ],
                      ),
                      backgroundColor: Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context, viewModel.currentUser);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
