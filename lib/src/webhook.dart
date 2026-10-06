import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'errors.dart';
import 'models.dart';

bool verifyWebhookSignature(dynamic payload, String? signature, String ipnSecret) {
  if (signature == null || signature.trim().isEmpty || ipnSecret.trim().isEmpty) {
    return false;
  }

  final rawBody = payload is String ? payload : jsonEncode(payload);
  final key = utf8.encode(ipnSecret.trim());
  final bytes = utf8.encode(rawBody);

  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);
  final expectedHex = digest.toString().toLowerCase();

  return _constantTimeCompare(expectedHex, signature.trim().toLowerCase());
}

WebhookEvent parseWebhookEvent(String rawBody, String? signature, String ipnSecret) {
  if (!verifyWebhookSignature(rawBody, signature, ipnSecret)) {
    throw SignatureVerificationException('Invalid K Khay webhook signature: Request rejected.');
  }

  final decoded = jsonDecode(rawBody) as Map<String, dynamic>;
  return WebhookEvent.fromJson(decoded);
}

bool _constantTimeCompare(String a, String b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

