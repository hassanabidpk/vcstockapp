class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const ApiException({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    return ApiException(
      code: error?['code'] as String? ?? 'UNKNOWN',
      message: error?['message'] as String? ?? 'Unknown error',
      details: error?['details'],
    );
  }

  factory ApiException.unknown([String? message]) {
    return ApiException(
      code: 'UNKNOWN',
      message: message ?? 'An unexpected error occurred',
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
