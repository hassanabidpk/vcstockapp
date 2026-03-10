import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

part 'portfolio.freezed.dart';
part 'portfolio.g.dart';

@freezed
class PortfolioInfo with _$PortfolioInfo {
  const factory PortfolioInfo({
    required String id,
    required String name,
  }) = _PortfolioInfo;

  factory PortfolioInfo.fromJson(Map<String, dynamic> json) =>
      _$PortfolioInfoFromJson(json);
}

@freezed
class Portfolio with _$Portfolio {
  const factory Portfolio({
    required String id,
    required String name,
    required List<HoldingWithPrice> holdings,
    required PortfolioSummary summary,
    double? usdToSgd,
  }) = _Portfolio;

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);
}

@freezed
class PortfolioSummary with _$PortfolioSummary {
  const factory PortfolioSummary({
    required double totalValue,
    required double totalCost,
    required double totalPL,
    required double totalPLPercent,
    required double dayChange,
    required double dayChangePercent,
    required Map<String, AssetTypeSummary> byAssetType,
  }) = _PortfolioSummary;

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSummaryFromJson(json);
}

@freezed
class AssetTypeSummary with _$AssetTypeSummary {
  const factory AssetTypeSummary({
    required double totalValue,
    required double totalCost,
    required double totalPL,
    required double totalPLPercent,
    required List<HoldingWithPrice> holdings,
  }) = _AssetTypeSummary;

  factory AssetTypeSummary.fromJson(Map<String, dynamic> json) =>
      _$AssetTypeSummaryFromJson(json);
}
