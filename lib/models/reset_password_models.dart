class ResetPasswordRequest {
  final String email;

  ResetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyOtpRequest {
  final String email;
  final String otpKode;

  VerifyOtpRequest({required this.email, required this.otpKode});

  Map<String, dynamic> toJson() => {'email': email, 'otp_kode': otpKode};
}

class ResetPasswordData {
  final String email;
  final String otpKode;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordData({
    required this.email,
    required this.otpKode,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp_kode': otpKode,
    'new_password': newPassword,
    'confirm_password': confirmPassword,
  };
}

class OtpResponse {
  final String email;
  final String? otpKode;
  final DateTime berakhirPada;
  final int maxPercobaan;
  final int? sisaPercobaan;
  final DateTime? terakhirRequest;
  final int? cooldownDetik;

  OtpResponse({
    required this.email,
    this.otpKode,
    required this.berakhirPada,
    this.maxPercobaan = 5,
    this.sisaPercobaan,
    this.terakhirRequest,
    this.cooldownDetik = 120,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      email: json['email'] as String,
      otpKode: json['otp_kode'] as String?,
      berakhirPada: DateTime.parse(json['berakhir_pada'] as String),
      maxPercobaan: json['max_percobaan'] as int? ?? 5,
      sisaPercobaan: json['sisa_percobaan'] as int?,
      terakhirRequest: json['terakhir_request'] != null
          ? DateTime.parse(json['terakhir_request'] as String)
          : null,
      cooldownDetik: json['cooldown_detik'] as int? ?? 120,
    );
  }

  bool get isExpired => DateTime.now().isAfter(berakhirPada);

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(berakhirPada)) {
      return Duration.zero;
    }
    return berakhirPada.difference(now);
  }

  // Check if still in cooldown period
  bool get isInCooldown {
    if (terakhirRequest == null) return false;
    final now = DateTime.now();
    final elapsed = now.difference(terakhirRequest!);
    return elapsed.inSeconds < (cooldownDetik ?? 120);
  }

  //Get remaining cooldown time
  Duration get remainingCooldown {
    if (terakhirRequest == null || !isInCooldown) {
      return Duration.zero;
    }
    final now = DateTime.now();
    final elapsed = now.difference(terakhirRequest!);
    final remaining = (cooldownDetik ?? 120) - elapsed.inSeconds;
    return Duration(seconds: remaining > 0 ? remaining : 0);
  }

  // Get formatted cooldown time (mm:ss)
  String get cooldownTimeFormatted {
    final remaining = remainingCooldown;
    if (remaining.inSeconds <= 0) return '';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
