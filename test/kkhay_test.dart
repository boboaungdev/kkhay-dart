import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:kkhay/kkhay.dart';

void main() {
  group('KkhayClient Initialization', () {
    test('initialization with apiKey', () {
      final client = KkhayClient(apiKey: 'kkhay_live_test_123');
      expect(client.apiKey, equals('kkhay_live_test_123'));
      expect(client.baseUrl, equals('https://api.kkhay.com'));
      client.close();
    });

    test('custom baseUrl and timeout', () {
      final client = KkhayClient(
        apiKey: 'kkhay_test_key',
        baseUrl: 'http://localhost:3000',
        timeout: const Duration(seconds: 10),
      );
      expect(client.baseUrl, equals('http://localhost:3000'));
      expect(client.timeout, equals(const Duration(seconds: 10)));
      client.close();
    });

    test('throws on empty apiKey', () {
      expect(() => KkhayClient(apiKey: ''), throwsArgumentError);
      expect(() => KkhayClient(apiKey: '   '), throwsArgumentError);
    });
  });

  group('CreateInvoiceRequest Validation', () {
    test('validates positive amount', () {
      expect(
        () => CreateInvoiceRequest(amount: 0),
        throwsArgumentError,
      );
      expect(
        () => CreateInvoiceRequest(priceAmount: -10),
        throwsArgumentError,
      );
    });

    test('serializes to JSON cleanly', () {
      final req = CreateInvoiceRequest(
        amount: 49.99,
        currency: 'USD',
        payNetwork: 'bsc',
        payToken: 'USDT',
        orderId: 'ORD-101',
        title: 'Pro Plan',
      );
      final json = req.toJson();
      expect(json['amount'], equals(49.99));
      expect(json['priceAmount'], equals(49.99));
      expect(json['currency'], equals('USD'));
      expect(json['payNetwork'], equals('bsc'));
      expect(json['payToken'], equals('USDT'));
      expect(json['orderId'], equals('ORD-101'));
    });
  });

  group('Mock HTTP API Endpoints', () {
    test('createInvoice targets /v1/gateway/invoices', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/v1/gateway/invoices'));
        expect(request.method, equals('POST'));
        expect(request.headers['x-api-key'], equals('kkhay_test_key'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['amount'], equals(50.0));
        expect(body['payToken'], equals('USDT'));

        return http.Response(
          jsonEncode({
            'ok': true,
            'invoice': {
              'id': '01940000-0000-7000-8000-000000000001',
              'gatewayId': 'gw_test123',
              'type': 'PAYMENT',
              'amount': 50.0,
              'currency': 'USD',
              'priceAmount': 50.0,
              'priceCurrency': 'USD',
              'payAmount': '50.00',
              'payToken': 'USDT',
              'payNetwork': 'bsc',
              'depositAddress': '0x71C...test',
              'payoutAddress': '0xPayout...test',
              'status': 'WAITING',
              'feeAmount': '0.50',
              'netAmount': '49.50',
              'hostedUrl': 'https://kkhay.com/invoice/01940000-0000-7000-8000-000000000001',
              'expiresAt': '2026-10-26T00:00:00Z',
              'createdAt': '2026-10-25T00:00:00Z',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = KkhayClient(apiKey: 'kkhay_test_key', httpClient: mockClient);
      final invoice = await client.createInvoice(CreateInvoiceRequest(
        amount: 50.0,
        payNetwork: 'bsc',
        payToken: 'USDT',
      ));

      expect(invoice.id, equals('01940000-0000-7000-8000-000000000001'));
      expect(invoice.gatewayId, equals('gw_test123'));
      expect(invoice.status, equals('WAITING'));
      expect(invoice.hostedUrl, contains('https://kkhay.com/invoice/'));
      client.close();
    });

    test('getInvoice targets /v1/gateway/invoices/:id', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/v1/gateway/invoices/inv_999'));
        expect(request.method, equals('GET'));

        return http.Response(
          jsonEncode({
            'ok': true,
            'invoice': {
              'id': 'inv_999',
              'gatewayId': 'gw_999',
              'type': 'PAYMENT',
              'amount': 100.0,
              'currency': 'USD',
              'priceAmount': 100.0,
              'priceCurrency': 'USD',
              'depositAddress': '0xDeposit...',
              'payoutAddress': '0xPayout...',
              'status': 'PAID',
              'feeAmount': '1.00',
              'netAmount': '99.00',
              'hostedUrl': 'https://kkhay.com/invoice/inv_999',
              'expiresAt': '2026-10-26T00:00:00Z',
              'createdAt': '2026-10-25T00:00:00Z',
            },
            'payments': [
              {
                'id': 'pay_1',
                'invoiceId': 'inv_999',
                'txHash': '0xabc123',
                'amountReceived': '100.00',
                'confirmations': 12,
                'status': 'SETTLED',
                'createdAt': '2026-10-25T00:05:00Z',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = KkhayClient(apiKey: 'kkhay_test_key', httpClient: mockClient);
      final res = await client.getInvoice('inv_999');

      expect(res.ok, isTrue);
      expect(res.invoice.status, equals('PAID'));
      expect(res.payments.length, equals(1));
      expect(res.payments.first.txHash, equals('0xabc123'));
      expect(res.payments.first.confirmations, equals(12));
      client.close();
    });

    test('listInvoices targets /v1/gateway/invoices with query params', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/v1/gateway/invoices'));
        expect(request.url.queryParameters['page'], equals('1'));
        expect(request.url.queryParameters['limit'], equals('10'));
        expect(request.url.queryParameters['status'], equals('PAID'));

        return http.Response(
          jsonEncode({
            'ok': true,
            'items': [],
            'totalCount': 0,
            'totalPages': 0,
            'currentPage': 1,
            'limit': 10,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = KkhayClient(apiKey: 'kkhay_test_key', httpClient: mockClient);
      final res = await client.listInvoices(page: 1, limit: 10, status: 'PAID');

      expect(res.ok, isTrue);
      expect(res.items, isEmpty);
      expect(res.totalCount, equals(0));
      client.close();
    });
  });

  group('Webhook HMAC-SHA256 Verification', () {
    const secret = 'whsec_test_secret_123';
    final payload = jsonEncode({
      'event': 'payment.paid',
      'invoice_id': 'inv_123',
      'gateway_id': 'gw_987',
      'pay_amount': '50.00',
      'pay_token': 'USDT',
      'status': 'PAID',
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

  group('Webhook Parsing', () {
    const secret = 'whsec_secret_456';
    final raw = jsonEncode({
      'event': 'payment.paid',
      'invoice_id': 'inv_abc',
      'gateway_id': 'gw_xyz',
      'order_id': 'ORD-555',
      'price_amount': 50.0,
      'price_currency': 'USD',
      'pay_amount': '50.00',
      'pay_token': 'USDT',
      'pay_network': 'bsc',
      'deposit_address': '0x123',
      'status': 'PAID',
      'timestamp': '2026-10-25T00:00:00Z',
    });

    final key = utf8.encode(secret);
    final signature = Hmac(sha256, key).convert(utf8.encode(raw)).toString();

    test('parses valid event', () {
      final event = parseWebhookEvent(raw, signature, secret);
      expect(event.event, equals('payment.paid'));
      expect(event.invoiceId, equals('inv_abc'));
      expect(event.gatewayId, equals('gw_xyz'));
      expect(event.orderId, equals('ORD-555'));
      expect(event.payToken, equals('USDT'));
      expect(event.status, equals('PAID'));
    });

    test('throws SignatureVerificationException on bad signature', () {
      expect(
        () => parseWebhookEvent(raw, 'invalid_signature_hex', secret),
        throwsA(isA<SignatureVerificationException>()),
      );
    });
  });
}
