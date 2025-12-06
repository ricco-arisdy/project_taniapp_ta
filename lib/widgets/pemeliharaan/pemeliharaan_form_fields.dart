import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/widgets/kebun/formatter_number.dart';

class PemeliharaanFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController kegiatanController;
  final TextEditingController tanggalController;
  final TextEditingController jumlahController;
  final TextEditingController biayaController;
  final TextEditingController catatanController;
  final List<Kebun> kebunList;
  final int? selectedKebunId;
  final String? selectedSatuan;
  final Function(int?) onKebunChanged;
  final Function(String?) onSatuanChanged;
  final VoidCallback onDatePicker;

  const PemeliharaanFormFields({
    Key? key,
    required this.formKey,
    required this.kegiatanController,
    required this.tanggalController,
    required this.jumlahController,
    required this.biayaController,
    required this.catatanController,
    required this.kebunList,
    required this.selectedKebunId,
    this.selectedSatuan,
    required this.onKebunChanged,
    required this.onSatuanChanged,
    required this.onDatePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kebun Dropdown
          _buildKebunDropdown(),
          const SizedBox(height: 20),

          // Kegiatan Dropdown/TextField
          _buildKegiatanField(),
          const SizedBox(height: 20),

          // Tanggal Field
          _buildDateField(),
          const SizedBox(height: 20),
          Row(
            children: [
              // Jumlah Field (3/5 width)
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: jumlahController,
                  label: 'Jumlah',
                  hintText: 'Masukkan jumlah',
                  icon: Icons.analytics_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah harus diisi';
                    }

                    // Parse value tanpa titik untuk validasi
                    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                    final jumlah = int.tryParse(digitsOnly);
                    if (jumlah == null || jumlah <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Satuan Dropdown (2/5 width)
              Expanded(flex: 2, child: _buildSatuanDropdown()),
            ],
          ),
          const SizedBox(height: 20),

          // Biaya Field
          _buildTextField(
            controller: biayaController,
            label: 'Biaya (Rp)',
            hintText: 'Masukkan biaya pemeliharaan',
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Biaya harus diisi';
              }

              // ✅ Parse value tanpa titik untuk validasi
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              final biaya = int.tryParse(digitsOnly);
              if (biaya == null || biaya < 0) {
                return 'Biaya harus berupa angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Catatan Field (Optional)
          _buildTextField(
            controller: catatanController,
            label: 'Catatan (Opsional)',
            hintText: 'Tambahkan catatan pemeliharaan',
            icon: Icons.note_outlined,
            maxLines: 3,
            validator: null, // Optional field
          ),
        ],
      ),
    );
  }

  // method _buildSatuanDropdown
  Widget _buildSatuanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Satuan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // Validasi value dengan opsi yang tersedia
          value:
              selectedSatuan != null &&
                  PemeliharaanConstants.satuanOptions.contains(selectedSatuan)
              ? selectedSatuan
              : null, // Reset ke null jika tidak valid
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.straighten_outlined,
              color: Color(AppColors.infoBlue),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          hint: const Text('Pilih satuan'),
          items: PemeliharaanConstants.satuanOptions.map((satuan) {
            return DropdownMenuItem<String>(value: satuan, child: Text(satuan));
          }).toList(),
          onChanged: onSatuanChanged,
          validator: null, // Satuan bersifat opsional
        ),
      ],
    );
  }

  Widget _buildKebunDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kebun',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedKebunId,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.eco_outlined,
              color: Color(AppColors.primaryGreen),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          hint: const Text('Pilih kebun untuk pemeliharaan'),
          items: kebunList.map((Kebun kebun) {
            return DropdownMenuItem<int>(
              value: kebun.id,
              child: Container(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kebun.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${kebun.lokasi} - ${kebun.luas} Ha',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onKebunChanged,
          validator: (value) {
            if (value == null) {
              return 'Pilih kebun terlebih dahulu';
            }
            return null;
          },
          menuMaxHeight: 300,
          selectedItemBuilder: (BuildContext context) {
            return kebunList.map<Widget>((Kebun kebun) {
              return Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Text(
                  '${kebun.nama} (${kebun.luas} Ha)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildKegiatanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kegiatan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value:
              kegiatanController.text.isNotEmpty &&
                  PemeliharaanConstants.jenisKegiatanOptions.contains(
                    kegiatanController.text,
                  )
              ? kegiatanController.text
              : null,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.handyman_outlined,
              color: Color(AppColors.warningOrange),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          hint: const Text('Pilih jenis kegiatan'),
          items: PemeliharaanConstants.jenisKegiatanOptions.map((kegiatan) {
            return DropdownMenuItem<String>(
              value: kegiatan,
              child: Text(kegiatan),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              kegiatanController.text = value;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih jenis kegiatan';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Pemeliharaan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: tanggalController,
          readOnly: true,
          onTap: onDatePicker,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(AppColors.infoBlue),
            ),
            hintText: 'Pilih tanggal pemeliharaan',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih tanggal pemeliharaan';
            }

            final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
            if (!datePattern.hasMatch(value)) {
              return 'Format tanggal harus DD-MM-YYYY';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.darkGreen),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(AppColors.primaryGreen)),
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(AppColors.primaryGreen),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
