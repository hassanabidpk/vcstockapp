import 'package:freezed_annotation/freezed_annotation.dart';

part 'crypto.freezed.dart';
part 'crypto.g.dart';

@freezed
class CryptoQuote with _$CryptoQuote {
  const factory CryptoQuote({
    required String id,
    required String symbol,
    required String name,
    required double price,
    required double change24h,
    required double changePercent24h,
    required double marketCap,
  }) = _CryptoQuote;

  factory CryptoQuote.fromJson(Map<String, dynamic> json) =>
      _$CryptoQuoteFromJson(json);
}

@freezed
class CryptoSearchResult with _$CryptoSearchResult {
  const factory CryptoSearchResult({
    required String id,
    required String name,
    required String symbol,
    int? marketCapRank,
    required String thumb,
  }) = _CryptoSearchResult;

  factory CryptoSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CryptoSearchResultFromJson(json);
}
