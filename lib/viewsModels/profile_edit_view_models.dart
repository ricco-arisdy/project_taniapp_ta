import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/user_models.dart';
import 'package:project_taniapp_ta/services/profile_service.dart';
import 'package:project_taniapp_ta/viewsmodels/base_view_models.dart';

class ProfileEditViewModel extends BaseViewModel {
  final ProfileUpdateService _profileService = ProfileUpdateService();
  final TextEditingController namaController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  static final ValueNotifier<User?> profileUpdateNotifier =
      ValueNotifier<User?>(null);

  User? _currentUser;
  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    namaController.text = user.nama;
    notifyListeners();
  }

  String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  Future<bool> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final nama = namaController.text.trim();

      print('🔄 [PROFILE_EDIT_VM] Updating profile with name: $nama');

      final response = await _profileService.updateProfile(nama);

      if (response.isSuccess && response.data != null) {
        _currentUser = response.data!;

        print('✅ [PROFILE_EDIT_VM] Profile updated successfully');
        print('🔑 [PROFILE_EDIT_VM] New token automatically saved');
        print('👤 [PROFILE_EDIT_VM] Updated user: ${_currentUser!.nama}');

        profileUpdateNotifier.value = _currentUser;

        setLoading(false);
        return true;
      } else {
        setError(response.message);
        setLoading(false);
        return false;
      }
    } catch (e) {
      print('💥 [PROFILE_EDIT_VM] Error: $e');
      setError('Terjadi kesalahan: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<void> loadCurrentProfile() async {
    setLoading(true);
    clearError();

    try {
      final response = await _profileService.getCurrentProfile();

      if (response.isSuccess && response.data != null) {
        setUser(response.data!);
        setLoading(false);
      } else {
        setError(response.message);
        setLoading(false);
      }
    } catch (e) {
      setError('Gagal memuat profil: ${e.toString()}');
      setLoading(false);
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    super.dispose();
  }
}
