import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'errors.dart';
import 'models.dart';

/// Verifies the HMAC-SHA256 signature sent with incoming K Khay IPN webhooks.
///
/// Returns `true` if the signature is authentic and untampered.
bool verifyWebhookSignature(
  dynamic payload,
  String? signature,
  String webhookSecret,
) {
  if (signature == null || signature.trim().isEmpty || webhookSecret.trim().isEmpty) {
    return false;
  }

  final rawBody = payload is String ? payload : jsonEncode(payload);
  final key = utf8.encode(webhookSecret.trim());
  final bytes = utf8.encode(rawBody);

  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);
  final expectedHex = digest.toString().toLowerCase();

  return _constantTimeCompare(expectedHex, signature.trim().toLowerCase());
}

/// Validates and parses an incoming K Khay IPN webhook request.
/// Throws [SignatureVerificationException] if the signature does not match.
KkhayWebhookEvent parseWebhookEvent(
  String rawBody,
  String? signature,
  String webhookSecret,
) {
  if (!verifyWebhookSignature(rawBody, signature, webhookSecret)) {
    throw SignatureVerificationException(
      'Invalid or untrusted K Khay webhook signature (x-kkhay-signature mismatch).',
    );
  }

  try {
    final decoded = jsonDecode(rawBody) as Map<String, dynamic>;
    return KkhayWebhookEvent.fromJson(decoded);
  } catch (err) {
    throw FormatException('Failed to parse K Khay webhook body as JSON: $err');
  }
}

/// Constant-time string comparison to prevent cryptographic timing attacks.
bool _constantTimeCompare(String a, String b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}
