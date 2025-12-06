import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:project_taniapp_ta/widgets/laporan/pdf_line_chart_painter.dart';
import '../../models/laporan_models.dart';

class LaporanPdfExport {
  static final _formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatNumber = NumberFormat('#,##0', 'id_ID');
  static Future<pw.Document> generatePdfDocument(
      LaporanData laporanData) async {
    final pdf = pw.Document();
    final kebun = laporanData.kebun;
    final pemeliharaan = laporanData.pemeliharaan.data;
    final panen = laporanData.panen.data;
    final summary = laporanData.summary;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildPdfHeader(kebun),
          pw.SizedBox(height: 20),
          _buildPdfKebunInfo(kebun, laporanData.periode),
          pw.SizedBox(height: 20),
          _buildPdfSummaryDetail(laporanData),
          pw.SizedBox(height: 20),
          _buildPdfSummaryKeuangan(summary),
          pw.SizedBox(height: 25),

          // ✅ Line Chart Panen
          if (panen.isNotEmpty) ...[
            _buildPdfPanenChart(panen, laporanData.panen),
            pw.SizedBox(height: 25),
          ],

          // ✅ Line Chart Pemeliharaan
          if (pemeliharaan.isNotEmpty) ...[
            _buildPdfPemeliharaanChart(
                pemeliharaan, laporanData.pemeliharaan.totalBiaya),
            pw.SizedBox(height: 25),
          ],

          _buildPdfPemeliharaanTable(
              pemeliharaan, laporanData.pemeliharaan.totalBiaya),
          pw.SizedBox(height: 25),
          _buildPdfPanenTable(panen, laporanData.panen),
          pw.SizedBox(height: 20),
          _buildPdfFooter(laporanData.metadata),
        ],
      ),
    );

    return pdf;
  }

  // ==================== PDF COMPONENTS ====================

  /// Build PDF Header
  static pw.Widget _buildPdfHeader(KebunLaporan kebun) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey400,
            width: 2,
          ),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'LAPORAN KEBUN',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            kebun.nama,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            kebun.lokasi,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Kebun Information Section
  static pw.Widget _buildPdfKebunInfo(
      KebunLaporan kebun, PeriodeLaporan periode) {
    String formatLuas(String luas) {
      final luasTrimmed = luas.trim();
      if (luasTrimmed.toLowerCase().contains('ha')) {
        return luasTrimmed;
      }
      return '$luasTrimmed Ha';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informasi Kebun',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildPdfInfoRow('Nama Kebun', kebun.nama),
          _buildPdfInfoRow('Lokasi', kebun.lokasi),
          _buildPdfInfoRow('Luas', formatLuas(kebun.luas)),
          _buildPdfInfoRow(
              'Titik Tanam', '${_formatNumber.format(kebun.titikTanam)} titik'),
          _buildPdfInfoRow('Status', kebun.statusKepemilikan),
          if (periode.tanggalDari != null && periode.tanggalSampai != null)
            _buildPdfInfoRow(
              'Periode',
              '${_formatDateForPdf(periode.tanggalDari!)} - ${_formatDateForPdf(periode.tanggalSampai!)}',
            )
          else
            _buildPdfInfoRow('Periode', 'Semua Waktu'),
        ],
      ),
    );
  }

  /// Build Summary Detail (dari Summary Card - Detail Page)
  static pw.Widget _buildPdfSummaryDetail(LaporanData laporanData) {
    // Hitung statistik detail
    final totalPanen = laporanData.panen.totalRecords;
    final totalPemeliharaan = laporanData.pemeliharaan.totalRecords;
    final totalJumlahKg = laporanData.panen.totalJumlahKg;

    // Hitung rata-rata harga per kg
    double hargaRataPerKg = 0;
    if (totalJumlahKg > 0 && laporanData.panen.totalPendapatan > 0) {
      hargaRataPerKg = laporanData.panen.totalPendapatan / totalJumlahKg;
    }

    String formatLuas(String luas) {
      final luasTrimmed = luas.trim();
      if (luasTrimmed.toLowerCase().contains('ha')) {
        return luasTrimmed;
      }
      return '$luasTrimmed Ha';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Icon(
                  pw.IconData(0xe574), // assessment icon
                  color: PdfColors.white,
                  size: 16,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'Statistik Detail',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Grid 2x3 (6 item)
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailStatItem(
                  'Panen',
                  totalPanen.toString(),
                  const PdfColor(0.298, 0.686, 0.314), // #4CAF50
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildDetailStatItem(
                  'Pemeliharaan',
                  totalPemeliharaan.toString(),
                  const PdfColor(1.0, 0.596, 0.0), // #FF9800
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildDetailStatItem(
                  'Luas Kebun',
                  formatLuas(laporanData.kebun.luas),
                  const PdfColor(0.129, 0.588, 0.953), // #2196F3
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildDetailStatItem(
                  'Total Kg',
                  '${_formatNumber.format(totalJumlahKg)} Kg',
                  const PdfColor(0.914, 0.118, 0.388), // #E91E63
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildDetailStatItem(
                  'Harga/Kg',
                  _formatCurrency.format(hargaRataPerKg.toInt()),
                  const PdfColor(0.0, 0.588, 0.533), // #009688
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(), // Empty untuk balance grid
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper: Build Detail Stat Item
  static pw.Widget _buildDetailStatItem(
      String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color.shade(0.2), width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            overflow: pw.TextOverflow.clip,
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.center,
            overflow: pw.TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  /// Build Financial Summary Section
  static pw.Widget _buildPdfSummaryKeuangan(SummaryLaporan summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            summary.isUntung ? PdfColors.green50 : PdfColors.red50,
            PdfColors.white,
          ],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: summary.isUntung ? PdfColors.green200 : PdfColors.red200,
          width: 2,
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'RINGKASAN KEUANGAN',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 16),

          // Biaya Pemeliharaan
          _buildPdfSummaryRow(
            'Total Biaya Pemeliharaan',
            summary.totalBiayaPemeliharaan,
            PdfColors.red700,
          ),
          pw.SizedBox(height: 8),

          // Pendapatan
          _buildPdfSummaryRow(
            'Total Pendapatan Panen',
            summary.totalPendapatan,
            PdfColors.green700,
          ),

          // Divider
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 12),
            child: pw.Divider(thickness: 2, color: PdfColors.grey400),
          ),

          // Keuntungan/Kerugian
          _buildPdfSummaryRow(
            summary.isUntung ? 'KEUNTUNGAN' : 'KERUGIAN',
            summary.totalKeuntungan,
            summary.isUntung ? PdfColors.green800 : PdfColors.red800,
            isTotal: true,
          ),

          pw.SizedBox(height: 12),
        ],
      ),
    );
  }

  /// FIXED: Build Line Chart Panen - HANYA BULAN DENGAN DATA
  static pw.Widget _buildPdfPanenChart(
      List<PanenLaporanItem> panen, PanenLaporan panenLaporan) {
    print('🚀 [PDF_PANEN] Starting panen chart generation...');
    print('   - Total panen items: ${panen.length}');

    // Group panen by month
    Map<String, List<PanenLaporanItem>> groupedByMonth = {};

    for (var item in panen) {
      try {
        final date = DateTime.parse(item.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }
        groupedByMonth[monthKey]!.add(item);
      } catch (e) {
        print('❌ [PDF_PANEN] Error parsing date: ${item.tanggal} - $e');
      }
    }

    print(
        '📊 [PDF_PANEN] Grouped by month: ${groupedByMonth.keys.length} months');

    // SOLUTION: Hanya ambil bulan yang ada datanya (sorted)
    final sortedMonthKeys = groupedByMonth.keys.toList()..sort();

    List<String> activeMonths = [];
    List<double> panen1Values = [];
    List<double> panen2Values = [];

    for (var monthKey in sortedMonthKeys) {
      final items = groupedByMonth[monthKey]!;

      // Sort by tanggal
      items.sort((a, b) {
        try {
          return DateTime.parse(a.tanggal).compareTo(DateTime.parse(b.tanggal));
        } catch (e) {
          return 0;
        }
      });

      // Format month label
      try {
        final date = DateTime.parse('$monthKey-01');
        final monthLabel = DateFormat('MMM').format(date);
        activeMonths.add(monthLabel);
      } catch (e) {
        activeMonths.add(monthKey);
      }

      // Get panen 1 & 2
      double panen1 = items[0].jumlah.toDouble();
      double panen2 = items.length > 1 ? items[1].jumlah.toDouble() : 0.0;

      panen1Values.add(panen1);
      panen2Values.add(panen2);

      print(
          '   - Month ${activeMonths.last}: panen1=$panen1 kg, panen2=$panen2 kg');
    }

    // VALIDASI
    print('🔍 [PDF_PANEN] Final validation:');
    print('   - activeMonths: $activeMonths');
    print('   - panen1Values: $panen1Values');
    print('   - panen2Values: $panen2Values');

    if (activeMonths.isEmpty) {
      // Return empty state
      return pw.Container(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Text('Tidak ada data panen'),
      );
    }

    // Create line series
    final series = [
      LineSeriesData(
        label: 'Panen 1',
        values: panen1Values,
        color: PdfColors.blue,
      ),
      LineSeriesData(
        label: 'Panen 2',
        values: panen2Values,
        color: PdfColors.green,
      ),
    ];

    print('✅ [PDF_PANEN] Chart data prepared successfully');

    // Hitung total
    int totalKg1 = panen1Values.fold(0, (sum, val) => sum + val.toInt());
    int totalKg2 = panen2Values.fold(0, (sum, val) => sum + val.toInt());
    int countPanen1 = panen1Values.where((v) => v > 0).length;
    int countPanen2 = panen2Values.where((v) => v > 0).length;

    return pw.Column(
      children: [
        PdfLineChartPainter.buildLineChart(
          title: 'Grafik Panen per Bulan',
          months: activeMonths, // ✅ Hanya bulan aktif
          series: series,
          yAxisUnit: 'kg',
          titleColor: PdfColors.green,
          titleIcon: pw.IconData(0xe558),
          chartHeight: 180,
        ),
        pw.SizedBox(height: 12),
        PdfLineChartPainter.buildSummaryCards(
          backgroundColor: PdfColors.green50,
          cards: [
            SummaryCardData(
              label: 'Total Panen 1',
              value: '${_formatNumber.format(totalKg1)} kg',
              subtitle: '${countPanen1}x panen',
              color: PdfColors.blue,
            ),
            SummaryCardData(
              label: 'Total Panen 2',
              value: '${_formatNumber.format(totalKg2)} kg',
              subtitle: '${countPanen2}x panen',
              color: PdfColors.green,
            ),
            SummaryCardData(
              label: 'Total',
              value: '${_formatNumber.format(panenLaporan.totalJumlahKg)} Kg',
              subtitle: '${panenLaporan.totalRecords}x panen',
              color: PdfColors.green700,
            ),
          ],
        ),
      ],
    );
  }

  /// Build 2 SEPARATE Line Charts untuk Pemeliharaan
  static pw.Widget _buildPdfPemeliharaanChart(
      List<PemeliharaanLaporanItem> pemeliharaan, int totalBiaya) {
    if (pemeliharaan.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(24),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          children: [
            // Header
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Icon(
                    pw.IconData(0xe1c8),
                    color: PdfColors.white,
                    size: 14,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  'Grafik Pemeliharaan per Bulan',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange.shade(0.8),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            pw.Container(
              height: 120,
              alignment: pw.Alignment.center,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Icon(
                    pw.IconData(0xe1c8),
                    size: 48,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Tidak ada data pemeliharaan',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    print('🚀 [PDF_PEMELIHARAAN] Starting pemeliharaan chart generation...');
    print('   - Total pemeliharaan items: ${pemeliharaan.length}');

    // Print semua data pemeliharaan untuk debug
    for (var i = 0; i < pemeliharaan.length; i++) {
      print(
          '   - Pemeliharaan[$i]: ${pemeliharaan[i].tanggal}, ${pemeliharaan[i].jumlah} ${pemeliharaan[i].satuan}');
    }

    Map<String, List<Map<String, dynamic>>> groupedByMonth = {};

    for (var item in pemeliharaan) {
      try {
        final date = DateTime.parse(item.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);
        final satuan = item.satuan?.toLowerCase() ?? 'kg';

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }

        // Simpan detail lengkap
        groupedByMonth[monthKey]!.add({
          'tanggal': item.tanggal,
          'jumlah': item.jumlah,
          'satuan': satuan == 'liter' ? 'liter' : 'kg',
        });
      } catch (e) {
        print('❌ [PDF_PEMELIHARAAN] Error parsing date: ${item.tanggal}');
      }
    }

    print('📊 [PDF_PEMELIHARAAN] Grouped data with details:');
    groupedByMonth.forEach((key, value) {
      print('   - $key: ${value.length} records');
      for (var detail in value) {
        print(
            '      • ${detail['tanggal']}: ${detail['jumlah']} ${detail['satuan']}');
      }
    });

    // Prepare data untuk 12 bulan
    final now = DateTime.now();
    final currentYear = now.year;

    // List<String> months12 = [];
    List<String> months12 = [];
    Map<int, List<Map<String, dynamic>>> kgDetailsPerMonth = {};
    Map<int, List<Map<String, dynamic>>> literDetailsPerMonth = {};

    for (int i = 1; i <= 12; i++) {
      final monthDate = DateTime(currentYear, i, 1);
      final monthLabel = DateFormat('MMM').format(monthDate);
      months12.add(monthLabel);

      final monthKey = DateFormat('yyyy-MM').format(monthDate);
      final details = groupedByMonth[monthKey] ?? [];

      // Pisahkan berdasarkan satuan
      final kgDetails = details.where((d) => d['satuan'] == 'kg').toList();
      final literDetails =
          details.where((d) => d['satuan'] == 'liter').toList();

      kgDetailsPerMonth[i - 1] = kgDetails;
      literDetailsPerMonth[i - 1] = literDetails;

      print(
          '   - Month $monthLabel: kg=${kgDetails.length}, liter=${literDetails.length}');
    }

    // Hitung total
    final totalKg = pemeliharaan
        .where((p) => (p.satuan?.toLowerCase() ?? 'kg') == 'kg')
        .fold<int>(0, (sum, p) => sum + p.jumlah);
    final totalLiter = pemeliharaan
        .where((p) => (p.satuan?.toLowerCase() ?? '') == 'liter')
        .fold<int>(0, (sum, p) => sum + p.jumlah);
    final countKg = pemeliharaan
        .where((p) => (p.satuan?.toLowerCase() ?? 'kg') == 'kg')
        .length;
    final countLiter = pemeliharaan
        .where((p) => (p.satuan?.toLowerCase() ?? '') == 'liter')
        .length;

    print('   - totalKg: $totalKg, countKg: $countKg');
    print('   - totalLiter: $totalLiter, countLiter: $countLiter');
    // RETURN: 2 CHART TERPISAH
    return pw.Column(
      children: [
        // CHART 1: Material Padat (Kg)
        _buildDetailedLineChart(
          title: 'Material Padat (Kg)',
          months: months12,
          detailsPerMonth: kgDetailsPerMonth,
          color: PdfColors.deepOrange,
          unit: 'kg',
          titleIcon: pw.IconData(0xe1c8),
        ),

        pw.SizedBox(height: 20),

        // CHART 2: Material Cair (Liter)
        _buildDetailedLineChart(
          title: 'Material Cair (Liter)',
          months: months12,
          detailsPerMonth: literDetailsPerMonth,
          color: PdfColors.blue,
          unit: 'L',
          titleIcon: pw.IconData(0xe1c8),
        ),

        pw.SizedBox(height: 12),

        // Summary Cards
        PdfLineChartPainter.buildSummaryCards(
          backgroundColor: PdfColors.orange50,
          cards: [
            SummaryCardData(
              label: 'Total Kg',
              value: '${_formatNumber.format(totalKg)} Kg',
              subtitle: '${countKg}x pemeliharaan',
              color: PdfColors.deepOrange,
            ),
            SummaryCardData(
              label: 'Total Liter',
              value: '${_formatNumber.format(totalLiter)} L',
              subtitle: '${countLiter}x pemeliharaan',
              color: PdfColors.blue,
            ),
            SummaryCardData(
              label: 'Total Biaya',
              value: _formatCurrency.format(totalBiaya),
              color: PdfColors.orange,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDetailedLineChart({
    required String title,
    required List<String> months,
    required Map<int, List<Map<String, dynamic>>> detailsPerMonth,
    required PdfColor color,
    required String unit,
    required pw.IconData titleIcon,
  }) {
    // Convert details to values list untuk calculate maxY
    List<double> allValues = [];
    for (var details in detailsPerMonth.values) {
      for (var detail in details) {
        allValues.add(detail['jumlah'].toDouble());
      }
    }

    // Jika tidak ada data, return empty state
    if (allValues.isEmpty || allValues.every((v) => v == 0)) {
      return _buildNoDataChartPlaceholder(title, color);
    }

    // Create LineSeriesData dengan semua detail
    return PdfLineChartPainter.buildDetailedLineChart(
      title: title,
      months: months,
      detailsPerMonth: detailsPerMonth,
      color: color,
      yAxisUnit: unit,
      titleColor: color,
      titleIcon: titleIcon,
      chartHeight: 140,
    );
  }

  /// Helper untuk chart placeholder ketika tidak ada data
  static pw.Widget _buildNoDataChartPlaceholder(String title, PdfColor color) {
    return pw.Container(
      height: 140,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Icon(
            pw.IconData(0xe88f), // show_chart icon
            size: 32,
            color: PdfColors.grey400,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Tidak ada data',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Pemeliharaan Table
  static pw.Widget _buildPdfPemeliharaanTable(
      List<PemeliharaanLaporanItem> pemeliharaan, int totalBiaya) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Section Title
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.orange200),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Icon(
                  pw.IconData(0xe1c8), // grass icon
                  color: PdfColors.white,
                  size: 16,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'Data Pemeliharaan (${pemeliharaan.length} kegiatan)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 12),

        // Table or Empty State
        if (pemeliharaan.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Belum ada data pemeliharaan',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange100),
                children: [
                  _buildPdfTableCell('Tanggal', isHeader: true),
                  _buildPdfTableCell('Kegiatan', isHeader: true),
                  _buildPdfTableCell('Jumlah', isHeader: true),
                  _buildPdfTableCell('Biaya', isHeader: true),
                ],
              ),
              // Data Rows
              ...pemeliharaan.map((item) => pw.TableRow(
                    children: [
                      _buildPdfTableCell(_formatDateForPdf(item.tanggal)),
                      _buildPdfTableCell(
                        item.kegiatan,
                        align: pw.Alignment.centerLeft,
                      ),
                      _buildPdfTableCell(
                        '${item.jumlah} ${item.satuan ?? ''}',
                      ),
                      _buildPdfTableCell(
                        _formatCurrency.format(item.biaya),
                        align: pw.Alignment.centerRight,
                      ),
                    ],
                  )),
              // Total Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange200),
                children: [
                  _buildPdfTableCell('TOTAL', isHeader: true, colSpan: 3),
                  _buildPdfTableCell('', isHeader: true),
                  _buildPdfTableCell('', isHeader: true),
                  _buildPdfTableCell(
                    _formatCurrency.format(totalBiaya),
                    isHeader: true,
                    align: pw.Alignment.centerRight,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  /// Build Panen Table
  static pw.Widget _buildPdfPanenTable(
      List<PanenLaporanItem> panen, PanenLaporan panenLaporan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Section Title
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.green200),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Icon(
                  pw.IconData(0xe558), // agriculture icon
                  color: PdfColors.white,
                  size: 16,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'Data Panen (${panen.length} kali panen)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 12),

        // Table or Empty State
        if (panen.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Belum ada data panen',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  _buildPdfTableCell('Tanggal', isHeader: true),
                  _buildPdfTableCell('Jumlah (kg)', isHeader: true),
                  _buildPdfTableCell('Harga/kg', isHeader: true),
                  _buildPdfTableCell('Total', isHeader: true),
                ],
              ),
              // Data Rows
              ...panen.map((item) => pw.TableRow(
                    children: [
                      _buildPdfTableCell(_formatDateForPdf(item.tanggal)),
                      _buildPdfTableCell('${item.jumlah} kg'),
                      _buildPdfTableCell(
                        _formatCurrency.format(item.harga),
                        align: pw.Alignment.centerRight,
                      ),
                      _buildPdfTableCell(
                        _formatCurrency.format(item.total),
                        align: pw.Alignment.centerRight,
                      ),
                    ],
                  )),
              // Total Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green200),
                children: [
                  _buildPdfTableCell('TOTAL', isHeader: true),
                  _buildPdfTableCell(
                    '${panenLaporan.totalJumlahKg} kg',
                    isHeader: true,
                  ),
                  _buildPdfTableCell('', isHeader: true),
                  _buildPdfTableCell(
                    _formatCurrency.format(panenLaporan.totalPendapatan),
                    isHeader: true,
                    align: pw.Alignment.centerRight,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  /// Build PDF Footer
  static pw.Widget _buildPdfFooter(MetadataLaporan metadata) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'Laporan dibuat oleh: ${metadata.userName}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Tanggal cetak: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Info Row (Key-Value)
  static pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Summary Row (Financial)
  static pw.Widget _buildPdfSummaryRow(
    String label,
    int value,
    PdfColor color, {
    bool isTotal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 14 : 12,
            color: color,
          ),
        ),
        pw.Text(
          _formatCurrency.format(value),
          style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 14 : 12,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Build Table Cell
  static pw.Widget _buildPdfTableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment? align,
    int colSpan = 1,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: align ?? pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
          color: isHeader ? PdfColors.grey900 : PdfColors.grey800,
        ),
        textAlign: align == pw.Alignment.centerLeft
            ? pw.TextAlign.left
            : align == pw.Alignment.centerRight
                ? pw.TextAlign.right
                : pw.TextAlign.center,
      ),
    );
  }

  /// Format Date for PDF (DD/MM/YYYY)
  static String _formatDateForPdf(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print('❌ Error formatting date: $dateStr');
      return dateStr;
    }
  }
}
