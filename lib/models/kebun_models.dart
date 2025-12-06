class KebunMetadata {
  final int totalRecords;
  final double totalLuas;
  final int totalTitikTanam;
  final int userId;
  final String userName;

  KebunMetadata({
    required this.totalRecords,
    required this.totalLuas,
    required this.totalTitikTanam,
    required this.userId,
    required this.userName,
  });

  factory KebunMetadata.fromJson(Map<String, dynamic> json) {
    return KebunMetadata(
      totalRecords: json['total_records'] ?? 0,
      totalLuas: (json['total_luas'] is String)
          ? double.tryParse(json['total_luas']) ?? 0.0
          : (json['total_luas'] ?? 0.0).toDouble(),
      totalTitikTanam: json['total_titik_tanam'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
    );
  }
}

class Kebun {
  final int id;
  final int userId;
  final String nama;
  final String lokasi;
  final String luas;
  final int titikTanam;
  final String waktuBeli;
  final String statusKepemilikan;
  final String statusKebun;
  final String? namaUser;

  Kebun({
    required this.id,
    required this.userId,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.titikTanam,
    required this.waktuBeli,
    required this.statusKepemilikan,
    required this.statusKebun,
    this.namaUser,
  });

  factory Kebun.fromJson(Map<String, dynamic> json) {
    return Kebun(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      lokasi: json['lokasi'],
      luas: json['luas'],
      titikTanam: json['titik_tanam'],
      waktuBeli: json['waktu_beli'],
      statusKepemilikan: json['status_kepemilikan'],
      statusKebun: json['status_kebun'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'lokasi': lokasi,
      'luas': luas,
      'titik_tanam': titikTanam,
      'waktu_beli': waktuBeli,
      'status_kepemilikan': statusKepemilikan,
      'status_kebun': statusKebun,
      if (namaUser != null) 'nama_user': namaUser,
    };
  }
}
