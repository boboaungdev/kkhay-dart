class KkhayApiException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;
  final dynamic details;

  KkhayApiException(this.statusCode, this.message, {this.errorCode, this.details});

  @override
  String toString() => 'KkhayApiException [HTTP $statusCode]: $message';
}

class SignatureVerificationException implements Exception {
  final String message;
  SignatureVerificationException(this.message);

  @override
  String toString() => 'SignatureVerificationException: $message';
}

