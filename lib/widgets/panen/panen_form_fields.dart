import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';
import 'package:project_taniapp_ta/widgets/kebun/formatter_number.dart';

class PanenFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tanggalController;
  final TextEditingController jumlahController;
  final TextEditingController hargaController;
  final TextEditingController catatanController;
  final List<Kebun> kebunList;
  final int? selectedKebunId;
  final Function(int?) onKebunChanged;
  final VoidCallback onDatePicker;

  const PanenFormFields({
    Key? key,
    required this.formKey,
    required this.tanggalController,
    required this.jumlahController,
    required this.hargaController,
    required this.catatanController,
    required this.kebunList,
    required this.selectedKebunId,
    required this.onKebunChanged,
    required this.onDatePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilih Kebun
          _buildKebunDropdown(),
          const SizedBox(height: 16),

          // Tanggal Panen
          _buildDateField(),
          const SizedBox(height: 16),

          // Jumlah Panen
          _buildTextField(
            controller: jumlahController,
            label: 'Jumlah Panen (Kg)',
            icon: Icons.scale_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah panen harus diisi';
              }

              // Parse value tanpa titik untuk validasi
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (int.tryParse(digitsOnly) == null) {
                return 'Harus berupa angka';
              }
              if (int.parse(digitsOnly) <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Harga per Kg
          _buildTextField(
            controller: hargaController,
            label: 'Harga per Kg (Rp)',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga harus diisi';
              }

              // ✅ Parse value tanpa titik untuk validasi
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (int.tryParse(digitsOnly) == null) {
                return 'Harus berupa angka';
              }
              if (int.parse(digitsOnly) < 0) {
                return 'Harga tidak boleh negatif';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Catatan (Optional)
          _buildTextField(
            controller: catatanController,
            label: 'Catatan (Opsional)',
            icon: Icons.note_outlined,
            maxLines: 3,
            validator: null, // Optional field
          ),
        ],
      ),
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
              Icons.local_activity_outlined,
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
          hint: const Text('Pilih kebun untuk panen'),
          items: kebunList.map((Kebun kebun) {
            return DropdownMenuItem<int>(
              value: kebun.id,
              child: Container(
                // Container untuk kontrol layout
                constraints: const BoxConstraints(
                  maxWidth: double.infinity, // Maksimal lebar
                ),
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
          menuMaxHeight: 300, // Maksimal tinggi dropdown menu
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Panen',
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
              color: Color(AppColors.primaryGreen),
            ),
            hintText: 'Pilih tanggal',
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
              return 'Tanggal panen harus dipilih';
            }

            // ✅ ADD DD-MM-YYYY format validation
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
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(AppColors.primaryGreen)),
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
        ),
      ],
    );
  }
}
