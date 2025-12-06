import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/panen_models.dart';

class PanenHomeCard extends StatelessWidget {
  final int totalPanen;
  final double totalPendapatan;
  final List<Panen> recentPanen;
  final VoidCallback onTap;

  const PanenHomeCard({
    Key? key,
    required this.totalPanen,
    required this.totalPendapatan,
    required this.recentPanen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPanen == 0 || recentPanen.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Panen Terbaru" dengan "Lihat semua"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Panen Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: Color.fromARGB(255, 92, 231, 96),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color.fromARGB(255, 92, 231, 96),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recentPanen.length,
            itemBuilder: (context, index) {
              return _buildPanenCard(recentPanen[index], index);
            },
          ),
        ),
      ],
    );
  }

  // Empty state widget - SAMA seperti KebunCard
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Panen Terbaru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 12),

          // Empty state card
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.agriculture_outlined,
                      size: 36,
                      color: const Color(0xFFFF9800).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada data panen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Catat hasil panen pertama Anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      fontFamily: 'SF Pro Display',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Tambah Panen',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card design yang KONSISTEN dengan KebunCard
  Widget _buildPanenCard(Panen panen, int index) {
    // Format number helper
    String formatNumber(int number) {
      final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return number.toString().replaceAllMapped(
        formatter,
        (Match m) => '${m[1]}.',
      );
    }

    // Format date helper
    String formatDate(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        // Format: DD-MM-YYYY dengan leading zero
        String day = date.day.toString().padLeft(2, '0');
        String month = date.month.toString().padLeft(2, '0');
        return '$day-$month-${date.year}';
      } catch (e) {
        return dateString;
      }
    }

    String getKebunName() {
      // Jika ada namaKebun dari join query API
      if (panen.namaKebun != null && panen.namaKebun!.isNotEmpty) {
        return panen.namaKebun!;
      }

      // Fallback ke "Kebun {ID}" jika nama tidak ada
      return 'Kebun ${panen.kebunId}';
    }

    final gradients = [
      const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: gradients[index % gradients.length],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_activity_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getKebunName(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                            fontFamily: 'SF Pro Display',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        Text(
                          formatDate(panen.tanggal),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
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

            // struktur dengan KebunCard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.scale_outlined,
                              size: 13,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Jumlah Panen',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatNumber(panen.jumlah)} Kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.1,
                            fontFamily: 'SF Pro Display',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 13,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Total Nilai',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: gradients[index % gradients.length]
                                .colors
                                .first
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rp ${formatNumber(panen.totalNilai)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: gradients[index % gradients.length]
                                  .colors
                                  .first,
                              letterSpacing: 0.2,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ],
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
}
