// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HoldingWithPriceImpl _$$HoldingWithPriceImplFromJson(
        Map<String, dynamic> json) =>
    _$HoldingWithPriceImpl(
      id: json['id'] as String,
      portfolioId: json['portfolioId'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      assetType: $enumDecode(_$AssetTypeEnumMap, json['assetType']),
      shares: (json['shares'] as num).toDouble(),
      avgBuyPrice: (json['avgBuyPrice'] as num).toDouble(),
      manualPrice: (json['manualPrice'] as num?)?.toDouble(),
      platform: json['platform'] as String,
      currency: json['currency'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      priceUpdatedAt: json['priceUpdatedAt'] as String?,
      marketValue: (json['marketValue'] as num).toDouble(),
      costBasis: (json['costBasis'] as num).toDouble(),
      profitLoss: (json['profitLoss'] as num).toDouble(),
      profitLossPercent: (json['profitLossPercent'] as num).toDouble(),
    );

Map<String, dynamic> _$$HoldingWithPriceImplToJson(
        _$HoldingWithPriceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'portfolioId': instance.portfolioId,
      'symbol': instance.symbol,
      'name': instance.name,
      'assetType': _$AssetTypeEnumMap[instance.assetType]!,
      'shares': instance.shares,
      'avgBuyPrice': instance.avgBuyPrice,
      'manualPrice': instance.manualPrice,
      'platform': instance.platform,
      'currency': instance.currency,
      'currentPrice': instance.currentPrice,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priceUpdatedAt': instance.priceUpdatedAt,
      'marketValue': instance.marketValue,
      'costBasis': instance.costBasis,
      'profitLoss': instance.profitLoss,
      'profitLossPercent': instance.profitLossPercent,
    };

const _$AssetTypeEnumMap = {
  AssetType.usStock: 'us_stock',
  AssetType.sgStock: 'sg_stock',
  AssetType.crypto: 'crypto',
};

_$CreateHoldingInputImpl _$$CreateHoldingInputImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateHoldingInputImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      assetType: $enumDecode(_$AssetTypeEnumMap, json['assetType']),
      shares: (json['shares'] as num).toDouble(),
      avgBuyPrice: (json['avgBuyPrice'] as num).toDouble(),
      currency: json['currency'] as String?,
      platform: json['platform'] as String?,
    );

Map<String, dynamic> _$$CreateHoldingInputImplToJson(
        _$CreateHoldingInputImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'assetType': _$AssetTypeEnumMap[instance.assetType]!,
      'shares': instance.shares,
      'avgBuyPrice': instance.avgBuyPrice,
      'currency': instance.currency,
      'platform': instance.platform,
    };

_$UpdateHoldingInputImpl _$$UpdateHoldingInputImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateHoldingInputImpl(
      shares: (json['shares'] as num?)?.toDouble(),
      avgBuyPrice: (json['avgBuyPrice'] as num?)?.toDouble(),
      manualPrice: (json['manualPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$UpdateHoldingInputImplToJson(
        _$UpdateHoldingInputImpl instance) =>
    <String, dynamic>{
      'shares': instance.shares,
      'avgBuyPrice': instance.avgBuyPrice,
      'manualPrice': instance.manualPrice,
    };
