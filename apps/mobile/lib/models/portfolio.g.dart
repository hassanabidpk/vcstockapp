// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PortfolioInfoImpl _$$PortfolioInfoImplFromJson(Map<String, dynamic> json) =>
    _$PortfolioInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$PortfolioInfoImplToJson(_$PortfolioInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$PortfolioImpl _$$PortfolioImplFromJson(Map<String, dynamic> json) =>
    _$PortfolioImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => HoldingWithPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          PortfolioSummary.fromJson(json['summary'] as Map<String, dynamic>),
      usdToSgd: (json['usdToSgd'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PortfolioImplToJson(_$PortfolioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'holdings': instance.holdings,
      'summary': instance.summary,
      'usdToSgd': instance.usdToSgd,
    };

_$PortfolioSummaryImpl _$$PortfolioSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$PortfolioSummaryImpl(
      totalValue: (json['totalValue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalPL: (json['totalPL'] as num).toDouble(),
      totalPLPercent: (json['totalPLPercent'] as num).toDouble(),
      dayChange: (json['dayChange'] as num).toDouble(),
      dayChangePercent: (json['dayChangePercent'] as num).toDouble(),
      byAssetType: (json['byAssetType'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, AssetTypeSummary.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$PortfolioSummaryImplToJson(
        _$PortfolioSummaryImpl instance) =>
    <String, dynamic>{
      'totalValue': instance.totalValue,
      'totalCost': instance.totalCost,
      'totalPL': instance.totalPL,
      'totalPLPercent': instance.totalPLPercent,
      'dayChange': instance.dayChange,
      'dayChangePercent': instance.dayChangePercent,
      'byAssetType': instance.byAssetType,
    };

_$AssetTypeSummaryImpl _$$AssetTypeSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$AssetTypeSummaryImpl(
      totalValue: (json['totalValue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalPL: (json['totalPL'] as num).toDouble(),
      totalPLPercent: (json['totalPLPercent'] as num).toDouble(),
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => HoldingWithPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AssetTypeSummaryImplToJson(
        _$AssetTypeSummaryImpl instance) =>
    <String, dynamic>{
      'totalValue': instance.totalValue,
      'totalCost': instance.totalCost,
      'totalPL': instance.totalPL,
      'totalPLPercent': instance.totalPLPercent,
      'holdings': instance.holdings,
    };
