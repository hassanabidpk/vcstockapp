// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CryptoQuoteImpl _$$CryptoQuoteImplFromJson(Map<String, dynamic> json) =>
    _$CryptoQuoteImpl(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      changePercent24h: (json['changePercent24h'] as num).toDouble(),
      marketCap: (json['marketCap'] as num).toDouble(),
    );

Map<String, dynamic> _$$CryptoQuoteImplToJson(_$CryptoQuoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'price': instance.price,
      'change24h': instance.change24h,
      'changePercent24h': instance.changePercent24h,
      'marketCap': instance.marketCap,
    };

_$CryptoSearchResultImpl _$$CryptoSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$CryptoSearchResultImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      marketCapRank: (json['marketCapRank'] as num?)?.toInt(),
      thumb: json['thumb'] as String,
    );

Map<String, dynamic> _$$CryptoSearchResultImplToJson(
        _$CryptoSearchResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'symbol': instance.symbol,
      'marketCapRank': instance.marketCapRank,
      'thumb': instance.thumb,
    };
