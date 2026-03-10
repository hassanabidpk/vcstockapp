import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock.freezed.dart';
part 'stock.g.dart';

@freezed
class StockQuote with _$StockQuote {
  const factory StockQuote({
    required String symbol,
    required String name,
    required double price,
    required double change,
    required double changePercent,
    required double dayHigh,
    required double dayLow,
    required double volume,
    required double marketCap,
    double? pe,
    double? eps,
    required String exchange,
  }) = _StockQuote;

  factory StockQuote.fromJson(Map<String, dynamic> json) =>
      _$StockQuoteFromJson(json);
}

@freezed
class StockSearchResult with _$StockSearchResult {
  const factory StockSearchResult({
    required String symbol,
    required String name,
    required String exchange,
    required String exchangeShortName,
    required String type,
  }) = _StockSearchResult;

  factory StockSearchResult.fromJson(Map<String, dynamic> json) =>
      _$StockSearchResultFromJson(json);
}

@freezed
class HistoricalPrice with _$HistoricalPrice {
  const factory HistoricalPrice({
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    required double volume,
  }) = _HistoricalPrice;

  factory HistoricalPrice.fromJson(Map<String, dynamic> json) =>
      _$HistoricalPriceFromJson(json);
}
