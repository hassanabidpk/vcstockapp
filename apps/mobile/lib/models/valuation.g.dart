// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValuationMetricsImpl _$$ValuationMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$ValuationMetricsImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      peRatio: (json['peRatio'] as num?)?.toDouble(),
      forwardPE: (json['forwardPE'] as num?)?.toDouble(),
      pegRatio: (json['pegRatio'] as num?)?.toDouble(),
      priceToBook: (json['priceToBook'] as num?)?.toDouble(),
      priceToSales: (json['priceToSales'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      bookValuePerShare: (json['bookValuePerShare'] as num?)?.toDouble(),
      revenuePerShare: (json['revenuePerShare'] as num?)?.toDouble(),
      grahamNumber: (json['grahamNumber'] as num?)?.toDouble(),
      dcfValue: (json['dcfValue'] as num?)?.toDouble(),
      upside: (json['upside'] as num?)?.toDouble(),
      verdict: json['verdict'] as String?,
    );

Map<String, dynamic> _$$ValuationMetricsImplToJson(
        _$ValuationMetricsImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'peRatio': instance.peRatio,
      'forwardPE': instance.forwardPE,
      'pegRatio': instance.pegRatio,
      'priceToBook': instance.priceToBook,
      'priceToSales': instance.priceToSales,
      'eps': instance.eps,
      'bookValuePerShare': instance.bookValuePerShare,
      'revenuePerShare': instance.revenuePerShare,
      'grahamNumber': instance.grahamNumber,
      'dcfValue': instance.dcfValue,
      'upside': instance.upside,
      'verdict': instance.verdict,
    };
