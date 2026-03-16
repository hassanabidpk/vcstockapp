# Hong Kong Stock Support

## Summary

Add `hk_stock` asset type to support Hong Kong Exchange (HKEX) listed stocks. Uses manual pricing (no free API supports HKEX) and HKD currency, following the same pattern as `sg_stock`.

## Decisions

- **Asset type**: `hk_stock` — ordered between `sg_stock` and `crypto`
- **Symbol format**: `9988.HK` (`.HK` suffix, like `.SI` for SG)
- **Currency**: HKD
- **Pricing**: Manual only (Twelve Data requires Pro plan for HKEX, FMP doesn't support it on free tier)
- **FX rate**: USD/HKD fetched alongside USD/SGD from Twelve Data

## Changes

### Shared types (`packages/types/src/holding.ts`)
- Add `"hk_stock"` to `AssetType`: `"us_stock" | "sg_stock" | "hk_stock" | "crypto"`

### API — Holdings route (`apps/api/src/routes/v1/holdings.routes.ts`)
- Add `"hk_stock"` to Zod `assetType` enum
- Add `"HKD"` to Zod `currency` enum

### API — Holding service (`apps/api/src/services/holding.service.ts`)
- Auto-set currency to `"HKD"` when `assetType === "hk_stock"`

### API — Stock price service (`apps/api/src/services/stock-price.service.ts`)
- Detect `.HK` suffix → manual price only (same as `.SI`)
- Add search support: filter by exchange `HKEX` or `XHKG`

### API — Portfolio service (`apps/api/src/services/portfolio.service.ts`)
- Handle `hk_stock` like `sg_stock` (always use manual price)
- Convert HKD→USD using `usdToHkd` rate for portfolio totals
- Return `usdToHkd` in portfolio response

### API — FX / Exchange rate
- Fetch USD/HKD rate from Twelve Data (or hardcode fallback ~7.78)
- Store in portfolio response alongside `usdToSgd`

### API — Reports
- Add `usdToHkd` to `CollectedData` type
- Show HKD rate in Telegram report footer: `USD/HKD: 7.7800`

### Web frontend (`apps/web/`)
- `AddHoldingModal.tsx`: Add HK button (between SG and Crypto), placeholder `9988.HK`
- `constants.ts`: Add `hk_stock: "HK Stocks"` to `ASSET_TYPE_LABELS`
- `api-client.ts`: Add `"hk_stock"` to types, `"HKD"` to currency
- `dashboard/page.tsx`: Add `hk_stock` to asset type grouping array
- Auto-currency: `hk_stock` → HKD

### Mobile app (`apps/mobile/`)
- Add `hkStock` to Dart `AssetType` enum with `@JsonValue('hk_stock')`
- Update `kAssetTypeLabels` and `kPlatformOptions`
- Update add holding sheet: HK button, `9988.HK` placeholder, auto-HKD

### Database
- No schema migration needed — `assetType` is already a `String` field
