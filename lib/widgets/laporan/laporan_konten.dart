import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/widgets/laporan/chart_panen.dart';
import 'package:project_taniapp_ta/widgets/laporan/chart_pemeliharaan.dart';
import 'package:project_taniapp_ta/widgets/laporan/laporan_datalist.dart';
import 'package:project_taniapp_ta/widgets/laporan/laporan_summary.dart';
import 'package:provider/provider.dart';
import '../../viewsModels/laporan_view_models.dart';
import '../../models/app_constants.dart';
import '../../models/laporan_models.dart';

class LaporanContentWidget extends StatefulWidget {
  final LaporanViewModel viewModel;

  const LaporanContentWidget({
    super.key,
    required this.viewModel,
  });

  @override
  State<LaporanContentWidget> createState() => _LaporanContentWidgetState();
}

class _LaporanContentWidgetState extends State<LaporanContentWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanViewModel>(
      builder: (context, vm, child) {
        // Error State
        if (vm.hasError) {
          return _buildErrorState(vm);
        }

        // Loading State
        if (vm.isLoading) {
          return _buildLoadingState();
        }

        // Data State (filtered laporan)
        if (vm.hasData) {
          return _buildDataStateWithTabs(vm.currentLaporan!, vm);
        }

        // Empty State with Summary (show summary keseluruhan)
        if (vm.hasSummary) {
          return _buildEmptyStateWithSummary(vm);
        }

        // Complete empty state
        return _buildCompleteEmptyState();
      },
    );
  }

  Widget _buildDataStateWithTabs(LaporanData laporan, LaporanViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary Card with Statistics
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LaporanSummaryCard(
            summaryData: vm.displaySummary,
            currentPage: vm.summaryCurrentPage,
            totalPages: vm.summaryTotalPages,
            onPageChanged: (page) => vm.setSummaryPage(page),
          ),
        ),

        const SizedBox(height: 24),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            indicator: BoxDecoration(
              color: const Color(AppColors.primaryGreen),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Data Catatan'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Data Visual'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTabContent(laporan, vm),
        ),

        const SizedBox(height: 80), 
      ],
    );
  }

  // Method untuk menampilkan konten tab berdasarkan tab yang aktif
  Widget _buildTabContent(LaporanData laporan, LaporanViewModel vm) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        if (_tabController.index == 0) {
          return _buildDataCatatanContent(laporan);
        } else {
          return _buildDataVisualContent(laporan); 
        }
      },
    );
  }

  // Konten Data Catatan - Tanpa scroll terpisah
  Widget _buildDataCatatanContent(LaporanData laporan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ...existing header code...

        const SizedBox(height: 20),

        // Data Pemeliharaan 
        LaporanDataList(
          title: 'Data Pemeliharaan',
          icon: Icons.build_circle,
          count: laporan.pemeliharaan.totalRecords,
          pemeliharaanData: laporan.pemeliharaan.data,
          panenData: const [],
          isPemeliharaan: true,
          kebunNama: laporan.kebun.nama, 
        ),

        const SizedBox(height: 24),

        // Data Panen 
        LaporanDataList(
          title: 'Data Panen',
          icon: Icons.eco,
          count: laporan.panen.totalRecords,
          pemeliharaanData: const [],
          panenData: laporan.panen.data,
          isPemeliharaan: false,
          kebunNama: laporan.kebun.nama, 
        ),
      ],
    );
  }

  //Konten Data Visual - DENGAN CHART!
  Widget _buildDataVisualContent(LaporanData laporan) {
    // Check if there's data to visualize
    final hasPemeliharaanData = laporan.pemeliharaan.totalRecords > 0;
    final hasPanenData = laporan.panen.totalRecords > 0;

    if (!hasPemeliharaanData && !hasPanenData) {
      return _buildNoDataForVisualization();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visualisasi Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Grafik panen dan pemeliharaan dari ${laporan.kebun.nama}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        //  CHART PANEN
        if (hasPanenData) ...[
          ChartPanenWidget(laporanData: laporan),
          const SizedBox(height: 24),
        ],

        //  CHART PEMELIHARAAN
        if (hasPemeliharaanData) ...[
          ChartPemeliharaanWidget(laporanData: laporan),
          const SizedBox(height: 24),
        ] else ...[
          _buildNoDataCard(
            icon: Icons.spa_outlined,
            title: 'Tidak Ada Data Pemeliharaan',
            message:
                'Belum ada data pemeliharaan untuk ${laporan.kebun.nama} pada periode yang dipilih',
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
        ],

        // Info footer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data ditampilkan berdasarkan periode yang dipilih',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card untuk menampilkan pesan tidak ada data visualisasi (pemeliharaan)
  Widget _buildNoDataCard({
    required IconData icon,
    required String title,
    required String message,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color.shade600),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: color.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // untuk tab visual jika semua data kosong panen dan pemeliharaan
  Widget _buildNoDataForVisualization() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.orange.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
                size: 64,
                color: Colors.orange.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Data untuk Divisualisasikan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan data pemeliharaan atau panen untuk melihat grafik visualisasi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(LaporanViewModel vm) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.errorMessage,
              style: TextStyle(color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.initialize(shouldReset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(AppColors.primaryGreen)),
            SizedBox(height: 16),
            Text(
              'Memuat data laporan...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithSummary(LaporanViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary Card with Statistics
        Padding(
          padding: const EdgeInsets.all(16),
          child: LaporanSummaryCard(
            summaryData: vm.displaySummary,
            currentPage: vm.summaryCurrentPage,
            totalPages: vm.summaryTotalPages,
            onPageChanged: (page) => vm.setSummaryPage(page),
          ),
        ),

        const SizedBox(height: 24),

        // Call-to-action message
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.green.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                'Analisis Detail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih kebun dan periode untuk melihat laporan detail dengan data pemeliharaan dan panen',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list,
                        size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Gunakan filter di atas',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80), 
      ],
    );
  }

  Widget _buildCompleteEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined,
                size: 120, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data Laporan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai dengan menambahkan kebun, melakukan pemeliharaan, dan mencatat panen untuk melihat laporan keuangan',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/kebun');
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Tambah Kebun'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
