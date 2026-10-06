import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:kkhay/kkhay.dart';

void main() {
  group('KkhayClient', () {
    test('initialization with apiKey', () {
      final client = KkhayClient(apiKey: 'kkhay_live_test_123');
      expect(client.apiKey, equals('kkhay_live_test_123'));
      expect(client.baseUrl, equals('https://api.kkhay.com'));
    });

    test('throws on empty apiKey', () {
      expect(() => KkhayClient(apiKey: ''), throwsArgumentError);
    });
  });

  group('Webhook verification', () {
    const secret = 'whsec_test_secret_123';
    final payload = jsonEncode({
      'event': 'payment.finished',
      'invoice_id': 'inv_123',
      'pay_amount': '50.00',
      'pay_token': 'USDT',
    });

    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final signature = Hmac(sha256, key).convert(bytes).toString();

    test('verifies valid HMAC-SHA256 signature', () {
      expect(verifyWebhookSignature(payload, signature, secret), isTrue);
    });

    test('fails on tampered payload', () {
      expect(verifyWebhookSignature('$payload tampered', signature, secret), isFalse);
    });

    test('fails on wrong secret', () {
      expect(verifyWebhookSignature(payload, signature, 'wrong_secret'), isFalse);
    });

    test('fails on null or empty signature', () {
      expect(verifyWebhookSignature(payload, null, secret), isFalse);
      expect(verifyWebhookSignature(payload, '', secret), isFalse);
    });
  });

  group('Webhook parsing', () {
    const secret = 'whsec_secret';
    final raw = jsonEncode({
      'event': 'payment.finished',
      'invoice_id': 'inv_abc',
      'price_amount': 50.0,
      'price_currency': 'USD',
      'pay_amount': '50.00',
      'pay_token': 'USDT',
      'pay_network': 'bsc',
      'deposit_address': '0x123',
      'status': 'paid',
      'timestamp': '2026-10-07T00:00:00Z',
    });

    final key = utf8.encode(secret);
    final signature = Hmac(sha256, key).convert(utf8.encode(raw)).toString();

    test('parses valid event', () {
      final event = parseWebhookEvent(raw, signature, secret);
      expect(event.event, equals('payment.finished'));
      expect(event.invoiceId, equals('inv_abc'));
      expect(event.payToken, equals('USDT'));
    });

    test('throws SignatureVerificationException on bad signature', () {
      expect(
        () => parseWebhookEvent(raw, 'bad_sig', secret),
        throwsA(isA<SignatureVerificationException>()),
      );
    });
  });
}

