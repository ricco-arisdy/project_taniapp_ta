class Pemeliharaan {
  final int id;
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan;
  final int biaya;
  final String? catatan;
  final String? namaKebun;
  final String? lokasiKebun;
  final String? namaUser;

  Pemeliharaan({
    required this.id,
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan,
    required this.biaya,
    this.catatan,
    this.namaKebun,
    this.lokasiKebun,
    this.namaUser,
  });

  factory Pemeliharaan.fromJson(Map<String, dynamic> json) {
    // Normalisasi satuan dari database
    String? normalizedSatuan;
    if (json['satuan'] != null && json['satuan'].toString().isNotEmpty) {
      final rawSatuan = json['satuan'].toString().trim();

      // Cari satuan yang cocok dengan opsi yang tersedia (case insensitive)
      final validSatuans = ['Kg', 'Liter'];
      normalizedSatuan = validSatuans.firstWhere(
        (option) => option.toLowerCase() == rawSatuan.toLowerCase(),
        orElse: () => '',
      );

      // Jika tidak ditemukan yang cocok, set ke null
      if (normalizedSatuan.isEmpty) {
        normalizedSatuan = null;
      }
    }

    return Pemeliharaan(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      kegiatan: json['kegiatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: normalizedSatuan,
      biaya: json['biaya'] ?? 0,
      catatan: json['catatan'],
      namaKebun: json['nama_kebun'],
      lokasiKebun: json['lokasi_kebun'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'kegiatan': kegiatan,
      'tanggal': tanggal,
      'jumlah': jumlah,
      if (satuan != null) 'satuan': satuan,
      'biaya': biaya,
      if (catatan != null) 'catatan': catatan,
      if (namaKebun != null) 'nama_kebun': namaKebun,
      if (lokasiKebun != null) 'lokasi_kebun': lokasiKebun,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }

  // Helper method untuk format tanggal input (DD-MM-YYYY)
  String get formattedDateInput {
    try {
      DateTime parsedDate = DateTime.parse(tanggal);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return tanggal;
    }
  }

  // Helper method untuk format tanggal yang lebih readable
  String get formattedDate {
    try {
      DateTime parsedDate = DateTime.parse(tanggal);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return tanggal;
    }
  }

  DateTime get parsedDate {
    try {
      return DateTime.parse(tanggal);
    } catch (e) {
      // Jika format tanggal tidak standar, coba parsing manual
      if (tanggal.contains('-') && tanggal.split('-').length == 3) {
        final parts = tanggal.split('-');

        // Cek apakah format DD-MM-YYYY
        if (parts[0].length == 2 &&
            parts[1].length == 2 &&
            parts[2].length == 4) {
          try {
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } catch (e) {
            // Fallback ke tanggal hari ini
            return DateTime.now();
          }
        }
      }

      // Fallback default
      return DateTime.now();
    }
  }

  int compareByDateAndId(Pemeliharaan other) {
    // Primary sort: Date (newest first)
    final dateComparison = other.parsedDate.compareTo(parsedDate);

    // Secondary sort: ID (newest first) jika tanggal sama
    if (dateComparison == 0) {
      return other.id.compareTo(id);
    }

    return dateComparison;
  }

  // Helper method untuk format biaya dengan pemisah ribuan
  String get formattedBiaya {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return biaya
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Method untuk membuat object baru dengan perubahan tertentu
  Pemeliharaan copyWith({
    int? id,
    int? kebunId,
    String? kegiatan,
    String? tanggal,
    int? jumlah,
    String? satuan,
    int? biaya,
    String? catatan,
    String? namaKebun,
    String? lokasiKebun,
    String? namaUser,
  }) {
    return Pemeliharaan(
      id: id ?? this.id,
      kebunId: kebunId ?? this.kebunId,
      kegiatan: kegiatan ?? this.kegiatan,
      tanggal: tanggal ?? this.tanggal,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      biaya: biaya ?? this.biaya,
      catatan: catatan ?? this.catatan,
      namaKebun: namaKebun ?? this.namaKebun,
      lokasiKebun: lokasiKebun ?? this.lokasiKebun,
      namaUser: namaUser ?? this.namaUser,
    );
  }

  @override
  String toString() {
    return 'Pemeliharaan{id: $id, kebunId: $kebunId, kegiatan: $kegiatan, tanggal: $tanggal, jumlah: $jumlah, satuan: $satuan, biaya: $biaya, catatan: $catatan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pemeliharaan &&
        other.id == id &&
        other.kebunId == kebunId &&
        other.kegiatan == kegiatan &&
        other.tanggal == tanggal &&
        other.jumlah == jumlah &&
        other.satuan == satuan &&
        other.biaya == biaya &&
        other.catatan == catatan;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, kebunId, kegiatan, tanggal, jumlah, satuan, biaya, catatan);
  }
}

// Model untuk request create/update Pemeliharaan
class PemeliharaanRequest {
  final int kebunId;
  final String kegiatan;
  final String tanggal;
  final int jumlah;
  final String? satuan;
  final int biaya;
  final String? catatan;

  PemeliharaanRequest({
    required this.kebunId,
    required this.kegiatan,
    required this.tanggal,
    required this.jumlah,
    this.satuan,
    required this.biaya,
    this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'kebun_id': kebunId,
      'kegiatan': kegiatan,
      'tanggal': tanggal,
      'jumlah': jumlah,
      if (satuan != null) 'satuan': satuan,
      'biaya': biaya,
      'catatan': catatan,
    };
  }

  factory PemeliharaanRequest.fromPemeliharaan(Pemeliharaan pemeliharaan) {
    return PemeliharaanRequest(
      kebunId: pemeliharaan.kebunId,
      kegiatan: pemeliharaan.kegiatan,
      tanggal: pemeliharaan.tanggal,
      jumlah: pemeliharaan.jumlah,
      satuan: pemeliharaan.satuan,
      biaya: pemeliharaan.biaya,
      catatan: pemeliharaan.catatan,
    );
  }
}

// ✅ UPDATE: Model untuk metadata dari backend
class PemeliharaanMetadata {
  final int totalRecords;
  final int totalBiaya;
  final double rataRataBiaya; // ✅ UBAH: int → double
  final String? kegiatanTerbanyak;
  final int? kebunId;
  final String? namaKebun;
  final String? lokasiKebun;
  final String? kegiatanFilter;
  final int userId;
  final String userName;

  PemeliharaanMetadata({
    required this.totalRecords,
    required this.totalBiaya,
    required this.rataRataBiaya,
    this.kegiatanTerbanyak,
    this.kebunId,
    this.namaKebun,
    this.lokasiKebun,
    this.kegiatanFilter,
    required this.userId,
    required this.userName,
  });

  factory PemeliharaanMetadata.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] ?? {};

    print('🔧 [METADATA] Parsing metadata from JSON: $json');
    print('🔧 [METADATA] Statistics object: $statistics');

    final totalBiaya = statistics['total_biaya'] ?? 0;
    final rataRataBiaya = statistics['rata_rata_biaya'] ?? 0.0; // ✅ TAMBAH

    print('🔧 [METADATA] Total biaya: $totalBiaya (${totalBiaya.runtimeType})');
    print(
        '🔧 [METADATA] Rata-rata biaya: $rataRataBiaya (${rataRataBiaya.runtimeType})'); // ✅ TAMBAH

    return PemeliharaanMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalBiaya: totalBiaya is int ? totalBiaya : (totalBiaya as num).toInt(),
      rataRataBiaya: rataRataBiaya is double
          ? rataRataBiaya
          : (rataRataBiaya as num).toDouble(), // ✅ FIX: Handle double/int
      kegiatanTerbanyak: statistics['kegiatan_terbanyak'],
      kebunId: json['kebun_id'],
      namaKebun: json['nama_kebun'],
      lokasiKebun: json['lokasi_kebun'],
      kegiatanFilter: json['kegiatan_filter'],
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PemeliharaanMetadata{totalRecords: $totalRecords, totalBiaya: $totalBiaya, rataRataBiaya: $rataRataBiaya, kegiatanTerbanyak: $kegiatanTerbanyak, kebunId: $kebunId, kegiatanFilter: $kegiatanFilter}';
  }
}

// ...existing class Pemeliharaan tetap sama...

// Model untuk response list pemeliharaan dengan metadata
class PemeliharaanListResponse {
  final List<Pemeliharaan> data;
  final PemeliharaanMetadata metadata;

  PemeliharaanListResponse({
    required this.data,
    required this.metadata,
  });

  factory PemeliharaanListResponse.fromJson(Map<String, dynamic> json) {
    return PemeliharaanListResponse(
      data: (json['data']['pemeliharaan'] as List?)
              ?.map((item) => Pemeliharaan.fromJson(item))
              .toList() ??
          [],
      metadata: PemeliharaanMetadata.fromJson(json['data']['metadata'] ?? {}),
    );
  }
}
