import 'package:freezed_annotation/freezed_annotation.dart';

part 'valuation.freezed.dart';
part 'valuation.g.dart';

@freezed
class ValuationMetrics with _$ValuationMetrics {
  const factory ValuationMetrics({
    required String symbol,
    required String name,
    required double currentPrice,
    double? peRatio,
    double? forwardPE,
    double? pegRatio,
    double? priceToBook,
    double? priceToSales,
    double? eps,
    double? bookValuePerShare,
    double? revenuePerShare,
    double? grahamNumber,
    double? dcfValue,
    double? upside,
    String? verdict,
  }) = _ValuationMetrics;

  factory ValuationMetrics.fromJson(Map<String, dynamic> json) =>
      _$ValuationMetricsFromJson(json);
}
