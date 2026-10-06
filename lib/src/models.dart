class CreateInvoiceRequest {
  final double priceAmount;
  final String? priceCurrency;
  final String payNetwork;
  final String payToken;
  final String? orderId;
  final String? title;
  final String? customerName;
  final String? customerEmail;
  final String? redirectUrl;
  final String? cancelUrl;
  final String? ipnCallbackUrl;
  final Map<String, dynamic>? metadata;

  CreateInvoiceRequest({
    required this.priceAmount,
    this.priceCurrency = 'USD',
    required this.payNetwork,
    required this.payToken,
    this.orderId,
    this.title,
    this.customerName,
    this.customerEmail,
    this.redirectUrl,
    this.cancelUrl,
    this.ipnCallbackUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'priceAmount': priceAmount,
      'priceCurrency': priceCurrency ?? 'USD',
      'payNetwork': payNetwork,
      'payToken': payToken,
    };
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

class Invoice {
  final String id;
  final String merchantId;
  final String? orderId;
  final String? title;
  final double priceAmount;
  final String priceCurrency;
  final String payAmount;
  final String payToken;
  final String payNetwork;
  final String depositAddress;
  final String status;
  final String feeAmount;
  final String netAmount;
  final String hostedUrl;
  final String expiresAt;
  final String createdAt;

  Invoice({
    required this.id,
    required this.merchantId,
    this.orderId,
    this.title,
    required this.priceAmount,
    required this.priceCurrency,
    required this.payAmount,
    required this.payToken,
    required this.payNetwork,
    required this.depositAddress,
    required this.status,
    required this.feeAmount,
    required this.netAmount,
    required this.hostedUrl,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      merchantId: json['merchantId'] ?? '',
      orderId: json['orderId'],
      title: json['title'],
      priceAmount: (json['priceAmount'] as num?)?.toDouble() ?? 0.0,
      priceCurrency: json['priceCurrency'] ?? 'USD',
      payAmount: json['payAmount']?.toString() ?? '0',
      payToken: json['payToken'] ?? '',
      payNetwork: json['payNetwork'] ?? '',
      depositAddress: json['depositAddress'] ?? '',
      status: json['status'] ?? 'WAITING',
      feeAmount: json['feeAmount']?.toString() ?? '0',
      netAmount: json['netAmount']?.toString() ?? '0',
      hostedUrl: json['hostedUrl'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class PaymentRecord {
  final String id;
  final String txHash;
  final String amountReceived;
  final int confirmations;
  final String status;
  final String? forwardedTxHash;
  final String createdAt;

  PaymentRecord({
    required this.id,
    required this.txHash,
    required this.amountReceived,
    required this.confirmations,
    required this.status,
    this.forwardedTxHash,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? '',
      txHash: json['txHash'] ?? '',
      amountReceived: json['amountReceived']?.toString() ?? '0',
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? '',
      forwardedTxHash: json['forwardedTxHash'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class WebhookEvent {
  final String event;
  final String invoiceId;
  final String? orderId;
  final double priceAmount;
  final String priceCurrency;
  final String payAmount;
  final String payToken;
  final String payNetwork;
  final String depositAddress;
  final String? txHash;
  final String status;
  final String timestamp;

  WebhookEvent({
    required this.event,
    required this.invoiceId,
    this.orderId,
    required this.priceAmount,
    required this.priceCurrency,
    required this.payAmount,
    required this.payToken,
    required this.payNetwork,
    required this.depositAddress,
    this.txHash,
    required this.status,
    required this.timestamp,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return WebhookEvent(
      event: json['event'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      orderId: json['order_id'],
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0.0,
      priceCurrency: json['price_currency'] ?? 'USD',
      payAmount: json['pay_amount']?.toString() ?? '0',
      payToken: json['pay_token'] ?? '',
      payNetwork: json['pay_network'] ?? '',
      depositAddress: json['deposit_address'] ?? '',
      txHash: json['tx_hash'],
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

