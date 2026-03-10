// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PortfolioSnapshotImpl _$$PortfolioSnapshotImplFromJson(
        Map<String, dynamic> json) =>
    _$PortfolioSnapshotImpl(
      date: json['date'] as String,
      totalValue: (json['totalValue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalPL: (json['totalPL'] as num).toDouble(),
    );

Map<String, dynamic> _$$PortfolioSnapshotImplToJson(
        _$PortfolioSnapshotImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalValue': instance.totalValue,
      'totalCost': instance.totalCost,
      'totalPL': instance.totalPL,
    };
