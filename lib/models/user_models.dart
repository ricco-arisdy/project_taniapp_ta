class User {
  final int id;
  final String nama;
  final String email;
  final DateTime tanggalDibuat;
  final String? token;
  final String? tokenType;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.tanggalDibuat,
    this.token,
    this.tokenType = 'Bearer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Handle proper login response structure
      Map<String, dynamic> userData;
      String? userToken;
      String? userTokenType;

      // Case 1: Login/Register response: {user: {...}, token: "...", token_type: "..."}
      if (json.containsKey('user')) {
        userData = json['user'] as Map<String, dynamic>;
        userToken =
            json['token']
                as String?; // ✅ Ambil dari level yang sama dengan 'user'
        userTokenType = json['token_type'] as String?;
      }
      // Case 2: Direct user data: {id: 1, nama: "...", email: "...", ...}
      else if (json.containsKey('id')) {
        userData = json;
        userToken = json['token'] as String?; // Might be null for profile calls
        userTokenType = json['token_type'] as String?;
      }
      // Case 3: Error case
      else {
        throw Exception('Invalid JSON structure for User');
      }

      final user = User(
        id: userData['id'] as int,
        nama: userData['nama'] as String,
        email: userData['email'] as String,
        tanggalDibuat: DateTime.parse(userData['tanggal_dibuat'] as String),
        token: userToken,
        tokenType: userTokenType,
      );
      return user;
    } catch (e, stackTrace) {
      print('📚 [DEBUG] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
      if (token != null) 'token': token,
      if (tokenType != null) 'token_type': tokenType,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, nama: $nama, email: $email, token: ${token != null ? "${token!.substring(0, 20)}..." : "null"}}';
  }

  User copyWith({
    int? id,
    String? nama,
    String? email,
    DateTime? tanggalDibuat,
    String? token,
    String? tokenType,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
      token: token ?? this.token,
      tokenType: tokenType ?? this.tokenType,
    );
  }
}
