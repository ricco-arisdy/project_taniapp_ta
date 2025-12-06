import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/kebun_models.dart';

class KebunHomeCard extends StatelessWidget {
  final int totalKebun;
  final double totalLuas;
  final List<Kebun> recentKebun;
  final VoidCallback onTap;

  const KebunHomeCard({
    Key? key,
    required this.totalKebun,
    required this.totalLuas,
    required this.recentKebun,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalKebun == 0 || recentKebun.isEmpty) {
      return _buildEmptyState();
    }

    //Show cards
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kebun Anda',
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
        // Horizontal Scrollable Cards
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recentKebun.length,
            itemBuilder: (context, index) {
              return _buildKebunCard(recentKebun[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Kebun Anda',
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
                      color: const Color(0xFF4CAF50).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.grass_outlined,
                      size: 36,
                      color: const Color(0xFF4CAF50).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada data kebun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tambahkan kebun pertama Anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
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
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.25),
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
                          'Tambah Kebun',
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

  Widget _buildKebunCard(Kebun kebun, int index) {
    final gradients = [
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
      const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
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
              height: 60,
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
                    child: Text(
                      kebun.nama,
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
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lokasi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lokasi',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kebun.lokasi,
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

                    // Luas Kebun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.square_foot_outlined,
                              size: 13,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Luas Kebun',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
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
                            '${kebun.luas} Ha',
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
