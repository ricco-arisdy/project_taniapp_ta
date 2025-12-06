class Panen {
  final int id;
  final int kebunId;
  final String tanggal;
  final int jumlah;
  final int harga;
  final String? catatan;
  final String? namaKebun;
  final String? lokasiKebun;
  final String? namaUser;

  Panen({
    required this.id,
    required this.kebunId,
    required this.tanggal,
    required this.jumlah,
    required this.harga,
    this.catatan,
    this.namaKebun,
    this.lokasiKebun,
    this.namaUser,
  });

  factory Panen.fromJson(Map<String, dynamic> json) {
    return Panen(
      id: json['id'] ?? 0,
      kebunId: json['kebun_id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      harga: json['harga'] ?? 0,
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
      'tanggal': tanggal,
      'jumlah': jumlah,
      'harga': harga,
      if (catatan != null) 'catatan': catatan,
      if (namaKebun != null) 'nama_kebun': namaKebun,
      if (lokasiKebun != null) 'lokasi_kebun': lokasiKebun,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }

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
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } catch (e) {
            return DateTime.now();
          }
        }
      }
      return DateTime.now();
    }
  }

  int compareByDateAndId(Panen other) {
    // Primary sort: Date (newest first)
    final dateComparison = other.parsedDate.compareTo(parsedDate);

    // Secondary sort: ID (newest first) jika tanggal sama
    if (dateComparison == 0) {
      return other.id.compareTo(id);
    }

    return dateComparison;
  }

  // Helper method untuk format harga dengan pemisah ribuan
  String get formattedHarga {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return harga
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Helper method untuk menghitung total nilai panen
  int get totalNilai => jumlah * harga;

  // Helper method untuk format total nilai dengan pemisah ribuan
  String get formattedTotalNilai {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return totalNilai
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  // Method untuk create copy dengan perubahan tertentu
  Panen copyWith({
    int? id,
    int? kebunId,
    String? tanggal,
    int? jumlah,
    int? harga,
    String? catatan,
    String? namaKebun,
    String? lokasiKebun,
    String? namaUser,
  }) {
    return Panen(
      id: id ?? this.id,
      kebunId: kebunId ?? this.kebunId,
      tanggal: tanggal ?? this.tanggal,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      catatan: catatan ?? this.catatan,
      namaKebun: namaKebun ?? this.namaKebun,
      lokasiKebun: lokasiKebun ?? this.lokasiKebun,
      namaUser: namaUser ?? this.namaUser,
    );
  }

  @override
  String toString() {
    return 'Panen{id: $id, kebunId: $kebunId, tanggal: $tanggal, jumlah: $jumlah, harga: $harga, catatan: $catatan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Panen &&
        other.id == id &&
        other.kebunId == kebunId &&
        other.tanggal == tanggal &&
        other.jumlah == jumlah &&
        other.harga == harga &&
        other.catatan == catatan;
  }

  @override
  int get hashCode {
    return Object.hash(id, kebunId, tanggal, jumlah, harga, catatan);
  }
}

// Model untuk metadata response dari API
class PanenMetadata {
  final int totalRecords;
  final int totalKg;
  final int totalNilai;
  final int rataRataHarga;
  final int userId;
  final String userName;

  PanenMetadata({
    required this.totalRecords,
    required this.totalKg,
    required this.totalNilai,
    required this.rataRataHarga,
    required this.userId,
    required this.userName,
  });

  factory PanenMetadata.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] ?? {};

    return PanenMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalKg: statistics['total_kg'] ?? 0,
      totalNilai: statistics['total_nilai'] ?? 0,
      rataRataHarga: statistics['rata_rata_harga'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PanenMetadata{totalRecords: $totalRecords, totalKg: $totalKg, totalNilai: $totalNilai, rataRataHarga: $rataRataHarga}';
  }
}

// Model khusus untuk metadata panen by kebun
class KebunPanenMetadata extends PanenMetadata {
  final int kebunId;
  final String namaKebun;
  final String lokasiKebun;
  final String luasKebun;
  final String statusKebun;

  KebunPanenMetadata({
    required super.totalRecords,
    required super.totalKg,
    required super.totalNilai,
    required super.rataRataHarga,
    required super.userId,
    required super.userName,
    required this.kebunId,
    required this.namaKebun,
    required this.lokasiKebun,
    required this.luasKebun,
    required this.statusKebun,
  });

  factory KebunPanenMetadata.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] ?? {};
    final kebunInfo = json['kebun_info'] ?? {};

    return KebunPanenMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalKg: statistics['total_kg'] ?? 0,
      totalNilai: statistics['total_nilai'] ?? 0,
      rataRataHarga: statistics['rata_rata_harga'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      kebunId: json['kebun_id'] ?? 0,
      namaKebun: kebunInfo['nama'] ?? '',
      lokasiKebun: kebunInfo['lokasi'] ?? '',
      luasKebun: kebunInfo['luas'] ?? '',
      statusKebun: kebunInfo['status_kebun'] ?? '',
    );
  }

  @override
  String toString() {
    return 'KebunPanenMetadata{kebunId: $kebunId, namaKebun: $namaKebun, totalRecords: $totalRecords, totalKg: $totalKg, totalNilai: $totalNilai}';
  }
}

// Model untuk response list panen dari API
class PanenListResponse {
  final List<Panen> data;
  final PanenMetadata metadata;

  PanenListResponse({
    required this.data,
    required this.metadata,
  });

  factory PanenListResponse.fromJson(Map<String, dynamic> json) {
    return PanenListResponse(
      data: (json['data']['panen'] as List?)
              ?.map((item) => Panen.fromJson(item))
              .toList() ??
          [],
      metadata: PanenMetadata.fromJson(json['data']['metadata'] ?? {}),
    );
  }
}
