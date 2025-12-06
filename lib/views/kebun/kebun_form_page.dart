import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/widgets/kebun/kebun_form_fields.dart';
import 'package:provider/provider.dart';

class KebunFormPage extends StatefulWidget {
  final Kebun? kebun;

  const KebunFormPage({Key? key, this.kebun}) : super(key: key);

  @override
  State<KebunFormPage> createState() => _KebunFormPageState();
}

class _KebunFormPageState extends State<KebunFormPage> {
  bool get isEditing => widget.kebun != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<KebunViewModel>(context, listen: false);

      if (isEditing && widget.kebun != null) {
        vm.setSelectedKebun(widget.kebun!);
      } else {
        vm.clearForm();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<KebunViewModel>();
        vm.resetForm();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        isEditing ? 'Edit Kebun' : 'Tambah Kebun',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          final vm = Provider.of<KebunViewModel>(context, listen: false);
          vm.clearForm();
          Navigator.pop(context);
        },
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(AppColors.primaryGreen),
              Color(AppColors.secondaryGreen),
            ],
          ),
        ),
      ),
      elevation: 0,
    );
  }

  Widget _buildForm() {
    return Consumer<KebunViewModel>(
      builder: (context, vm, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Info dengan rounded bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(AppColors.primaryGreen),
                      Color(AppColors.secondaryGreen),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon Circle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_activity_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      isEditing ? 'Edit Data Kebun' : 'Tambah Kebun Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      isEditing
                          ? 'Perbarui informasi kebun Anda'
                          : 'Lengkapi form untuk menambah kebun',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KebunFormFields(
                      formKey: vm.formKey,
                      namaController: vm.namaController,
                      lokasiController: vm.lokasiController,
                      luasController: vm.luasController,
                      titikTanamController: vm.titikTanamController,
                      waktuBeliController: vm.waktuBeliController,
                      selectedStatusKepemilikan: vm.selectedStatusKepemilikan,
                      selectedStatusKebun: vm.selectedStatusKebun,
                      selectedLuas: vm.selectedLuas,
                      onStatusKepemilikanChanged: vm.setStatusKepemilikan,
                      onStatusKebunChanged: vm.setStatusKebun,
                      onDatePicker: () => vm.selectDate(context),
                      isCustomLuas: vm.isCustomLuas,
                      onLuasChanged: vm.setLuas,
                    ),

                    // Error Message
                    if (vm.hasError) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vm.errorMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        // Button Batal
                        Expanded(
                          child: OutlinedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () {
                                    vm.clearForm();
                                    Navigator.pop(context);
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Button Simpan
                        Expanded(
                          child: ElevatedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () => _handleSave(vm),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                AppColors.successGreen,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: vm.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    isEditing ? 'Pembaruan' : 'Simpan',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _handleSave(KebunViewModel vm) async {
    bool success;

    if (isEditing) {
      success = await vm.updateKebun(widget.kebun!.id);
    } else {
      success = await vm.createKebun();
    }

    if (mounted) {
      if (success) {
        final message = isEditing
            ? 'Kebun berhasil diperbarui'
            : 'Kebun berhasil ditambahkan';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: const Color(AppColors.successGreen),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    }
  }
}
