import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';

class ChartPemeliharaanWidget extends StatefulWidget {
  final LaporanData laporanData;

  const ChartPemeliharaanWidget({Key? key, required this.laporanData})
    : super(key: key);

  @override
  State<ChartPemeliharaanWidget> createState() =>
      _ChartPemeliharaanWidgetState();
}

class _ChartPemeliharaanWidgetState extends State<ChartPemeliharaanWidget> {
  late PageController _pageControllerKg;
  late PageController _pageControllerLiter;
  int _currentPageKg = 0;
  int _currentPageLiter = 0;
  double _globalMaxYKg = 100;
  double _globalMaxYLiter = 100;

  final _formatNumber = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();

    final chartData = _prepareChartData();
    _globalMaxYKg = _calculateGlobalMaxY(chartData['kg'] as List<double>);
    _globalMaxYLiter = _calculateGlobalMaxY(chartData['liter'] as List<double>);

    final activeSlide = _detectActiveSlide(chartData);

    _pageControllerKg = PageController(initialPage: activeSlide);
    _pageControllerLiter = PageController(initialPage: activeSlide);
    _currentPageKg = activeSlide;
    _currentPageLiter = activeSlide;
  }

  @override
  void dispose() {
    _pageControllerKg.dispose();
    _pageControllerLiter.dispose();
    super.dispose();
  }

  double _calculateGlobalMaxY(List<double> data) {
    double maxY = 0;

    for (var value in data) {
      if (value > maxY) {
        maxY = value;
      }
    }

    // Add 20% padding to max
    maxY = maxY * 1.2;

    //Round up berdasarkan range
    if (maxY <= 100) {
      // Round ke kelipatan 20 untuk data kecil
      maxY = (maxY / 20).ceil() * 20.0;
    } else if (maxY <= 200) {
      // Round ke kelipatan 50
      maxY = (maxY / 50).ceil() * 50.0;
    } else if (maxY <= 500) {
      // Round ke kelipatan 100
      maxY = (maxY / 100).ceil() * 100.0;
    } else if (maxY <= 1000) {
      // Round ke kelipatan 200
      maxY = (maxY / 200).ceil() * 200.0;
    } else if (maxY <= 2000) {
      // Round ke kelipatan 500
      maxY = (maxY / 500).ceil() * 500.0;
    } else {
      // Round ke kelipatan 1000 untuk data sangat besar
      maxY = (maxY / 1000).ceil() * 1000.0;
    }

    // Minimum default 100
    if (maxY < 100) {
      maxY = 100;
    }

    return maxY;
  }

  int _detectActiveSlide(Map<String, dynamic> chartData) {
    final months = chartData['fullMonths'] as List<String>;

    if (months.isEmpty) return 0;

    final now = DateTime.now();
    final currentMonth = now.month;

    // Jika bulan sekarang Jul-Des (7-12), return slide 1
    if (currentMonth >= 7) {
      return 1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData['months'].isEmpty) {
      return _buildEmptyState();
    }

    final fullYearMonths = _generateFullYearMonths();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Chart Material Padat (Kg)
          _buildSingleChart(
            chartData,
            fullYearMonths,
            'Material Padat (Kg)',
            'kg',
            const Color(0xFFFF5722),
            _pageControllerKg,
            _currentPageKg,
            _globalMaxYKg,
            (page) {
              setState(() {
                _currentPageKg = page;
              });
            },
          ),

          const SizedBox(height: 12),
          _buildPageIndicator(_currentPageKg),

          const SizedBox(height: 24),

          // Chart Material Cair (Liter)
          _buildSingleChart(
            chartData,
            fullYearMonths,
            'Material Cair (Liter)',
            'liter',
            const Color(0xFF2196F3),
            _pageControllerLiter,
            _currentPageLiter,
            _globalMaxYLiter,
            (page) {
              setState(() {
                _currentPageLiter = page;
              });
            },
          ),

          const SizedBox(height: 12),
          _buildPageIndicator(_currentPageLiter),

          const SizedBox(height: 16),

          // Summary info
          _buildSummaryInfo(chartData),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.spa_outlined,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grafik Pemeliharaan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F2D),
                ),
              ),
              Text(
                'Material pemeliharaan per bulan (Kg & Liter)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChart(
    Map<String, dynamic> chartData,
    List<String> fullYearMonths,
    String title,
    String dataKey,
    Color color,
    PageController pageController,
    int currentPage,
    double maxY,
    Function(int) onPageChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            Container(
              width: 16,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Chart with Fixed Y-Axis and Swipeable content
        SizedBox(
          height: 250,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Y-Axis
              _buildFixedYAxis(maxY, dataKey),

              // Swipeable Chart Area
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  children: [
                    _buildSwipeableChart(
                      fullYearMonths.sublist(0, 6),
                      chartData,
                      'Jan - Jun',
                      dataKey,
                      color,
                      maxY,
                    ),
                    _buildSwipeableChart(
                      fullYearMonths.sublist(6, 12),
                      chartData,
                      'Jul - Des',
                      dataKey,
                      color,
                      maxY,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedYAxis(double maxY, String dataKey) {
    final unit = dataKey == 'kg' ? 'kg' : 'L';

    //Interval berdasarkan range data
    final interval = _calculateDynamicInterval(maxY);

    // Calculate jumlah steps berdasarkan interval
    final steps = (maxY / interval).round();

    return Container(
      width: 55,
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(steps + 1, (index) {
          // Generate dari maxY ke 0
          final value = maxY - (index * interval);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${value.toInt()} $unit',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          );
        }),
      ),
    );
  }

  //Method untuk hitung interval dinamis
  double _calculateDynamicInterval(double maxY) {
    // Tentukan interval berdasarkan range maxY
    if (maxY <= 0) return 20.0;

    if (maxY <= 100) {
      // Untuk 0-100: interval 20 (0, 20, 40, 60, 80, 100)
      return 20.0;
    } else if (maxY <= 200) {
      // Untuk 101-200: interval 50 (0, 50, 100, 150, 200)
      return 50.0;
    } else if (maxY <= 500) {
      // Untuk 201-500: interval 100 (0, 100, 200, 300, 400, 500)
      return 100.0;
    } else if (maxY <= 1000) {
      // Untuk 501-1000: interval 200 (0, 200, 400, 600, 800, 1000)
      return 200.0;
    } else if (maxY <= 2000) {
      // Untuk 1001-2000: interval 500
      return 500.0;
    } else {
      // Untuk > 2000: interval 1000
      return 1000.0;
    }
  }

  Widget _buildSwipeableChart(
    List<String> slideMonths,
    Map<String, dynamic> chartData,
    String slideLabel,
    String dataKey,
    Color color,
    double maxY,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16),
      child: Column(
        children: [
          // Slide label dengan tinggi tetap untuk alignment
          SizedBox(
            height: 22, // Fixed height untuk label
            child: Center(
              child: Text(
                slideLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Chart
          Expanded(
            child: LineChart(
              _buildLineChartData(slideMonths, chartData, dataKey, color, maxY),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0, currentPage),
        const SizedBox(width: 8),
        _buildDot(1, currentPage),
      ],
    );
  }

  Widget _buildDot(int index, int currentPage) {
    final isActive = currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  List<String> _generateFullYearMonths() {
    final now = DateTime.now();
    final currentYear = now.year;

    List<String> months = [];
    for (int month = 1; month <= 12; month++) {
      final date = DateTime(currentYear, month);
      months.add(DateFormat('MMM').format(date));
    }

    return months;
  }

  Map<String, dynamic> _prepareChartData() {
    final pemeliharaanData = widget.laporanData.pemeliharaan.data;

    // Simpan detail per tanggal, JANGAN aggregate
    Map<String, List<Map<String, dynamic>>> groupedByMonth = {};

    for (var pemeliharaan in pemeliharaanData) {
      try {
        final date = DateTime.parse(pemeliharaan.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }

        final satuan = pemeliharaan.satuan?.toLowerCase() ?? '';

        // Simpan detail lengkap per tanggal
        groupedByMonth[monthKey]!.add({
          'tanggal': pemeliharaan.tanggal,
          'jumlah': pemeliharaan.jumlah,
          'satuan': satuan == 'liter' ? 'liter' : 'kg',
        });
      } catch (e) {
        print('Error parsing pemeliharaan date: ${pemeliharaan.tanggal}');
      }
    }

    final sortedMonths = groupedByMonth.keys.toList()..sort();

    List<String> months = [];
    List<double> kgData = [];
    List<double> literData = [];
    Map<int, List<Map<String, dynamic>>> detailByIndex =
        {}; // ✅ Detail per index

    int index = 0;
    for (var monthKey in sortedMonths) {
      try {
        final date = DateTime.parse('$monthKey-01');
        months.add(DateFormat('MMM yy').format(date));
      } catch (e) {
        months.add(monthKey);
      }

      // Hitung total per satuan untuk chart
      double kgTotal = 0;
      double literTotal = 0;

      final details = groupedByMonth[monthKey]!;
      for (var detail in details) {
        if (detail['satuan'] == 'kg') {
          kgTotal += detail['jumlah'];
        } else {
          literTotal += detail['jumlah'];
        }
      }

      kgData.add(kgTotal);
      literData.add(literTotal);

      // Simpan detail lengkap per index
      detailByIndex[index] = details;

      index++;
    }

    // Hitung total dan count
    final totalKg = kgData.fold<double>(0, (sum, val) => sum + val);
    final totalLiter = literData.fold<double>(0, (sum, val) => sum + val);
    final avgKg = kgData.isNotEmpty ? totalKg / kgData.length : 0.0;
    final avgLiter = literData.isNotEmpty ? totalLiter / literData.length : 0.0;

    int totalCountKg = 0;
    int totalCountLiter = 0;

    for (var details in detailByIndex.values) {
      for (var detail in details) {
        if (detail['satuan'] == 'kg') {
          totalCountKg++;
        } else {
          totalCountLiter++;
        }
      }
    }

    return {
      'months': months,
      'fullMonths': _generateFullYearMonths(),
      'kg': kgData,
      'liter': literData,
      'detailByIndex': detailByIndex,
      'totalKg': totalKg,
      'totalLiter': totalLiter,
      'avgKg': avgKg,
      'avgLiter': avgLiter,
      'countKg': totalCountKg,
      'countLiter': totalCountLiter,
    };
  }

  LineChartData _buildLineChartData(
    List<String> slideMonths,
    Map<String, dynamic> chartData,
    String dataKey,
    Color color,
    double maxY,
  ) {
    final dataMonths = chartData['months'] as List<String>;
    final detailByIndex =
        chartData['detailByIndex'] as Map<int, List<Map<String, dynamic>>>;

    List<FlSpot> spots = [];
    Map<int, int> spotIndexToDataIndex = {};
    Map<int, List<Map<String, dynamic>>> spotDetails = {};

    final now = DateTime.now();
    final currentMonth = now.month;

    int getActualMonth(int slideIndex, List<String> slideMonths) {
      final fullYearMonths = _generateFullYearMonths();
      final monthName = slideMonths[slideIndex];
      return fullYearMonths.indexOf(monthName) + 1;
    }

    for (int i = 0; i < slideMonths.length; i++) {
      final slideMonth = slideMonths[i];

      final actualMonth = getActualMonth(i, slideMonths);
      if (actualMonth > currentMonth) {
        break;
      }

      bool foundData = false;

      for (int j = 0; j < dataMonths.length; j++) {
        final dataMonth = dataMonths[j];
        final dataMonthName = dataMonth.split(' ')[0];

        if (slideMonth == dataMonthName) {
          foundData = true;
          spotIndexToDataIndex[i] = j;

          final details = detailByIndex[j] ?? [];
          final filteredDetails = details.where((detail) {
            return detail['satuan'] == dataKey;
          }).toList();

          spotDetails[i] = filteredDetails;

          if (filteredDetails.isEmpty) {
            spots.add(FlSpot(i.toDouble(), 0));
          } else if (filteredDetails.length == 1) {
            // Jika hanya 1 data, tambahkan 1 spot
            spots.add(
              FlSpot(i.toDouble(), filteredDetails[0]['jumlah'].toDouble()),
            );
          } else {
            // Ini membuat line vertical naik-turun di bulan yang sama

            // Sort by jumlah untuk urutan yang lebih rapi (opsional)
            filteredDetails.sort(
              (a, b) => (a['jumlah'] as num).compareTo(b['jumlah'] as num),
            );

            for (int k = 0; k < filteredDetails.length; k++) {
              final jumlah = filteredDetails[k]['jumlah'].toDouble();

              // Buat offset horizontal berdasarkan urutan
              double xOffset = 0;
              if (filteredDetails.length == 2) {
                // Untuk 2 data: kiri (-0.1) dan kanan (+0.1)
                xOffset = k == 0 ? -0.1 : 0.1;
              } else if (filteredDetails.length >= 3) {
                // Untuk 3+ data: spread dari kiri ke kanan
                xOffset = (k - (filteredDetails.length - 1) / 2) * 0.1;
              }

              spots.add(FlSpot(i.toDouble() + xOffset, jumlah));
            }
          }
          break;
        }
      }

      if (!foundData) {
        spots.add(FlSpot(i.toDouble(), 0));
        spotDetails[i] = [];
      }
    }

    final interval = _calculateDynamicInterval(maxY);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < slideMonths.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    slideMonths[index],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          left: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      minX: 0,
      maxX: slideMonths.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      extraLinesData: ExtraLinesData(horizontalLines: []),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: color,
              );
            },
          ),
          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,
          tooltipMargin: 8,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            final spotIndex = touchedSpots.first.x.round();
            final details = spotDetails[spotIndex] ?? [];

            final isLeftEdge = spotIndex <= 1;
            final isRightEdge = spotIndex >= slideMonths.length - 2;

            final unit = dataKey == 'kg' ? 'Kg' : 'Liter';

            String tooltipText = '';

            if (details.isEmpty) {
              tooltipText = '${slideMonths[spotIndex]}\nTidak ada data';
            } else {
              for (int i = 0; i < details.length; i++) {
                final detail = details[i];
                final tanggal = _formatDateForDisplay(detail['tanggal']);
                final jumlah = detail['jumlah'].toInt();

                tooltipText += '$tanggal\n$jumlah $unit';

                if (i < details.length - 1) {
                  tooltipText += '\n';
                }
              }

              if (details.length > 1) {
                final total = details.fold<int>(
                  0,
                  (sum, detail) => sum + (detail['jumlah'] as num).toInt(),
                );
                tooltipText += '\n─────────\nTotal: $total $unit';
              }
            }

            return touchedSpots.asMap().entries.map((entry) {
              if (entry.key == 0) {
                return LineTooltipItem(
                  tooltipText.trim(),
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLeftEdge || isRightEdge ? 9 : 10,
                    height: 1.3,
                  ),
                  textAlign: isLeftEdge
                      ? TextAlign.left
                      : (isRightEdge ? TextAlign.right : TextAlign.center),
                );
              } else {
                return LineTooltipItem('', const TextStyle(fontSize: 0));
              }
            }).toList();
          },
        ),
      ),
    );
  }

  String _formatDateForDisplay(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        return dateStr.replaceAll('/', '-');
      }

      if (dateStr.contains('-') && dateStr.split('-')[0].length == 4) {
        final date = DateTime.parse(dateStr);
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      }

      return dateStr;
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr;
    }
  }

  Widget _buildSummaryInfo(Map<String, dynamic> chartData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Kg',
              '${_formatNumber.format(chartData['totalKg'])} Kg',
              '${chartData['countKg']}x pemeliharaan',
              const Color(0xFFFF5722),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              'Total Liter',
              '${_formatNumber.format(chartData['totalLiter'])} Liter',
              '${chartData['countLiter']}x pemeliharaan',
              const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    String subtext,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(subtext, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.spa_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Pemeliharaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data pemeliharaan akan ditampilkan di sini',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
