# Changelog

## 1.0.4

- **Non-Custodial Multi-Chain Architecture**: Expanded support to 190+ blockchain networks (EVM, Bitcoin, Solana, TON, Tron, XRPL, Dogecoin, Litecoin) and 500+ cryptocurrencies.
- **Dedicated Gateway Endpoints**: Migrated all API calls to `/v1/gateway/invoices`.
- **Database-Aligned Enums**: Full 1:1 alignment with PostgreSQL schema (`GatewayInvoiceStatus`: `waiting`, `paid`, `expired`, `canceled`).
- **Strongly-Typed Responses**: Added `GetInvoiceResponse` and `ListInvoicesResponse` models.
- **Resource Cleanup**: Added `client.close()` for disposing HTTP client streams in Flutter/Dart.
- **Zero Legacy Code**: Removed deprecated `merchantId` and legacy fallback logic.

## 1.0.0

- Initial release of K Khay Dart & Flutter SDK.
