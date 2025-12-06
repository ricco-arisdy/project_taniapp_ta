class LaporanData {
  final KebunLaporan kebun;
  final PeriodeLaporan periode;
  final PemeliharaanLaporan pemeliharaan;
  final PanenLaporan panen;
  final SummaryLaporan summary;
  final MetadataLaporan metadata;

  LaporanData({
    required this.kebun,
    required this.periode,
    required this.pemeliharaan,
    required this.panen,
    required this.summary,
    required this.metadata,
  });

  factory LaporanData.fromJson(Map<String, dynamic> json) {
    return LaporanData(
      kebun: KebunLaporan.fromJson(json['kebun']),
      periode: PeriodeLaporan.fromJson(json['periode']),
      pemeliharaan: PemeliharaanLaporan.fromJson(json['pemeliharaan']),
      panen: PanenLaporan.fromJson(json['panen']),
      summary: SummaryLaporan.fromJson(json['summary']),
      metadata: MetadataLaporan.fromJson(json['metadata']),
    );
  }
}

class KebunLaporan {
  final int id;
  final String nama;
  final String lokasi;
  final String luas;
  final int titikTanam;
  final String waktuBeli;
  final String statusKepemilikan;
  final String statusKebun;
  final String namaUser;

  KebunLaporan({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.titikTanam,
    required this.waktuBeli,
    required this.statusKepemilikan,
    required this.statusKebun,
    required this.namaUser,
  });

  factory KebunLaporan.fromJson(Map<String, dynamic> json) {
    return KebunLaporan(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      lokasi: json['lokasi'] ?? '',
      luas: json['luas'] ?? '',
      titikTanam: json['titik_tanam'] ?? 0,
      waktuBeli: json['waktu_beli'] ?? '',
      statusKepemilikan: json['status_kepemilikan'] ?? '',
      statusKebun: json['status_kebun'] ?? '',
      namaUser: json['nama_user'] ?? '',
    );
  }
}

class PeriodeLaporan {
  final String? tanggalDari;
  final String? tanggalSampai;
  final String dicetakPada;

  PeriodeLaporan({
    this.tanggalDari,
    this.tanggalSampai,
    required this.dicetakPada,
  });

  factory PeriodeLaporan.fromJson(Map<String, dynamic> json) {
    return PeriodeLaporan(
      tanggalDari: json['tanggal_dari'],
      tanggalSampai: json['tanggal_sampai'],
      dicetakPada: json['dicetak_pada'] ?? '',
    );
  }
}

class PemeliharaanLaporan {
  final List<PemeliharaanLaporanItem> data;
  final int totalRecords;
  final int totalBiaya;
  final double rataRataBiaya;

  PemeliharaanLaporan({
    required this.data,
    required this.totalRecords,
    required this.totalBiaya,
    required this.rataRataBiaya,
  });

  factory PemeliharaanLaporan.fromJson(Map<String, dynamic> json) {
    return PemeliharaanLaporan(
      data: (json['data'] as List?)
              ?.map((item) => PemeliharaanLaporanItem.fromJson(item))
              .toList() ??
          [],
      totalRecords: json['total_records'] ?? 0,
      totalBiaya: json['total_biaya'] ?? 0,
      rataRataBiaya: (json['rata_rata_biaya'] ?? 0.0).toDouble(),
    );
  }
}

class PemeliharaanLaporanItem {
  final int id;
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan; // ✅ TAMBAHKAN INI
  final int biaya;
  final String? catatan;

  PemeliharaanLaporanItem({
    required this.id,
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan, // ✅ TAMBAHKAN INI
    required this.biaya,
    this.catatan,
  });

  factory PemeliharaanLaporanItem.fromJson(Map<String, dynamic> json) {
    return PemeliharaanLaporanItem(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      kegiatan: json['kegiatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'], // ✅ TAMBAHKAN INI
      biaya: json['biaya'] ?? 0,
      catatan: json['catatan'],
    );
  }
}

class PanenLaporan {
  final List<PanenLaporanItem> data;
  final int totalRecords;
  final int totalJumlahKg;
  final int totalPendapatan;
  final double rataRataJumlah;
  final double hargaRataPerKg;

  PanenLaporan({
    required this.data,
    required this.totalRecords,
    required this.totalJumlahKg,
    required this.totalPendapatan,
    required this.rataRataJumlah,
    required this.hargaRataPerKg,
  });

  factory PanenLaporan.fromJson(Map<String, dynamic> json) {
    return PanenLaporan(
      data: (json['data'] as List?)
              ?.map((item) => PanenLaporanItem.fromJson(item))
              .toList() ??
          [],
      totalRecords: json['total_records'] ?? 0,
      totalJumlahKg: json['total_jumlah_kg'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      rataRataJumlah: (json['rata_rata_jumlah'] ?? 0.0).toDouble(),
      hargaRataPerKg: (json['harga_rata_per_kg'] ?? 0.0).toDouble(),
    );
  }
}

class PanenLaporanItem {
  final int id;
  final int kebunId;
  final String tanggal;
  final int jumlah;
  final int harga;
  final String? catatan;
  final int total;

  PanenLaporanItem({
    required this.id,
    required this.kebunId,
    required this.tanggal,
    required this.jumlah,
    required this.harga,
    this.catatan,
    required this.total,
  });

  factory PanenLaporanItem.fromJson(Map<String, dynamic> json) {
    return PanenLaporanItem(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: json['harga'] ?? 0,
      catatan: json['catatan'],
      total: json['total'] ?? 0,
    );
  }
}

class SummaryLaporan {
  final int totalBiayaPemeliharaan;
  final int totalPendapatan;
  final int totalKeuntungan;
  final double persentaseKeuntungan;
  final String statusKeuntungan;

  SummaryLaporan({
    required this.totalBiayaPemeliharaan,
    required this.totalPendapatan,
    required this.totalKeuntungan,
    required this.persentaseKeuntungan,
    required this.statusKeuntungan,
  });

  factory SummaryLaporan.fromJson(Map<String, dynamic> json) {
    return SummaryLaporan(
      totalBiayaPemeliharaan: json['total_biaya_pemeliharaan'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      totalKeuntungan: json['total_keuntungan'] ?? 0,
      persentaseKeuntungan: (json['persentase_keuntungan'] ?? 0.0).toDouble(),
      statusKeuntungan: json['status_keuntungan'] ?? 'rugi',
    );
  }

  bool get isUntung => statusKeuntungan == 'untung';
}

class SummaryKeseluruhan {
  final int totalKebun;
  final String totalLuasKebun;
  final int totalBiayaPemeliharaan;
  final int totalPendapatan;
  final int totalKeuntungan;
  final double persentaseKeuntungan;
  final String statusKeuntungan;
  final int totalPemeliharaanRecords;
  final int totalPanenRecords;
  final int totalKg;
  final double hargaPerKg;

  SummaryKeseluruhan({
    required this.totalKebun,
    required this.totalLuasKebun,
    required this.totalBiayaPemeliharaan,
    required this.totalPendapatan,
    required this.totalKeuntungan,
    required this.persentaseKeuntungan,
    required this.statusKeuntungan,
    required this.totalPemeliharaanRecords,
    required this.totalPanenRecords,
    required this.totalKg,
    required this.hargaPerKg,
  });

  factory SummaryKeseluruhan.fromJson(Map<String, dynamic> json) {
    // ✅ Helper function untuk parsing total_luas
    String parseTotalLuas(dynamic value) {
      if (value == null) {
        return '0 Ha';
      }

      String luasStr = value.toString().trim();

      // Jika sudah mengandung "Ha", return as is
      if (luasStr.toLowerCase().contains('ha')) {
        return luasStr;
      }

      // Jika kosong, return default
      if (luasStr.isEmpty || luasStr == '0') {
        return '0 Ha';
      }

      // Tambahkan " Ha" di akhir
      return '$luasStr Ha';
    }

    return SummaryKeseluruhan(
      totalKebun: json['total_kebun'] ?? 0,
      totalLuasKebun: parseTotalLuas(json['total_luas']),
      totalBiayaPemeliharaan: json['total_biaya_pemeliharaan'] ?? 0,
      totalPendapatan: json['total_pendapatan'] ?? 0,
      totalKeuntungan: json['total_keuntungan'] ?? 0,
      persentaseKeuntungan: (json['persentase_keuntungan'] ?? 0.0).toDouble(),
      statusKeuntungan: json['status_keuntungan'] ?? 'rugi',
      totalPemeliharaanRecords: json['total_pemeliharaan_records'] ?? 0,
      totalPanenRecords: json['total_panen_records'] ?? 0,
      totalKg: json['total_kg'] ?? 0, // ✅ TAMBAH parsing
      hargaPerKg: (json['harga_per_kg'] ?? 0.0).toDouble(), // ✅ TAMBAH parsing
    );
  }

  bool get isUntung => statusKeuntungan == 'untung';
}

class MetadataLaporan {
  final int userId;
  final String userName;
  final String generatedAt;
  final String apiVersion;

  MetadataLaporan({
    required this.userId,
    required this.userName,
    required this.generatedAt,
    required this.apiVersion,
  });

  factory MetadataLaporan.fromJson(Map<String, dynamic> json) {
    return MetadataLaporan(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      generatedAt: json['generated_at'] ?? '',
      apiVersion: json['api_version'] ?? '',
    );
  }
}
