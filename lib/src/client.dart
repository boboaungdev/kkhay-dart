import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'errors.dart';
import 'models.dart';

class KkhayClient {
  final String apiKey;
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  KkhayClient({
    required String apiKey,
    String baseUrl = 'https://api.kkhay.com',
    Duration timeout = const Duration(seconds: 30),
    http.Client? httpClient,
  })  : apiKey = apiKey.trim(),
        baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        timeout = timeout,
        _client = httpClient ?? http.Client() {
    if (this.apiKey.isEmpty) {
      throw ArgumentError('KkhayClient: apiKey is required.');
    }
  }

  String _getUrl(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    if (baseUrl.endsWith('/api') || baseUrl.contains('api.')) {
      return '$baseUrl$cleanPath';
    }
    return '$baseUrl/api$cleanPath';
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(_getUrl(path));
    final headers = {
      'Accept': 'application/json',
      'x-api-key': apiKey,
      'User-Agent': 'kkhay-dart/1.0.0',
    };

    http.Request req = http.Request(method, uri);
    req.headers.addAll(headers);

    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }

    try {
      final streamedResponse = await _client.send(req).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final raw = response.body;

      Map<String, dynamic> decoded = {};
      try {
        if (raw.isNotEmpty) {
          decoded = jsonDecode(raw) as Map<String, dynamic>;
        }
      } catch (_) {}

      if (response.statusCode >= 400) {
        final message = decoded['message'] ?? decoded['error'] ?? 'HTTP ${response.statusCode} Error';
        throw KkhayApiException(
          response.statusCode,
          message.toString(),
          errorCode: decoded['code']?.toString(),
          details: decoded['details'],
        );
      }

      return decoded;
    } on TimeoutException {
      throw KkhayApiException(408, 'Request timed out after ${timeout.inSeconds}s');
    } on KkhayApiException {
      rethrow;
    } catch (e) {
      throw KkhayApiException(500, 'Network error: $e');
    }
  }

  /// Create a new crypto invoice.
  Future<Invoice> createInvoice(CreateInvoiceRequest request) async {
    if (request.priceAmount <= 0) {
      throw ArgumentError('priceAmount must be greater than 0');
    }
    if (request.payNetwork.isEmpty) {
      throw ArgumentError('payNetwork is required');
    }
    if (request.payToken.isEmpty) {
      throw ArgumentError('payToken is required');
    }

    final res = await _request(
      '/v1/merchant/invoices',
      method: 'POST',
      body: request.toJson(),
    );

    return Invoice.fromJson(res['invoice'] as Map<String, dynamic>);
  }

  /// Retrieve status and details of an invoice.
  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    if (invoiceId.trim().isEmpty) {
      throw ArgumentError('invoiceId is required');
    }

    final res = await _request('/v1/merchant/invoices/${Uri.encodeComponent(invoiceId.trim())}');
    final invoice = Invoice.fromJson(res['invoice'] as Map<String, dynamic>);
    final payments = ((res['payments'] as List<dynamic>?) ?? [])
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();

    return {
      'ok': res['ok'] ?? true,
      'invoice': invoice,
      'payments': payments,
    };
  }

  /// List invoices with filters.
  Future<Map<String, dynamic>> listInvoices({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;
    if (search != null) params['search'] = search;

    final query = Uri(queryParameters: params).query;
    final res = await _request('/v1/merchant/invoices?$query');
    final items = ((res['items'] as List<dynamic>?) ?? [])
        .map((i) => Invoice.fromJson(i as Map<String, dynamic>))
        .toList();

    return {
      'ok': res['ok'] ?? true,
      'items': items,
      'totalCount': res['totalCount'] ?? 0,
      'totalPages': res['totalPages'] ?? 1,
      'currentPage': res['currentPage'] ?? page,
      'limit': res['limit'] ?? limit,
    };
  }

  void close() {
    _client.close();
  }
}

