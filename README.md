# K Khay Dart & Flutter SDK 🎯

Official Dart and Flutter SDK for the **[K Khay Sovereign Crypto Payment Gateway](https://kkhay.com)**.

Accept non-custodial and custodial crypto payments (USDT, USDC, BNB, ETH on BSC, Polygon, Arbitrum, Base, Ethereum) directly in **Flutter mobile apps (iOS & Android)**, web apps, or backend Dart services.

---

## 📦 Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  kkhay: ^1.0.0
```

Or run:

```bash
flutter pub add kkhay
```

---

## ⚡ Quick Start

```dart
import 'package:kkhay/kkhay.dart';

void main() async {
  final client = KkhayClient(apiKey: 'kkhay_live_your_api_key_here');

  final invoice = await client.createInvoice(CreateInvoiceRequest(
    priceAmount: 49.99,
    priceCurrency: 'USD',
    payNetwork: 'bsc',
    payToken: 'USDT',
    orderId: 'FLUTTER-8812',
    title: 'In-App Coins Pack',
    customerEmail: 'player@example.com',
    redirectUrl: 'https://myapp.com/success',
  ));

  print('Invoice ID: ${invoice.id}');
  print('Hosted Checkout URL: ${invoice.hostedUrl}');
  print('Deposit Address: ${invoice.depositAddress}');
}
```

---

## 🔐 Webhook Verification (Dart Frog / Shelf)

```dart
import 'package:kkhay/kkhay.dart';

void handleWebhook(String rawBody, String? signature, String ipnSecret) {
  try {
    final event = parseWebhookEvent(rawBody, signature, ipnSecret);

    if (event.event == 'payment.finished') {
      print('Order ${event.orderId} paid with tx ${event.txHash}!');
    }
  } on SignatureVerificationException {
    print('Rejected invalid signature');
  }
}
```

---

## 📄 License

MIT © [K Khay](https://kkhay.com)

