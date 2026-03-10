import 'package:freezed_annotation/freezed_annotation.dart';

part 'holding.freezed.dart';
part 'holding.g.dart';

enum AssetType {
  @JsonValue('us_stock')
  usStock,
  @JsonValue('sg_stock')
  sgStock,
  @JsonValue('crypto')
  crypto,
}

@freezed
class HoldingWithPrice with _$HoldingWithPrice {
  const factory HoldingWithPrice({
    required String id,
    required String portfolioId,
    required String symbol,
    required String name,
    required AssetType assetType,
    required double shares,
    required double avgBuyPrice,
    double? manualPrice,
    required String platform,
    required String currency,
    required double currentPrice,
    required double change,
    required double changePercent,
    String? priceUpdatedAt,
    required double marketValue,
    required double costBasis,
    required double profitLoss,
    required double profitLossPercent,
  }) = _HoldingWithPrice;

  factory HoldingWithPrice.fromJson(Map<String, dynamic> json) =>
      _$HoldingWithPriceFromJson(json);
}

@freezed
class CreateHoldingInput with _$CreateHoldingInput {
  const factory CreateHoldingInput({
    required String symbol,
    required String name,
    required AssetType assetType,
    required double shares,
    required double avgBuyPrice,
    String? currency,
    String? platform,
  }) = _CreateHoldingInput;

  factory CreateHoldingInput.fromJson(Map<String, dynamic> json) =>
      _$CreateHoldingInputFromJson(json);
}

@freezed
class UpdateHoldingInput with _$UpdateHoldingInput {
  const factory UpdateHoldingInput({
    double? shares,
    double? avgBuyPrice,
    double? manualPrice,
  }) = _UpdateHoldingInput;

  factory UpdateHoldingInput.fromJson(Map<String, dynamic> json) =>
      _$UpdateHoldingInputFromJson(json);
}
