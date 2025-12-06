import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/panen_models.dart';

class PanenCard extends StatelessWidget {
  final Panen panen;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? kebunNama;

  const PanenCard({
    Key? key,
    required this.panen,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.kebunNama,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    // Format number dengan pemisah ribuan manual
    String formatNumber(int number) {
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    // Format tanggal manual
    DateTime tanggalPanen;
    try {
      tanggalPanen = DateTime.parse(panen.tanggal);
    } catch (e) {
      tanggalPanen = DateTime.now();
    }

    // Fungsi format tanggal
    String formatDate(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(
                        AppColors.primaryGreen,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.agriculture_outlined,
                      color: Color(AppColors.primaryGreen),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Kebun atau ID
                        Text(
                          kebunNama ?? 'Kebun ID: ${panen.kebunId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.darkGreen),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Tanggal Panen
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDate(tanggalPanen),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Color(AppColors.primaryGreen),
                                ),
                                const SizedBox(width: 8),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(AppColors.errorRed),
                                ),
                                const SizedBox(width: 8),
                                const Text('Hapus'),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Statistics Row
              Row(
                children: [
                  // Jumlah Panen
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.scale_outlined,
                      label: 'Jumlah',
                      value: '${formatNumber(panen.jumlah)} Kg',
                      color: const Color(AppColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Harga per Kg
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.attach_money_outlined,
                      label: 'Harga/Kg',
                      value: 'Rp ${formatNumber(panen.harga)}',
                      color: const Color(AppColors.secondaryGreen),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Total Nilai Row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.successGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(AppColors.successGreen).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(
                          AppColors.successGreen,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.monetization_on_outlined,
                        color: Color(AppColors.successGreen),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Nilai',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rp ${formatNumber(panen.totalNilai)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.successGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Catatan (jika ada)
              if (panen.catatan != null && panen.catatan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              panen.catatan!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
