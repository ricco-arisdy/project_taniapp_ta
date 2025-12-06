import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';
import 'package:project_taniapp_ta/models/pemeliharaan_models.dart';

class PemeliharaanCard extends StatelessWidget {
  final Pemeliharaan pemeliharaan;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? kebunNama;

  const PemeliharaanCard({
    Key? key,
    required this.pemeliharaan,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.kebunNama,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format number dengan pemisah ribuan manual
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    String formatNumber(int number) {
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    // Parse tanggal
    DateTime tanggalPemeliharaan;
    try {
      tanggalPemeliharaan = DateTime.parse(pemeliharaan.tanggal);
    } catch (e) {
      try {
        final parts = pemeliharaan.tanggal.split('-');
        if (parts.length == 3) {
          tanggalPemeliharaan = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        } else {
          tanggalPemeliharaan = DateTime.now();
        }
      } catch (e) {
        tanggalPemeliharaan = DateTime.now();
      }
    }

    String formatDateHeader(DateTime date) {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      return '$day-$month-${date.year}';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kebun Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              AppColors.primaryGreen,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.grass_outlined,
                            color: const Color(AppColors.primaryGreen),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kebunNama ?? pemeliharaan.namaKebun ?? 'Kebun',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),

                              Text(
                                formatDateHeader(tanggalPemeliharaan),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Color(AppColors.primaryGreen),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.handyman_outlined,
                      label: 'Kegiatan',
                      value: pemeliharaan.kegiatan,
                      color: const Color(AppColors.warningOrange),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.analytics_outlined,
                      label: 'Jumlah',
                      value:
                          '${formatNumber(pemeliharaan.jumlah)}${pemeliharaan.satuan != null ? ' ${pemeliharaan.satuan}' : ''}',
                      color: const Color(AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Biaya Row (TETAP SAMA)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.successGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(AppColors.successGreen).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: const Color(AppColors.successGreen),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rp ${formatNumber(pemeliharaan.biaya)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.successGreen),
                      ),
                    ),
                  ],
                ),
              ),

              // Catatan (if exists) - TETAP SAMA
              if (pemeliharaan.catatan != null &&
                  pemeliharaan.catatan!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // color: Colors.grey[100],
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pemeliharaan.catatan!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
