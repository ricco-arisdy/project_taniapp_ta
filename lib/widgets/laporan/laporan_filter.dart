import 'dart:async';
import 'package:flutter/material.dart';
import '../../viewsModels/laporan_view_models.dart';
import '../../models/app_constants.dart';

class LaporanFilterWidget extends StatelessWidget {
  final LaporanViewModel viewModel;
  final Function(LaporanViewModel) onGenerateReport;

  const LaporanFilterWidget({
    super.key,
    required this.viewModel,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKebunDropdown(context),
          const SizedBox(height: 16),
          _buildDateRangeSection(context),
        ],
      ),
    );
  }

  Widget _buildKebunDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Kebun',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: viewModel.isLoadingKebun
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonFormField<int>(
                  value: viewModel.selectedKebun?.id,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down, size: 24),
                  ),
                  hint: Text(
                    'Pilih Kebun',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  items: viewModel.availableKebun.map((kebun) {
                    return DropdownMenuItem<int>(
                      value: kebun.id,
                      child: Text(
                        '${kebun.nama} - ${kebun.lokasi}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selectedKebun = viewModel.availableKebun
                          .firstWhere((kebun) => kebun.id == value);
                      viewModel.setSelectedKebun(selectedKebun);

                      Timer(const Duration(milliseconds: 300), () {
                        if (viewModel.canGenerateReport) {
                          onGenerateReport(viewModel);
                        }
                      });
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Priode',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 14, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick buttons
        Row(
          children: [
            Expanded(
              child: _buildQuickDateButton(
                  'Bulan Ini',
                  viewModel.isFilterActive &&
                      viewModel.dateRangeText.contains('Bulan Ini'), () {
                viewModel.setThisMonth();
                _generateWithDelay();
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickDateButton(
                  'Tahun Ini',
                  viewModel.isFilterActive &&
                      viewModel.dateRangeText.contains('Tahun Ini'), () {
                viewModel.setThisYear();
                _generateWithDelay();
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(
      String text, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? const Color(AppColors.primaryGreen) : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive
                ? const Color(AppColors.primaryGreen)
                : Colors.grey.shade300,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _generateWithDelay() {
    if (viewModel.canGenerateReport) {
      Timer(const Duration(milliseconds: 300), () {
        onGenerateReport(viewModel);
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          viewModel.tanggalDari != null && viewModel.tanggalSampai != null
              ? DateTimeRange(
                  start: viewModel.tanggalDari!, end: viewModel.tanggalSampai!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(AppColors.primaryGreen)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
      _generateWithDelay();
    }
  }
}
