class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;
  final String? errorCode;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errorCode,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  bool get isMonthlyLimitExceeded => errorCode == 'MONTHLY_LIMIT_EXCEEDED';
  bool get isUnauthorized => errorCode == 'UNAUTHORIZED';
  bool get isNotFound =>
      errorCode == 'PANEN_NOT_FOUND' || errorCode == 'KEBUN_NOT_FOUND';

  // New getters for profile update errors
  bool get isMissingName => errorCode == 'MISSING_NAME';
  bool get isNameTooShort => errorCode == 'NAME_TOO_SHORT';
  bool get isNameTooLong => errorCode == 'NAME_TOO_LONG';
  bool get isUpdateFailed => errorCode == 'UPDATE_FAILED';

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errorCode: json['error_code'],
    );
  }

  @override
  String toString() {
    return 'ApiResponse{status: $status, message: $message, errorCode: $errorCode, data: $data}';
  }
}
