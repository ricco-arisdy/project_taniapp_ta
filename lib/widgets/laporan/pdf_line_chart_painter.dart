import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfLineChartPainter {
  static final _formatNumber = NumberFormat('#,##0', 'id_ID');

  static pw.Widget buildLineChart({
    required String title,
    required List<String> months,
    required List<LineSeriesData> series,
    required String yAxisUnit,
    PdfColor? titleColor,
    pw.IconData? titleIcon,
    double chartHeight = 180,
  }) {
    // VALIDASI: Cek apakah ada data
    bool hasAnyData = false;
    for (var lineSeries in series) {
      if (lineSeries.values.any((v) => v > 0)) {
        hasAnyData = true;
        break;
      }
    }

    // RETURN EMPTY STATE jika tidak ada data sama sekali
    if (!hasAnyData) {
      return _buildEmptyChartState(
        title,
        titleColor ?? PdfColors.blue,
        titleIcon,
      );
    }

    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      if (s.values.length != months.length) {
        throw Exception(
          'CRITICAL ERROR: ${s.label} has ${s.values.length} values, '
          'but months has ${months.length} items!',
        );
      }
    }

    double maxY = 0;
    for (var lineSeries in series) {
      for (var value in lineSeries.values) {
        if (value > maxY) maxY = value;
      }
    }

    // Pastikan maxY tidak 0
    if (maxY == 0) {
      maxY = 1000; // Default minimal untuk chart
    }

    maxY = _roundUpMax(maxY);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildChartHeader(title, titleColor ?? PdfColors.blue, titleIcon),
          pw.SizedBox(height: 12),
          _buildLegend(series),
          pw.SizedBox(height: 16),
          pw.Container(
            height: chartHeight,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildYAxisLabels(maxY, yAxisUnit),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(
                      right: 16,
                    ), // ✅ TAMBAH: Right padding
                    child: _buildChartCanvas(
                      months: months,
                      series: series,
                      maxY: maxY,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          _buildXAxisLabels(months),
        ],
      ),
    );
  }

  // ✅ NEW: Empty state untuk chart tanpa data
  static pw.Widget _buildEmptyChartState(
    String title,
    PdfColor color,
    pw.IconData? icon,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          _buildChartHeader(title, color, icon),
          pw.SizedBox(height: 24),
          pw.Container(
            height: 120,
            alignment: pw.Alignment.center,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Icon(
                  pw.IconData(0xe88f), // show_chart icon
                  size: 48,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Tidak ada data untuk ditampilkan',
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

  static pw.Widget _buildChartHeader(
    String title,
    PdfColor color,
    pw.IconData? icon,
  ) {
    return pw.Row(
      children: [
        if (icon != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Icon(icon, color: PdfColors.white, size: 14),
          ),
          pw.SizedBox(width: 10),
        ],
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: color.shade(0.8),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildLegend(List<LineSeriesData> series) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: series.map((lineSeries) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12),
          child: pw.Row(
            children: [
              pw.Container(
                width: 16,
                height: 3,
                decoration: pw.BoxDecoration(
                  color: lineSeries.color,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                lineSeries.label,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildChartCanvas({
    required List<String> months,
    required List<LineSeriesData> series,
    required double maxY,
  }) {
    return pw.CustomPaint(
      painter: (PdfGraphics canvas, PdfPoint size) {
        _drawGridLines(canvas, size, maxY);

        // Draw lines and dots
        for (var i = 0; i < series.length; i++) {
          _drawLine(canvas, size, series[i].values, maxY, series[i].color);
        }

        for (var i = 0; i < series.length; i++) {
          _drawDots(canvas, size, series[i].values, maxY, series[i].color);
        }
      },
    );
  }

  static pw.Widget _buildYAxisLabels(double maxY, String unit) {
    // Gunakan interval dinamis seperti di mobile
    final interval = _calculateDynamicInterval(maxY);
    final steps = (maxY / interval).round();

    return pw.Container(
      width: 60,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: List.generate(steps + 1, (index) {
          // Generate dari maxY ke 0 dengan interval dinamis
          final value = maxY - (index * interval);
          return pw.Text(
            '${value.toInt()} $unit',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          );
        }),
      ),
    );
  }

  // Method untuk hitung interval dinamis (sama dengan mobile)
  static double _calculateDynamicInterval(double maxY) {
    if (maxY <= 0) return 20.0;

    if (maxY <= 100) {
      return 20.0; // 0, 20, 40, 60, 80, 100
    } else if (maxY <= 200) {
      return 50.0; // 0, 50, 100, 150, 200
    } else if (maxY <= 500) {
      return 100.0; // 0, 100, 200, 300, 400, 500
    } else if (maxY <= 1000) {
      return 200.0; // 0, 200, 400, 600, 800, 1000
    } else if (maxY <= 2000) {
      return 500.0; // 0, 500, 1000, 1500, 2000
    } else {
      return 1000.0; // 0, 1000, 2000, 3000, ...
    }
  }

  static void _drawGridLines(PdfGraphics canvas, PdfPoint size, double maxY) {
    // Gunakan interval dinamis
    final interval = _calculateDynamicInterval(maxY);
    final steps = (maxY / interval).round();
    final stepHeight = size.y / steps;

    canvas
      ..setStrokeColor(PdfColors.grey300)
      ..setLineWidth(0.5);

    for (int i = 0; i <= steps; i++) {
      final y = i * stepHeight;
      canvas
        ..drawLine(0, y, size.x, y)
        ..strokePath();
    }
  }

  static void _drawLine(
    PdfGraphics canvas,
    PdfPoint size,
    List<double> values,
    double maxY,
    PdfColor lineColor,
  ) {
    if (values.isEmpty || maxY <= 0 || maxY.isNaN || maxY.isInfinite) {
      print('⚠️ [PDF_CHART] Skipping line draw - invalid data');
      return;
    }

    final chartWidth = size.x;
    final chartHeight = size.y;
    final dataPoints = values.length;
    final stepX = chartWidth / (dataPoints - 1).clamp(1, dataPoints);

    print('🎨 [PDF_CHART] Drawing line:');
    print('   - values: $values');
    print('   - maxY: $maxY');
    print('   - stepX: $stepX');

    // PERBAIKAN: Collect SEMUA points (termasuk 0)
    List<PdfPoint?> allPoints = [];

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;

      // CHANGED: Jangan skip value 0, tetap buat point
      if (values[i] >= 0) {
        // Dari ">" jadi ">="
        final normalizedValue = values[i] / maxY;

        if (normalizedValue.isNaN || normalizedValue.isInfinite) {
          print('⚠️ [PDF_CHART] Invalid normalized value at index $i');
          allPoints.add(null);
          continue;
        }

        final y = chartHeight * normalizedValue;

        if (y.isNaN || y.isInfinite) {
          print('⚠️ [PDF_CHART] Invalid Y coordinate at index $i');
          allPoints.add(null);
          continue;
        }

        print('   - Point[$i]: value=${values[i]}, x=$x, y=$y');
        allPoints.add(PdfPoint(x, y));
      } else {
        allPoints.add(null);
      }
    }

    // Draw line connecting all points
    canvas
      ..setStrokeColor(lineColor)
      ..setLineWidth(2.5);

    bool isPathStarted = false;

    for (int i = 0; i < allPoints.length; i++) {
      if (allPoints[i] != null) {
        final currentPoint = allPoints[i]!;
        if (!isPathStarted) {
          canvas.moveTo(currentPoint.x, currentPoint.y);
          isPathStarted = true;
        } else {
          canvas.lineTo(currentPoint.x, currentPoint.y);
        }
      }
    }

    if (isPathStarted) {
      canvas.strokePath();
      print('✅ [PDF_CHART] Line drawn successfully');
    } else {
      print('⚠️ [PDF_CHART] No valid points to draw line');
    }
  }

  static void _drawDots(
    PdfGraphics canvas,
    PdfPoint size,
    List<double> values,
    double maxY,
    PdfColor dotColor,
  ) {
    if (values.isEmpty || maxY <= 0 || maxY.isNaN || maxY.isInfinite) {
      print('⚠️ [PDF_CHART] Skipping dots draw - invalid data');
      return;
    }

    final chartWidth = size.x;
    final chartHeight = size.y;
    final dataPoints = values.length;
    final stepX = chartWidth / (dataPoints - 1).clamp(1, dataPoints);
    final dotRadius = 4.0;

    for (int i = 0; i < values.length; i++) {
      //  TETAP: Skip dot untuk value 0
      if (values[i] > 0) {
        final x = i * stepX;
        final normalizedValue = values[i] / maxY;

        if (normalizedValue.isNaN || normalizedValue.isInfinite) {
          continue;
        }

        final y = chartHeight * normalizedValue;

        if (y.isNaN || y.isInfinite) {
          continue;
        }

        // Fill dot
        canvas
          ..setFillColor(dotColor)
          ..drawEllipse(x, y, dotRadius, dotRadius)
          ..fillPath();

        // White border
        canvas
          ..setStrokeColor(PdfColors.white)
          ..setLineWidth(2.0)
          ..drawEllipse(x, y, dotRadius, dotRadius)
          ..strokePath();
      }
    }
  }

  static pw.Widget _buildXAxisLabels(List<String> months) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 68, right: 16),
      child: pw.Row(
        children: months.map((month) {
          return pw.Expanded(
            child: pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                month,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build line chart dengan multiple dots per month
  static pw.Widget buildDetailedLineChart({
    required String title,
    required List<String> months,
    required Map<int, List<Map<String, dynamic>>> detailsPerMonth,
    required PdfColor color,
    required String yAxisUnit,
    PdfColor? titleColor,
    pw.IconData? titleIcon,
    double chartHeight = 180,
  }) {
    // Calculate maxY dari semua detail
    double maxY = 0;
    for (var details in detailsPerMonth.values) {
      for (var detail in details) {
        final value = detail['jumlah'].toDouble();
        if (value > maxY) maxY = value;
      }
    }

    if (maxY == 0) maxY = 100;
    maxY = _roundUpMax(maxY * 1.2);

    print('📊 [PDF_DETAILED_CHART] MaxY: $maxY, Unit: $yAxisUnit');

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildChartHeader(title, titleColor ?? color, titleIcon),
          pw.SizedBox(height: 16),
          pw.Container(
            height: chartHeight,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildYAxisLabels(maxY, yAxisUnit),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(
                      right: 16,
                    ), // Konsisten dengan X-axis labels
                    child: _buildDetailedChartCanvas(
                      months: months,
                      detailsPerMonth: detailsPerMonth,
                      maxY: maxY,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          _buildXAxisLabels(months),
        ],
      ),
    );
  }

  /// Build canvas dengan multiple dots per month
  static pw.Widget _buildDetailedChartCanvas({
    required List<String> months,
    required Map<int, List<Map<String, dynamic>>> detailsPerMonth,
    required double maxY,
    required PdfColor color,
  }) {
    return pw.CustomPaint(
      painter: (PdfGraphics canvas, PdfPoint size) {
        _drawGridLines(canvas, size, maxY);

        // ✅ Draw connecting line (hanya untuk dots yang ada)
        _drawDetailedLine(canvas, size, months, detailsPerMonth, maxY, color);

        // ✅ Draw all dots
        _drawDetailedDots(canvas, size, months, detailsPerMonth, maxY, color);
      },
    );
  }

  /// Draw line connecting ALL individual dots (bukan rata-rata)
  static void _drawDetailedLine(
    PdfGraphics canvas,
    PdfPoint size,
    List<String> months,
    Map<int, List<Map<String, dynamic>>> detailsPerMonth,
    double maxY,
    PdfColor lineColor,
  ) {
    final chartWidth = size.x;
    final chartHeight = size.y;
    final stepX = chartWidth / (months.length - 1).clamp(1, months.length);

    canvas
      ..setStrokeColor(lineColor)
      ..setLineWidth(2.5);

    print('🎨 [PDF_LINE] Drawing detailed line:');

    // Collect ALL dots dengan X offset yang sama dengan _drawDetailedDots
    List<PdfPoint> allDotPoints = [];

    for (int i = 0; i < months.length; i++) {
      final details = detailsPerMonth[i] ?? [];

      if (details.isEmpty) continue;

      final baseX = i * stepX;

      // Sort by value (sama seperti di _drawDetailedDots)
      details.sort(
        (a, b) => (a['jumlah'] as num).compareTo(b['jumlah'] as num),
      );

      if (details.length == 1) {
        // Single dot
        final value = details[0]['jumlah'].toDouble();
        final normalizedValue = value / maxY;
        final y = chartHeight * normalizedValue;

        allDotPoints.add(PdfPoint(baseX, y));
        print('   - Month $i: Single dot at ($baseX, $y)');
      } else {
        // Multiple dots - SEMUA dots di bulan yang sama
        for (int j = 0; j < details.length; j++) {
          final value = details[j]['jumlah'].toDouble();
          final normalizedValue = value / maxY;
          final y = chartHeight * normalizedValue;

          // Calculate horizontal offset (SAMA PERSIS dengan _drawDetailedDots)
          double xOffset = 0;
          if (details.length == 2) {
            xOffset = j == 0 ? -3 : 3;
          } else if (details.length == 3) {
            xOffset = (j - 1) * 3;
          } else {
            final spread = 6.0;
            xOffset =
                (j - (details.length - 1) / 2) * spread / (details.length - 1);
          }

          final x = baseX + xOffset;
          allDotPoints.add(PdfPoint(x, y));
          print('   - Month $i, Dot[$j]: at ($x, $y) offset=$xOffset');
        }
      }
    }

    // Draw line connecting ALL dots in sequence
    if (allDotPoints.isEmpty) {
      print('⚠️ [PDF_LINE] No dots to connect');
      return;
    }

    // Start from first dot
    canvas.moveTo(allDotPoints[0].x, allDotPoints[0].y);
    print('   ✅ Line starts at (${allDotPoints[0].x}, ${allDotPoints[0].y})');

    // Connect to all subsequent dots
    for (int i = 1; i < allDotPoints.length; i++) {
      canvas.lineTo(allDotPoints[i].x, allDotPoints[i].y);
      print('   ✅ Line to (${allDotPoints[i].x}, ${allDotPoints[i].y})');
    }

    canvas.strokePath();
    print(
      '✅ [PDF_LINE] Line drawn successfully connecting ${allDotPoints.length} dots',
    );
  }

  ///Draw all dots (multiple per month if exists)
  static void _drawDetailedDots(
    PdfGraphics canvas,
    PdfPoint size,
    List<String> months,
    Map<int, List<Map<String, dynamic>>> detailsPerMonth,
    double maxY,
    PdfColor dotColor,
  ) {
    final chartWidth = size.x;
    final chartHeight = size.y;
    final stepX = chartWidth / (months.length - 1).clamp(1, months.length);
    final dotRadius = 4.0;

    print('🎨 [PDF_DOTS] Drawing dots:');

    for (int i = 0; i < months.length; i++) {
      final details = detailsPerMonth[i] ?? [];

      if (details.isEmpty) continue;

      final baseX = i * stepX;

      print('   - Month ${months[i]}: ${details.length} dots');

      if (details.length == 1) {
        // Hanya 1 dot, taruh di tengah
        final value = details[0]['jumlah'].toDouble();
        final normalizedValue = value / maxY;
        final y = chartHeight * normalizedValue;

        _drawSingleDot(canvas, baseX, y, dotRadius, dotColor);
        print('      • Single dot at x=$baseX, y=$y, value=$value');
      } else {
        // Multiple dots, spread horizontal dengan offset
        // Sort by value untuk urutan yang rapi
        details.sort(
          (a, b) => (a['jumlah'] as num).compareTo(b['jumlah'] as num),
        );

        for (int j = 0; j < details.length; j++) {
          final value = details[j]['jumlah'].toDouble();
          final normalizedValue = value / maxY;
          final y = chartHeight * normalizedValue;

          // Calculate horizontal offset
          double xOffset = 0;
          if (details.length == 2) {
            // Untuk 2 dots: kiri dan kanan
            xOffset = j == 0 ? -3 : 3;
          } else if (details.length == 3) {
            // Untuk 3 dots: kiri, tengah, kanan
            xOffset = (j - 1) * 3;
          } else {
            // Untuk 4+ dots: spread evenly
            final spread = 6.0;
            xOffset =
                (j - (details.length - 1) / 2) * spread / (details.length - 1);
          }

          final x = baseX + xOffset;
          _drawSingleDot(canvas, x, y, dotRadius, dotColor);
          print(
            '      • Dot[$j] at x=$x (offset=$xOffset), y=$y, value=$value',
          );
        }
      }
    }
  }

  /// Helper: Draw single dot
  static void _drawSingleDot(
    PdfGraphics canvas,
    double x,
    double y,
    double radius,
    PdfColor color,
  ) {
    // Fill dot
    canvas
      ..setFillColor(color)
      ..drawEllipse(x, y, radius, radius)
      ..fillPath();

    // White border
    canvas
      ..setStrokeColor(PdfColors.white)
      ..setLineWidth(2.0)
      ..drawEllipse(x, y, radius, radius)
      ..strokePath();
  }

  static double _roundUpMax(double value) {
    if (value == 0) return 100;
    if (value.isNaN || value.isInfinite) return 100;

    if (value <= 100) {
      return (value / 20).ceil() * 20.0;
    } else if (value <= 200) {
      return (value / 50).ceil() * 50.0;
    } else if (value <= 500) {
      return (value / 100).ceil() * 100.0;
    } else if (value <= 1000) {
      return (value / 200).ceil() * 200.0;
    } else if (value <= 2000) {
      return (value / 500).ceil() * 500.0;
    } else {
      return (value / 1000).ceil() * 1000.0;
    }
  }

  static pw.Widget buildSummaryCards({
    required List<SummaryCardData> cards,
    PdfColor? backgroundColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: backgroundColor ?? PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: cards.map((card) {
          return pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text(
                  card.label,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  card.value,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: card.color,
                  ),
                ),
                if (card.subtitle != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    card.subtitle!,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LineSeriesData {
  final String label;
  final List<double> values;
  final PdfColor color;

  LineSeriesData({
    required this.label,
    required this.values,
    required this.color,
  });
}

class SummaryCardData {
  final String label;
  final String value;
  final String? subtitle;
  final PdfColor color;

  SummaryCardData({
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });
}
