import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/panen_models.dart';
import 'package:project_taniapp_ta/viewsModels/kebun_view_models.dart';
import 'package:project_taniapp_ta/viewsModels/panen_view_models.dart';
import 'package:project_taniapp_ta/widgets/panen/panen_form_fields.dart';
import 'package:provider/provider.dart';

class PanenFormPage extends StatefulWidget {
  final Panen? panen;

  const PanenFormPage({Key? key, this.panen}) : super(key: key);

  @override
  State<PanenFormPage> createState() => _PanenFormPageState();
}

class _PanenFormPageState extends State<PanenFormPage> {
  bool get isEditing => widget.panen != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panenVm = Provider.of<PanenViewModel>(context, listen: false);
      final kebunVm = Provider.of<KebunViewModel>(context, listen: false);

      // Load data kebun terlebih dahulu
      kebunVm.loadAllKebun();

      if (isEditing && widget.panen != null) {
        // Mode edit - set data panen
        panenVm.setSelectedPanen(widget.panen!);
      } else {
        // Mode tambah baru - pastikan form bersih
        panenVm.clearForm();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<PanenViewModel>();
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
        isEditing ? 'Edit Panen' : 'Tambah Panen',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          final vm = Provider.of<PanenViewModel>(context, listen: false);
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
    return Consumer2<PanenViewModel, KebunViewModel>(
      builder: (context, panenVm, kebunVm, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Info
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.agriculture_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEditing ? 'Edit Data Panen' : 'Tambah Panen Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing
                          ? 'Perbarui informasi panen kebun'
                          : 'Lengkapi form untuk menambah panen',
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
                    // Loading state untuk kebun
                    if (kebunVm.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (kebunVm.hasError)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Gagal memuat data kebun: ${kebunVm.errorMessage}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => kebunVm.loadAllKebun(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 32),
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    else if (kebunVm.kebunList.isEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
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
                      PanenFormFields(
                        formKey: panenVm.formKey,
                        tanggalController: panenVm.tanggalController,
                        jumlahController: panenVm.jumlahController,
                        hargaController: panenVm.hargaController,
                        catatanController: panenVm.catatanController,
                        kebunList: kebunVm.kebunList,
                        selectedKebunId: panenVm.selectedKebunId,
                        onKebunChanged: (int? value) =>
                            panenVm.setSelectedKebun(value),
                        onDatePicker: () => _selectDate(context, panenVm),
                      ),

                    // Monthly Limit Warning
                    if (!isEditing &&
                        panenVm.selectedKebunId != null &&
                        panenVm.tanggalController.text.isNotEmpty)
                      _buildMonthlyLimitWarning(panenVm, kebunVm),

                    // Error Message
                    if (panenVm.hasError) ...[
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
                                panenVm.errorMessage,
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
                    if (!kebunVm.isLoading && kebunVm.kebunList.isNotEmpty)
                      Row(
                        children: [
                          // Button Batal
                          Expanded(
                            child: OutlinedButton(
                              onPressed: panenVm.isFormLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                              onPressed: panenVm.isFormLoading
                                  ? null
                                  : () => _handleSave(panenVm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  AppColors.successGreen,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: panenVm.isFormLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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

  Widget _buildMonthlyLimitWarning(
    PanenViewModel panenVm,
    KebunViewModel kebunVm,
  ) {
    if (panenVm.isCheckingLimit) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Mengecek limit bulanan...',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (panenVm.monthlyLimitInfo != null) {
      final limitInfo = panenVm.monthlyLimitInfo!;
      final currentCount = limitInfo['current_count'] ?? 0;
      final maxLimit = limitInfo['max_limit'] ?? 2;
      final canAdd = limitInfo['can_add'] ?? false;
      final monthYear = limitInfo['month_year'] ?? '';

      // Find kebun name
      String kebunName = 'Kebun';
      try {
        final kebun = kebunVm.kebunList.firstWhere(
          (k) => k.id == panenVm.selectedKebunId,
        );
        kebunName = kebun.nama;
      } catch (e) {
        // Keep default name if not found
      }

      Color bgColor;
      Color borderColor;
      Color textColor;
      IconData icon;
      String title;

      if (canAdd) {
        if (currentCount == 0) {
          bgColor = Colors.green.shade50;
          borderColor = Colors.green.shade200;
          textColor = Colors.green.shade700;
          icon = Icons.check_circle_outline;
          title = 'Dapat Menambah Data';
        } else {
          bgColor = Colors.orange.shade50;
          borderColor = Colors.orange.shade200;
          textColor = Colors.orange.shade700;
          icon = Icons.warning_amber_outlined;
          title = 'Perhatian';
        }
      } else {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        textColor = Colors.red.shade700;
        icon = Icons.block_outlined;
        title = 'Limit Terlampaui';
      }

      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              canAdd
                  ? 'Kebun "$kebunName" memiliki $currentCount/$maxLimit data panen di bulan $monthYear.'
                  : 'Kebun "$kebunName" sudah mencapai batas maksimal $maxLimit data panen di bulan $monthYear.',
              style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
            ),
            if (!canAdd) ...[
              const SizedBox(height: 8),
              Text(
                'Hapus salah satu data panen bulan ini untuk menambah data baru.',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context, PanenViewModel vm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  void _handleSave(PanenViewModel vm) async {
    // Validate form
    if (vm.formKey.currentState?.validate() ?? false) {
      bool success;

      if (isEditing && widget.panen != null) {
        // Update existing panen
        success = await vm.updatePanen(widget.panen!.id);
      } else {
        // Create new panen
        success = await vm.createPanen();
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
                        ? 'Panen berhasil diperbarui'
                        : 'Panen berhasil ditambahkan!',
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
