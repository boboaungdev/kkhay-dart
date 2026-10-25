/// K Khay Gateway Invoice Status enum matching PostgreSQL pgEnum.
enum GatewayInvoiceStatus {
  waiting,
  paid,
  expired,
  canceled;

  static GatewayInvoiceStatus fromString(String val) {
    switch (val.toUpperCase().trim()) {
      case 'PAID':
        return GatewayInvoiceStatus.paid;
      case 'EXPIRED':
        return GatewayInvoiceStatus.expired;
      case 'CANCELED':
        return GatewayInvoiceStatus.canceled;
      case 'WAITING':
      default:
        return GatewayInvoiceStatus.waiting;
    }
  }

  String toValue() => name.toUpperCase();
}

/// Classification of invoice intent.
enum GatewayInvoiceType {
  payment,
  donation,
  subscription;

  static GatewayInvoiceType fromString(String val) {
    switch (val.toUpperCase().trim()) {
      case 'DONATION':
        return GatewayInvoiceType.donation;
      case 'SUBSCRIPTION':
        return GatewayInvoiceType.subscription;
      case 'PAYMENT':
      default:
        return GatewayInvoiceType.payment;
    }
  }

  String toValue() => name.toUpperCase();
}

/// On-chain payment settlement status.
enum GatewayPaymentStatus {
  settling,
  settled,
  failed;

  static GatewayPaymentStatus fromString(String val) {
    switch (val.toUpperCase().trim()) {
      case 'SETTLED':
        return GatewayPaymentStatus.settled;
      case 'FAILED':
        return GatewayPaymentStatus.failed;
      case 'SETTLING':
      default:
        return GatewayPaymentStatus.settling;
    }
  }

  String toValue() => name.toUpperCase();
}

/// Parameters required to create a new payment invoice on K Khay Gateway.
class CreateInvoiceRequest {
  final double? amount;
  final double? priceAmount;
  final String? currency;
  final String? priceCurrency;
  final String? payNetwork;
  final String? payToken;
  final String? settlementAsset;
  final String? type;
  final String? orderId;
  final String? title;
  final String? customerName;
  final String? customerEmail;
  final String? redirectUrl;
  final String? cancelUrl;
  final String? ipnCallbackUrl;
  final Map<String, dynamic>? metadata;

  CreateInvoiceRequest({
    this.amount,
    this.priceAmount,
    this.currency,
    this.priceCurrency,
    this.payNetwork,
    this.payToken,
    this.settlementAsset,
    this.type,
    this.orderId,
    this.title,
    this.customerName,
    this.customerEmail,
    this.redirectUrl,
    this.cancelUrl,
    this.ipnCallbackUrl,
    this.metadata,
  }) {
    final resolved = amount ?? priceAmount;
    if (resolved == null || resolved <= 0) {
      throw ArgumentError('CreateInvoiceRequest: amount or priceAmount must be greater than 0');
    }
  }

  Map<String, dynamic> toJson() {
    final resolvedAmount = amount ?? priceAmount ?? 0.0;
    final resolvedCurrency = currency ?? priceCurrency ?? 'USD';

    final map = <String, dynamic>{
      'amount': resolvedAmount,
      'priceAmount': resolvedAmount,
      'currency': resolvedCurrency,
      'priceCurrency': resolvedCurrency,
    };

    if (payNetwork != null && payNetwork!.trim().isNotEmpty) {
      map['payNetwork'] = payNetwork!.trim().toLowerCase();
    }
    if (payToken != null && payToken!.trim().isNotEmpty) {
      map['payToken'] = payToken!.trim().toUpperCase();
    }
    if (settlementAsset != null) {
      map['settlementAsset'] = settlementAsset;
    }
    if (type != null) {
      map['type'] = type!.trim().toUpperCase();
    }
    if (orderId != null) map['orderId'] = orderId;
    if (title != null) map['title'] = title;
    if (customerName != null) map['customerName'] = customerName;
    if (customerEmail != null) map['customerEmail'] = customerEmail;
    if (redirectUrl != null) map['redirectUrl'] = redirectUrl;
    if (cancelUrl != null) map['cancelUrl'] = cancelUrl;
    if (ipnCallbackUrl != null) map['ipnCallbackUrl'] = ipnCallbackUrl;
    if (metadata != null) map['metadata'] = metadata;

    return map;
  }
}

/// Fully typed invoice model matching K Khay Gateway PostgreSQL schema.
class KkhayInvoice {
  final String id;
  final String gatewayId;
  final String type;
  final String? orderId;
  final String? title;
  final double amount;
  final String currency;
  final double priceAmount;
  final String priceCurrency;
  final String? settlementAsset;
  final String? payAmount;
  final String? payToken;
  final String? payNetwork;
  final String? lockedRate;
  final String depositAddress;
  final int? derivationIndex;
  final String status;
  final String feeAmount;
  final String netAmount;
  final String? customerName;
  final String? customerEmail;
  final String? redirectUrl;
  final String? cancelUrl;
  final String? ipnCallbackUrl;
  final String? paymentMethod;
  final String? settlementMode;
  final String payoutAddress;
  final Map<String, dynamic>? metadata;
  final String hostedUrl;
  final String expiresAt;
  final String createdAt;
  final String? updatedAt;

  KkhayInvoice({
    required this.id,
    required this.gatewayId,
    required this.type,
    this.orderId,
    this.title,
    required this.amount,
    required this.currency,
    required this.priceAmount,
    required this.priceCurrency,
    this.settlementAsset,
    this.payAmount,
    this.payToken,
    this.payNetwork,
    this.lockedRate,
    required this.depositAddress,
    this.derivationIndex,
    required this.status,
    required this.feeAmount,
    required this.netAmount,
    this.customerName,
    this.customerEmail,
    this.redirectUrl,
    this.cancelUrl,
    this.ipnCallbackUrl,
    this.paymentMethod,
    this.settlementMode,
    required this.payoutAddress,
    this.metadata,
    required this.hostedUrl,
    required this.expiresAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory KkhayInvoice.fromJson(Map<String, dynamic> json) {
    final amountNum = (json['amount'] ?? json['priceAmount']) as num?;
    final currencyStr = (json['currency'] ?? json['priceCurrency'] ?? 'USD').toString();

    return KkhayInvoice(
      id: json['id']?.toString() ?? '',
      gatewayId: json['gatewayId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'PAYMENT',
      orderId: json['orderId']?.toString(),
      title: json['title']?.toString(),
      amount: amountNum?.toDouble() ?? 0.0,
      currency: currencyStr,
      priceAmount: amountNum?.toDouble() ?? 0.0,
      priceCurrency: currencyStr,
      settlementAsset: json['settlementAsset']?.toString(),
      payAmount: json['payAmount']?.toString(),
      payToken: json['payToken']?.toString(),
      payNetwork: json['payNetwork']?.toString(),
      lockedRate: json['lockedRate']?.toString(),
      depositAddress: json['depositAddress']?.toString() ?? '',
      derivationIndex: (json['derivationIndex'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'WAITING',
      feeAmount: json['feeAmount']?.toString() ?? '0',
      netAmount: json['netAmount']?.toString() ?? '0',
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      cancelUrl: json['cancelUrl']?.toString(),
      ipnCallbackUrl: json['ipnCallbackUrl']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      settlementMode: json['settlementMode']?.toString(),
      payoutAddress: json['payoutAddress']?.toString() ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      hostedUrl: json['hostedUrl']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gatewayId': gatewayId,
      'type': type,
      'orderId': orderId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'priceAmount': priceAmount,
      'priceCurrency': priceCurrency,
      'settlementAsset': settlementAsset,
      'payAmount': payAmount,
      'payToken': payToken,
      'payNetwork': payNetwork,
      'lockedRate': lockedRate,
      'depositAddress': depositAddress,
      'derivationIndex': derivationIndex,
      'status': status,
      'feeAmount': feeAmount,
      'netAmount': netAmount,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'redirectUrl': redirectUrl,
      'cancelUrl': cancelUrl,
      'ipnCallbackUrl': ipnCallbackUrl,
      'paymentMethod': paymentMethod,
      'settlementMode': settlementMode,
      'payoutAddress': payoutAddress,
      'metadata': metadata,
      'hostedUrl': hostedUrl,
      'expiresAt': expiresAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Legacy alias for KkhayInvoice.
typedef Invoice = KkhayInvoice;

/// On-chain payment transaction confirmed on the blockchain.
class KkhayPaymentRecord {
  final String id;
  final String invoiceId;
  final String txHash;
  final String? fromAddress;
  final String amountReceived;
  final int confirmations;
  final String? forwardedTxHash;
  final String? forwardedAt;
  final String status;
  final String createdAt;

  KkhayPaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.txHash,
    this.fromAddress,
    required this.amountReceived,
    required this.confirmations,
    this.forwardedTxHash,
    this.forwardedAt,
    required this.status,
    required this.createdAt,
  });

  factory KkhayPaymentRecord.fromJson(Map<String, dynamic> json) {
    return KkhayPaymentRecord(
      id: json['id']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString() ?? '',
      txHash: json['txHash']?.toString() ?? '',
      fromAddress: json['fromAddress']?.toString(),
      amountReceived: json['amountReceived']?.toString() ?? '0',
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      forwardedTxHash: json['forwardedTxHash']?.toString(),
      forwardedAt: json['forwardedAt']?.toString(),
      status: json['status']?.toString() ?? 'SETTLING',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'txHash': txHash,
      'fromAddress': fromAddress,
      'amountReceived': amountReceived,
      'confirmations': confirmations,
      'forwardedTxHash': forwardedTxHash,
      'forwardedAt': forwardedAt,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

/// Legacy alias for KkhayPaymentRecord.
typedef PaymentRecord = KkhayPaymentRecord;

/// Response returned when looking up an invoice by ID.
class GetInvoiceResponse {
  final bool ok;
  final KkhayInvoice invoice;
  final List<KkhayPaymentRecord> payments;

  GetInvoiceResponse({
    required this.ok,
    required this.invoice,
    required this.payments,
  });

  factory GetInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return GetInvoiceResponse(
      ok: json['ok'] == true,
      invoice: KkhayInvoice.fromJson(json['invoice'] as Map<String, dynamic>),
      payments: ((json['payments'] as List<dynamic>?) ?? [])
          .map((p) => KkhayPaymentRecord.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response returned when listing invoices with pagination.
class ListInvoicesResponse {
  final bool ok;
  final List<KkhayInvoice> items;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;

  ListInvoicesResponse({
    required this.ok,
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory ListInvoicesResponse.fromJson(Map<String, dynamic> json) {
    return ListInvoicesResponse(
      ok: json['ok'] == true,
      items: ((json['items'] as List<dynamic>?) ?? [])
          .map((i) => KkhayInvoice.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );
  }
}

/// Strongly-typed Webhook Event dispatched by K Khay IPN engine.
class KkhayWebhookEvent {
  final String event;
  final String invoiceId;
  final String? invoiceType;
  final String gatewayId;
  final String? orderId;
  final double priceAmount;
  final String priceCurrency;
  final String? payAmount;
  final String? payToken;
  final String? payNetwork;
  final String depositAddress;
  final String? txHash;
  final String status;
  final String timestamp;

  KkhayWebhookEvent({
    required this.event,
    required this.invoiceId,
    this.invoiceType,
    required this.gatewayId,
    this.orderId,
    required this.priceAmount,
    required this.priceCurrency,
    this.payAmount,
    this.payToken,
    this.payNetwork,
    required this.depositAddress,
    this.txHash,
    required this.status,
    required this.timestamp,
  });

  factory KkhayWebhookEvent.fromJson(Map<String, dynamic> json) {
    final amountNum = (json['price_amount'] ?? json['amount']) as num?;
    final curr = (json['price_currency'] ?? json['currency'] ?? 'USD').toString();

    return KkhayWebhookEvent(
      event: json['event']?.toString() ?? '',
      invoiceId: (json['invoice_id'] ?? json['id'] ?? '').toString(),
      invoiceType: json['invoice_type']?.toString(),
      gatewayId: (json['gateway_id'] ?? json['gatewayId'] ?? '').toString(),
      orderId: json['order_id']?.toString(),
      priceAmount: amountNum?.toDouble() ?? 0.0,
      priceCurrency: curr,
      payAmount: json['pay_amount']?.toString(),
      payToken: json['pay_token']?.toString(),
      payNetwork: json['pay_network']?.toString(),
      depositAddress: json['deposit_address']?.toString() ?? '',
      txHash: json['tx_hash']?.toString(),
      status: json['status']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}

/// Legacy alias for KkhayWebhookEvent.
typedef WebhookEvent = KkhayWebhookEvent;
