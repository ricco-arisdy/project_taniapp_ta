import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';
import 'package:project_taniapp_ta/views/profile/profile_edit_page.dart';
import 'package:project_taniapp_ta/viewsModels/profile_edit_view_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isPushNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPushNotificationState();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(AppConstants.userDataKey);
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _currentUser = User.fromJson(userData);
      });
    }
  }

  Future<void> _loadPushNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool('push_notification_enabled') ?? true;
    setState(() => _isPushNotificationEnabled = state);
  }

  String _formatTanggal(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> _togglePushNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notification_enabled', value);
    setState(() => _isPushNotificationEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Push Notification diaktifkan'
              : 'Push Notification dinonaktifkan',
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildMenuSection(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 16),
                    const Text(
                      'Versi 1.0.0',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            "Profil",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
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
                // 🌿 Nama pengguna - tampil lembut tapi berkarakter
                Text(
                  _currentUser?.nama ?? "Mr. John Doe",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Color(0xFF2E3A59),
                    height: 1.3,
                    fontFamily: 'Poppins', // opsional, bisa pakai Google Font
                  ),
                ),
                const SizedBox(height: 4),
                // 📧 Email - lebih ringan dan lembut
                Text(
                  _currentUser?.email ?? "user@email.com",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentUser != null
                          ? "Bergabung: ${_formatTanggal(_currentUser!.tanggalDibuat)}"
                          : "",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ ADD: Edit button
          InkWell(
            onTap: () => _handleEditProfile(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.lock_outline,
            "Ubah Kata Sandi",
            () => _showComingSoon("Ubah Kata Sandi"),
          ),
          _divider(),
          _buildMenuItem(
            Icons.help_outline,
            "Bantuan & Dukungan",
            () => _showComingSoon("Bantuan & Dukungan"),
          ),
          _divider(),
          _buildMenuItemSwitch(
            Icons.notifications_outlined,
            "Push Notification",
            _isPushNotificationEnabled,
            _togglePushNotification,
          ),
          _divider(),
          _buildMenuItem(
            Icons.description_outlined,
            "Syarat dan Ketentuan",
            () => _showComingSoon("Syarat dan Ketentuan"),
          ),
          _divider(),
          _buildMenuItem(
            Icons.security_outlined,
            "Kebijakan Privasi",
            () => _showComingSoon("Kebijakan Privasi"),
          ),
          _divider(),
          _buildMenuItem(
            Icons.info_outline,
            "Tentang Kami",
            () => _showComingSoon("Tentang Kami"),
          ),
          _divider(),
          _buildMenuItem(
            Icons.share_outlined,
            "Sosial Media",
            () => _showComingSoon("Sosial Media"),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.15));

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF94A3B8),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemSwitch(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF16A34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Keluar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Add this method to handle edit profile navigation
  Future<void> _handleEditProfile() async {
    if (_currentUser != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileEditPage(user: _currentUser!),
        ),
      );

      // If user data was updated, refresh the profile AND trigger homepage refresh
      if (result != null && result is User) {
        setState(() {
          _currentUser = result;
        });

        //Trigger profile update notification for HomePage
        ProfileEditViewModel.profileUpdateNotifier.value = result;
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF4CAF50)),
            SizedBox(width: 10),
            Text("Keluar"),
          ],
        ),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SharedPreferencesService.clearAuthData();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}
