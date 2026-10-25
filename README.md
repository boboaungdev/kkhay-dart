# K Khay Dart & Flutter SDK 🎯

**Official Dart and Flutter SDK for K Khay — The Non-Custodial Crypto Payment Gateway**

[![pub package](https://img.shields.io/pub/v/kkhay.svg?color=10b981)](https://pub.dev/packages/kkhay)
[![CI](https://github.com/boboaungdev/kkhay-dart/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/boboaungdev/kkhay-dart/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175c2.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-Ready-02569B.svg)](https://flutter.dev)

Accept non-custodial cryptocurrency payments across **190+ blockchain networks** and **500+ tokens** (EVM, Bitcoin, Solana, TON, Tron, and XRPL) with **zero custody** and automatic direct-to-wallet settlement in **Flutter mobile apps (iOS & Android)**, desktop apps, web apps, or backend Dart services.

[Gateway Dashboard](https://gateway.kkhay.com) • [API Keys](https://gateway.kkhay.com/dashboard/keys) • [Website](https://kkhay.com)

---

## ⚡ Highlights

- 🛡️ **100% Non-Custodial**: Payments settle directly to your external wallet address in seconds. K Khay never holds your private keys or customer funds.
- 🌐 **190+ Networks**:
  - **EVM (180+ Chains)**: BNB Smart Chain (`bsc`), Polygon (`polygon`), Base (`base`), Arbitrum (`arbitrum`), Ethereum (`ethereum`), Optimism (`optimism`), Avalanche (`avalanche`).
  - **UTXO Chains**: Bitcoin (`bitcoin`), Dogecoin (`dogecoin`), Litecoin (`litecoin`), Bitcoin Cash (`bitcoincash`).
  - **High-Throughput Chains**: Solana (`solana`), TON (`ton`), Tron (`tron`), XRP Ledger (`ripple`).
- 🪙 **500+ Tokens**: Native coins and tokens (USDT, USDC, BTC, ETH, SOL, TON, BNB, DOGE, XRP, TRX, LTC, DAI, and more).
- 📱 **Flutter & Dart Native**: Zero native platform dependencies, works smoothly across iOS, Android, macOS, Linux, Windows, and Web.
- 🔔 **HMAC-SHA256 Webhook Engine**: Timing-safe cryptographic signature validation (`x-kkhay-signature`).

---

## 📦 Installation

Add `kkhay` to your `pubspec.yaml`:

```yaml
dependencies:
  kkhay: ^1.0.4
```

Or run:

```bash
# In Flutter
flutter pub add kkhay

# In pure Dart
dart pub add kkhay
```

---

## 🚀 Quickstart

### 1. Initialize the Client

Retrieve your API key from the [K Khay Gateway Dashboard](https://gateway.kkhay.com/dashboard/keys).

```dart
import 'package:kkhay/kkhay.dart';

final client = KkhayClient(
  apiKey: 'kkhay_live_your_api_key_here',
);
```

---

### 2. Create a Crypto Payment Invoice

Accept stablecoins, native coins, or let the customer choose their chain on checkout:

```dart
// Example A: USDT on BNB Smart Chain (BSC)
final invoice = await client.createInvoice(CreateInvoiceRequest(
  amount: 49.99,
  currency: 'USD',
  payNetwork: 'bsc',        // 'bsc' | 'polygon' | 'base' | 'arbitrum' | 'ethereum' | 'solana' | 'bitcoin' | 'ton'
  payToken: 'USDT',         // 'USDT' | 'USDC' | 'BTC' | 'ETH' | 'SOL' | 'TON'
  orderId: 'ORDER-9842',    // Your internal order ID
  title: 'Annual Pro Plan',
  customerEmail: 'alice@example.com',
  redirectUrl: 'https://myshop.com/success',
));

print('Invoice ID: ${invoice.id}');
print('Gateway ID: ${invoice.gatewayId}');
print('Deposit Address: ${invoice.depositAddress}');
print('Checkout Hosted URL: ${invoice.hostedUrl}');

// In Flutter, open the hosted checkout in browser:
// launchUrl(Uri.parse(invoice.hostedUrl));
```

```dart
// Example B: Native Bitcoin or Solana
final btcInvoice = await client.createInvoice(CreateInvoiceRequest(
  amount: 120.00,
  currency: 'USD',
  payNetwork: 'bitcoin',
  payToken: 'BTC',
  orderId: 'ORDER-9843',
));

final solInvoice = await client.createInvoice(CreateInvoiceRequest(
  amount: 25.00,
  currency: 'USD',
  payNetwork: 'solana',
  payToken: 'SOL',
  orderId: 'ORDER-9844',
));
```

---

### 3. Fetch & List Invoices

```dart
// Retrieve a single invoice with blockchain transaction history
final response = await client.getInvoice('01940000-0000-7000-8000-000000000001');

print('Status: ${response.invoice.status}'); // WAITING | PAID | EXPIRED | CANCELED
for (final payment in response.payments) {
  print('Received: ${payment.amountReceived} | Confirmations: ${payment.confirmations} | Tx: ${payment.txHash}');
}

// List recent invoices with pagination
final list = await client.listInvoices(
  page: 1,
  limit: 20,
  status: 'PAID',
);

print('Total Invoices: ${list.totalCount}');
```

---

### 4. Verify Incoming Webhooks (IPN)

In your backend server (`Shelf`, `Dart Frog`, or serverless Dart), verify the incoming `x-kkhay-signature` header:

```dart
import 'package:kkhay/kkhay.dart';

void handleWebhook(String rawBody, String? signature, String webhookSecret) {
  try {
    final event = parseWebhookEvent(rawBody, signature, webhookSecret);

    if (event.event == 'payment.paid') {
      print('Payment confirmed for Order: ${event.orderId}');
      print('Tx Hash: ${event.txHash}');
      print('Amount: ${event.payAmount} ${event.payToken} on ${event.payNetwork}');
      // Fulfill your customer's order in your database
    }
  } on SignatureVerificationException catch (e) {
    print('Rejected invalid signature: $e');
  }
}
```

---

### 5. Clean Resource Disposal

When your app or service is shutting down:

```dart
client.close();
```

---

## 🌐 Supported Networks & Families

| Network Family | Popular Chains | Supported Tokens |
| :--- | :--- | :--- |
| **EVM (180+ Chains)** | Ethereum, BNB Smart Chain, Polygon, Arbitrum, Base, Optimism, Avalanche | USDT, USDC, ETH, BNB, POL, AVAX, DAI, ERC-20s |
| **UTXO** | Bitcoin, Dogecoin, Litecoin, Bitcoin Cash | BTC, DOGE, LTC, BCH |
| **Solana** | Solana Mainnet | SOL, USDT, USDC |
| **TON** | The Open Network | TON, USDT |
| **Tron (TVM)** | Tron Mainnet | TRX, USDT |
| **XRPL** | XRP Ledger | XRP |

---

## 📄 License

MIT © [K Khay](https://kkhay.com)
