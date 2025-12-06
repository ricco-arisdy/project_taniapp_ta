import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_models.dart';

class ChartPanenWidget extends StatefulWidget {
  final LaporanData laporanData;

  const ChartPanenWidget({Key? key, required this.laporanData})
    : super(key: key);

  @override
  State<ChartPanenWidget> createState() => _ChartPanenWidgetState();
}

class _ChartPanenWidgetState extends State<ChartPanenWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  double _globalMaxY = 100;

  int? _touchedSpotIndex;
  List<LineBarSpot>? _touchedSpots;

  final _formatNumber = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();

    final chartData = _prepareChartData();
    _globalMaxY = _calculateGlobalMaxY(chartData);
    final activeSlide = _detectActiveSlide(chartData);

    _pageController = PageController(initialPage: activeSlide);
    _currentPage = activeSlide;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _calculateGlobalMaxY(Map<String, dynamic> chartData) {
    final panen1Data = chartData['panen1'] as List<double?>;
    final panen2Data = chartData['panen2'] as List<double?>;

    double maxY = 0;

    for (var value in [...panen1Data, ...panen2Data]) {
      if (value != null && value > maxY) {
        maxY = value;
      }
    }

    // Add 20% padding to max
    maxY = maxY * 1.2;

    // ROUND UP ke kelipatan 1000
    if (maxY > 0) {
      maxY = (maxY / 1000).ceil() * 1000.0;
    }

    // Default minimum 1000 jika data terlalu kecil
    if (maxY < 1000) maxY = 1000;

    return maxY;
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
          _buildHeader(),
          const SizedBox(height: 24),
          _buildLegend(),
          const SizedBox(height: 24),

          // Better layout dengan proper spacing
          SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFixedYAxis(),

                // Swipeable Chart Area
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildSwipeableChart(
                        fullYearMonths.sublist(0, 6),
                        chartData,
                        'Jan - Jun',
                      ),
                      _buildSwipeableChart(
                        fullYearMonths.sublist(6, 12),
                        chartData,
                        'Jul - Des',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _buildPageIndicator(),
          const SizedBox(height: 16),
          _buildSummaryInfo(chartData),
        ],
      ),
    );
  }

  Widget _buildFixedYAxis() {
    // Calculate jumlah steps (interval 1000)
    final int steps = (_globalMaxY / 1000).toInt();

    return Container(
      width: 55,
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(steps + 1, (index) {
          // Generate dari maxY ke 0 dengan interval 1000
          final value = _globalMaxY - (index * 1000);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${value.toInt()} kg',
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

  // Swipeable chart dengan better spacing
  Widget _buildSwipeableChart(
    List<String> slideMonths,
    Map<String, dynamic> chartData,
    String slideLabel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16),
      child: Column(
        children: [
          // Slide label
          Text(
            slideLabel,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Chart
          Expanded(
            child: LineChart(
              _buildLineChartData(slideMonths, chartData, _globalMaxY),
            ),
          ),
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
            Icons.agriculture_outlined,
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
                'Grafik Panen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5F2D),
                ),
              ),
              Text(
                'Perbandingan hasil panen per bulan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Panen Pertama', const Color(0xFF2196F3)),
        const SizedBox(width: 24),
        _buildLegendItem('Panen Kedua', const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
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
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildDot(0), const SizedBox(width: 8), _buildDot(1)],
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
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

  int _detectActiveSlide(Map<String, dynamic> chartData) {
    final months = chartData['months'] as List<String>;

    if (months.isEmpty) return 0;

    for (var month in months) {
      try {
        final now = DateTime.now();
        for (int m = 7; m <= 12; m++) {
          final date = DateTime(now.year, m);
          final monthStr = DateFormat('MMM yy').format(date);
          if (month == monthStr) {
            return 1;
          }
        }
      } catch (e) {
        // Continue
      }
    }

    return 0;
  }

  Map<String, dynamic> _prepareChartData() {
    final panenData = widget.laporanData.panen.data;
    Map<String, List<PanenLaporanItem>> groupedByMonth = {};

    for (var panen in panenData) {
      try {
        final date = DateTime.parse(panen.tanggal);
        final monthKey = DateFormat('yyyy-MM').format(date);

        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }
        groupedByMonth[monthKey]!.add(panen);
      } catch (e) {
        print('Error parsing date: ${panen.tanggal}');
      }
    }

    final sortedMonths = groupedByMonth.keys.toList()..sort();

    List<String> months = [];
    List<double?> panen1Data = [];
    List<double?> panen2Data = [];

    for (var monthKey in sortedMonths) {
      final panenList = groupedByMonth[monthKey]!;

      panenList.sort((a, b) {
        try {
          return DateTime.parse(a.tanggal).compareTo(DateTime.parse(b.tanggal));
        } catch (e) {
          return 0;
        }
      });

      try {
        final date = DateTime.parse('$monthKey-01');
        months.add(DateFormat('MMM yy').format(date));
      } catch (e) {
        months.add(monthKey);
      }

      panen1Data.add(
        panenList.isNotEmpty ? panenList[0].jumlah.toDouble() : null,
      );
      panen2Data.add(
        panenList.length > 1 ? panenList[1].jumlah.toDouble() : null,
      );
    }

    int totalPanen1 = 0;
    int totalPanen2 = 0;
    int countPanen1 = 0;
    int countPanen2 = 0;

    for (int i = 0; i < panen1Data.length; i++) {
      if (panen1Data[i] != null) {
        totalPanen1 += panen1Data[i]!.toInt();
        countPanen1++;
      }
      if (panen2Data[i] != null) {
        totalPanen2 += panen2Data[i]!.toInt();
        countPanen2++;
      }
    }

    print('🔍 [FLUTTER] panen1Data: $panen1Data');
    print('🔍 [FLUTTER] panen2Data: $panen2Data');

    return {
      'months': months,
      'panen1': panen1Data,
      'panen2': panen2Data,
      'totalPanen1': totalPanen1,
      'totalPanen2': totalPanen2,
      'avgPanen1': countPanen1 > 0 ? (totalPanen1 / countPanen1) : 0.0,
      'avgPanen2': countPanen2 > 0 ? (totalPanen2 / countPanen2) : 0.0,
      'countPanen1': countPanen1,
      'countPanen2': countPanen2,
    };
  }

  LineChartData _buildLineChartData(
    List<String> slideMonths,
    Map<String, dynamic> chartData,
    double maxY,
  ) {
    final dataMonths = chartData['months'] as List<String>;
    final panen1Data = chartData['panen1'] as List<double?>;
    final panen2Data = chartData['panen2'] as List<double?>;

    List<FlSpot> panen1Spots = [];
    List<FlSpot> panen2Spots = [];

    for (int i = 0; i < slideMonths.length; i++) {
      final slideMonth = slideMonths[i];

      for (int j = 0; j < dataMonths.length; j++) {
        final dataMonth = dataMonths[j];
        final dataMonthName = dataMonth.split(' ')[0];

        if (slideMonth == dataMonthName) {
          if (panen1Data[j] != null) {
            panen1Spots.add(FlSpot(i.toDouble(), panen1Data[j]!));
          }
          if (panen2Data[j] != null) {
            panen2Spots.add(FlSpot(i.toDouble(), panen2Data[j]!));
          }
          break;
        }
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1000,
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
      lineBarsData: [
        LineChartBarData(
          spots: panen1Spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: const Color(0xFF2196F3),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF2196F3),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF2196F3).withOpacity(0.1),
          ),
        ),
        LineChartBarData(
          spots: panen2Spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: const Color(0xFF4CAF50),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF4CAF50),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF4CAF50).withOpacity(0.1),
          ),
        ),
      ],

      // Smart tooltip dengan auto-positioning
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (response != null && response.lineBarSpots != null) {
            setState(() {
              _touchedSpots = response.lineBarSpots;
              _touchedSpotIndex = response.lineBarSpots!.first.spotIndex;
            });
          } else {
            setState(() {
              _touchedSpots = null;
              _touchedSpotIndex = null;
            });
          }
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,

          // Adjust berdasarkan posisi X
          tooltipMargin: 8,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          tooltipRoundedRadius: 8,

          // Rotate tooltip jika dekat edge
          rotateAngle: 0,

          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            final monthIndex = touchedSpots.first.x.toInt();
            final month = monthIndex < slideMonths.length
                ? slideMonths[monthIndex]
                : '';

            // Deteksi posisi: kiri, tengah, atau kanan
            final isLeftEdge = monthIndex <= 1;
            final isRightEdge = monthIndex >= slideMonths.length - 2;

            // Build combined text dengan formatting
            String tooltipText = '$month\n';

            for (var spot in touchedSpots) {
              final label = spot.barIndex == 0 ? 'P1' : 'P2';
              final value = spot.y.toInt();
              tooltipText += '$label: $value kg\n';
            }

            // Return HANYA 1 tooltip untuk spot pertama
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
                  // Align text berdasarkan posisi
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
              'Total Panen 1',
              '${_formatNumber.format(chartData['totalPanen1'])} kg',
              '${chartData['countPanen1']}x panen',
              const Color(0xFF2196F3),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              'Total Panen 2',
              '${_formatNumber.format(chartData['totalPanen2'])} kg',
              '${chartData['countPanen2']}x panen',
              const Color(0xFF4CAF50),
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
          Icon(
            Icons.agriculture_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Panen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data panen akan ditampilkan di sini',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
