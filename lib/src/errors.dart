/// Standard exception thrown when a K Khay Gateway API request fails.
class KkhayApiException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;
  final dynamic details;

  KkhayApiException(
    this.statusCode,
    this.message, {
    this.errorCode,
    this.details,
  });

  @override
  String toString() => 'KkhayApiException [HTTP $statusCode]: $message';
}

/// Thrown when an incoming IPN webhook signature is invalid or tampered with.
class SignatureVerificationException implements Exception {
  final String message;

  SignatureVerificationException(this.message);

  @override
  String toString() => 'SignatureVerificationException: $message';
}
