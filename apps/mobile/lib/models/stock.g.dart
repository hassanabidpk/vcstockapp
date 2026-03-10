// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockQuoteImpl _$$StockQuoteImplFromJson(Map<String, dynamic> json) =>
    _$StockQuoteImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      dayHigh: (json['dayHigh'] as num).toDouble(),
      dayLow: (json['dayLow'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      marketCap: (json['marketCap'] as num).toDouble(),
      pe: (json['pe'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      exchange: json['exchange'] as String,
    );

Map<String, dynamic> _$$StockQuoteImplToJson(_$StockQuoteImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'price': instance.price,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'dayHigh': instance.dayHigh,
      'dayLow': instance.dayLow,
      'volume': instance.volume,
      'marketCap': instance.marketCap,
      'pe': instance.pe,
      'eps': instance.eps,
      'exchange': instance.exchange,
    };

_$StockSearchResultImpl _$$StockSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$StockSearchResultImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      exchange: json['exchange'] as String,
      exchangeShortName: json['exchangeShortName'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$StockSearchResultImplToJson(
        _$StockSearchResultImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'exchange': instance.exchange,
      'exchangeShortName': instance.exchangeShortName,
      'type': instance.type,
    };

_$HistoricalPriceImpl _$$HistoricalPriceImplFromJson(
        Map<String, dynamic> json) =>
    _$HistoricalPriceImpl(
      date: json['date'] as String,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );

Map<String, dynamic> _$$HistoricalPriceImplToJson(
        _$HistoricalPriceImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
    };
