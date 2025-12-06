import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/pemeliharaan_models.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/pemeiharaan_view_models.dart';
import 'package:project_taniapp_ta/widgets/pemeliharaan/pemeliharaan_form_fields.dart';
import 'package:provider/provider.dart';

class PemeliharaanFormPage extends StatefulWidget {
  final Pemeliharaan? pemeliharaan;

  const PemeliharaanFormPage({Key? key, this.pemeliharaan}) : super(key: key);

  @override
  State<PemeliharaanFormPage> createState() => _PemeliharaanFormPageState();
}

class _PemeliharaanFormPageState extends State<PemeliharaanFormPage> {
  bool get isEditing => widget.pemeliharaan != null;

  @override
  void initState() {
    super.initState();

    // Load kebun list untuk dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kebunVm = Provider.of<KebunViewModel>(context, listen: false);
      kebunVm.loadAllKebun();

      final vm = Provider.of<PemeliharaanViewModel>(context, listen: false);
      if (isEditing && widget.pemeliharaan != null) {
        // ✅ ADD: Debug info
        print(
          '🔧 [FORM_PAGE] Editing pemeliharaan: ${widget.pemeliharaan!.satuan}',
        );
        vm.setSelectedPemeliharaan(widget.pemeliharaan!);

        // ✅ ADD: Verifikasi satuan setelah set
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print(
            '🔧 [FORM_PAGE] Selected satuan after set: ${vm.selectedSatuan}',
          );
          print(
            '🔧 [FORM_PAGE] Available options: ${PemeliharaanConstants.satuanOptions}',
          );
        });
      } else {
        vm.clearForm();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<PemeliharaanViewModel>();
        vm.clearForm();
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
        isEditing ? 'Edit Pemeliharaan' : 'Tambah Pemeliharaan',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
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
    return Consumer2<PemeliharaanViewModel, KebunViewModel>(
      builder: (context, vm, kebunVm, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(AppColors.primaryGreen),
                      Color(AppColors.secondaryGreen),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.grass_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing
                          ? 'Edit Data Pemeliharaan'
                          : 'Tambah Pemeliharaan Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing
                          ? 'Perbarui informasi pemeliharaan kebun'
                          : 'Lengkapi form untuk menambah pemeliharaan',
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
                    // Loading indicator untuk kebun
                    if (kebunVm.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (kebunVm.kebunList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Belum ada kebun tersedia. Silakan tambahkan kebun terlebih dahulu.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      PemeliharaanFormFields(
                        formKey: vm.formKey,
                        kegiatanController: vm.kegiatanController,
                        tanggalController: vm.tanggalController,
                        jumlahController: vm.jumlahController,
                        biayaController: vm.biayaController,
                        catatanController: vm.catatanController,
                        kebunList: kebunVm.kebunList,
                        selectedKebunId: vm.selectedKebunId,
                        selectedSatuan: vm.selectedSatuan,
                        onKebunChanged: vm.setSelectedKebun,
                        onSatuanChanged: vm.setSelectedSatuan,
                        onDatePicker: () => _selectDate(context, vm),
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
                        Expanded(
                          child: OutlinedButton(
                            onPressed: vm.isFormLoading
                                ? null
                                : () => Navigator.pop(context),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                vm.isFormLoading || kebunVm.kebunList.isEmpty
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
                            child: vm.isFormLoading
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

  // Date picker method
  Future<void> _selectDate(
    BuildContext context,
    PemeliharaanViewModel vm,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(AppColors.primaryGreen),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(AppColors.primaryGreen),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format to DD-MM-YYYY
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      vm.tanggalController.text = '$day-$month-$year';
    }
  }

  void _handleSave(PemeliharaanViewModel vm) async {
    // Validate form
    if (vm.formKey.currentState?.validate() ?? false) {
      bool success;

      if (isEditing && widget.pemeliharaan != null) {
        // Update existing pemeliharaan
        success = await vm.updatePemeliharaan(widget.pemeliharaan!.id);
      } else {
        // Create new pemeliharaan
        success = await vm.createPemeliharaan();
      }

      if (mounted && success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEditing
                        ? 'Pemeliharaan berhasil diperbarui'
                        : 'Pemeliharaan berhasil ditambahkan!',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(AppColors.successGreen),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else if (mounted && !success) {
        // Error message already shown in ViewModel via errorMessage
        // Optionally show snackbar for specific errors
        if (vm.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vm.errorMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mohon lengkapi semua field yang diperlukan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(AppColors.warningOrange),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
