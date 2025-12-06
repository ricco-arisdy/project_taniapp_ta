import 'package:flutter/material.dart';
import '../../models/laporan_models.dart';
import '../../models/app_constants.dart';
import '../../models/panen_models.dart';
import '../../models/pemeliharaan_models.dart';
import '../panen/panen_card.dart';
import '../pemeliharaan/pemeliharaan_card.dart';

class LaporanDataList extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final List<PemeliharaanLaporanItem> pemeliharaanData;
  final List<PanenLaporanItem> panenData;
  final bool isPemeliharaan;
  final String? kebunNama;

  const LaporanDataList({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.pemeliharaanData,
    required this.panenData,
    required this.isPemeliharaan,
    this.kebunNama,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(icon, color: const Color(AppColors.primaryGreen)),
            const SizedBox(width: 8),
            Text(
              '$title ($count)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.darkGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Data List - Menggunakan Card yang sudah ada
        if (isPemeliharaan && pemeliharaanData.isEmpty)
          _buildEmptyState('Belum ada data pemeliharaan')
        else if (!isPemeliharaan && panenData.isEmpty)
          _buildEmptyState('Belum ada data panen')
        else if (isPemeliharaan)
          ...pemeliharaanData.map((item) => _buildPemeliharaanCardWrapper(item))
        else
          ...panenData.map((item) => _buildPanenCardWrapper(item)),
      ],
    );
  }

  // Convert LaporanItem ke Pemeliharaan model
  Widget _buildPemeliharaanCardWrapper(PemeliharaanLaporanItem laporanItem) {
    final pemeliharaan = Pemeliharaan(
      id: laporanItem.id,
      kebunId: laporanItem.kebunId,
      kegiatan: laporanItem.kegiatan,
      tanggal: laporanItem.tanggal,
      jumlah: laporanItem.jumlah,
      satuan: laporanItem.satuan,
      biaya: laporanItem.biaya,
      catatan: laporanItem.catatan,
      namaKebun: kebunNama,
      lokasiKebun: null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PemeliharaanCard(
        pemeliharaan: pemeliharaan,
        kebunNama: kebunNama,
        onTap: () => _showPemeliharaanDetail(pemeliharaan),
      ),
    );
  }

  // Convert LaporanItem ke Panen model
  Widget _buildPanenCardWrapper(PanenLaporanItem laporanItem) {
    // Convert LaporanItem ke Panen model
    final panen = Panen(
      id: laporanItem.id,
      kebunId: laporanItem.kebunId,
      tanggal: laporanItem.tanggal,
      jumlah: laporanItem.jumlah,
      harga: laporanItem.harga,
      catatan: laporanItem.catatan,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PanenCard(
        panen: panen,
        kebunNama: kebunNama,
        onTap: () => _showPanenDetail(panen),
      ),
    );
  }

  // dialog untuk Pemeliharaan (read-only)
  void _showPemeliharaanDetail(Pemeliharaan pemeliharaan) {
    print('Show detail pemeliharaan: ${pemeliharaan.id}');
  }

  // dialog untuk Panen (read-only)
  void _showPanenDetail(Panen panen) {
    print('Show detail panen: ${panen.id}');
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
