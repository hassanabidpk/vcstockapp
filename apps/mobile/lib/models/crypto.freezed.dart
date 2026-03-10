// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crypto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CryptoQuote _$CryptoQuoteFromJson(Map<String, dynamic> json) {
  return _CryptoQuote.fromJson(json);
}

/// @nodoc
mixin _$CryptoQuote {
  String get id => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get change24h => throw _privateConstructorUsedError;
  double get changePercent24h => throw _privateConstructorUsedError;
  double get marketCap => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CryptoQuoteCopyWith<CryptoQuote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CryptoQuoteCopyWith<$Res> {
  factory $CryptoQuoteCopyWith(
          CryptoQuote value, $Res Function(CryptoQuote) then) =
      _$CryptoQuoteCopyWithImpl<$Res, CryptoQuote>;
  @useResult
  $Res call(
      {String id,
      String symbol,
      String name,
      double price,
      double change24h,
      double changePercent24h,
      double marketCap});
}

/// @nodoc
class _$CryptoQuoteCopyWithImpl<$Res, $Val extends CryptoQuote>
    implements $CryptoQuoteCopyWith<$Res> {
  _$CryptoQuoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? name = null,
    Object? price = null,
    Object? change24h = null,
    Object? changePercent24h = null,
    Object? marketCap = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      change24h: null == change24h
          ? _value.change24h
          : change24h // ignore: cast_nullable_to_non_nullable
              as double,
      changePercent24h: null == changePercent24h
          ? _value.changePercent24h
          : changePercent24h // ignore: cast_nullable_to_non_nullable
              as double,
      marketCap: null == marketCap
          ? _value.marketCap
          : marketCap // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CryptoQuoteImplCopyWith<$Res>
    implements $CryptoQuoteCopyWith<$Res> {
  factory _$$CryptoQuoteImplCopyWith(
          _$CryptoQuoteImpl value, $Res Function(_$CryptoQuoteImpl) then) =
      __$$CryptoQuoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String symbol,
      String name,
      double price,
      double change24h,
      double changePercent24h,
      double marketCap});
}

/// @nodoc
class __$$CryptoQuoteImplCopyWithImpl<$Res>
    extends _$CryptoQuoteCopyWithImpl<$Res, _$CryptoQuoteImpl>
    implements _$$CryptoQuoteImplCopyWith<$Res> {
  __$$CryptoQuoteImplCopyWithImpl(
      _$CryptoQuoteImpl _value, $Res Function(_$CryptoQuoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? name = null,
    Object? price = null,
    Object? change24h = null,
    Object? changePercent24h = null,
    Object? marketCap = null,
  }) {
    return _then(_$CryptoQuoteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      change24h: null == change24h
          ? _value.change24h
          : change24h // ignore: cast_nullable_to_non_nullable
              as double,
      changePercent24h: null == changePercent24h
          ? _value.changePercent24h
          : changePercent24h // ignore: cast_nullable_to_non_nullable
              as double,
      marketCap: null == marketCap
          ? _value.marketCap
          : marketCap // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CryptoQuoteImpl implements _CryptoQuote {
  const _$CryptoQuoteImpl(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.price,
      required this.change24h,
      required this.changePercent24h,
      required this.marketCap});

  factory _$CryptoQuoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CryptoQuoteImplFromJson(json);

  @override
  final String id;
  @override
  final String symbol;
  @override
  final String name;
  @override
  final double price;
  @override
  final double change24h;
  @override
  final double changePercent24h;
  @override
  final double marketCap;

  @override
  String toString() {
    return 'CryptoQuote(id: $id, symbol: $symbol, name: $name, price: $price, change24h: $change24h, changePercent24h: $changePercent24h, marketCap: $marketCap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CryptoQuoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.change24h, change24h) ||
                other.change24h == change24h) &&
            (identical(other.changePercent24h, changePercent24h) ||
                other.changePercent24h == changePercent24h) &&
            (identical(other.marketCap, marketCap) ||
                other.marketCap == marketCap));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, symbol, name, price,
      change24h, changePercent24h, marketCap);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CryptoQuoteImplCopyWith<_$CryptoQuoteImpl> get copyWith =>
      __$$CryptoQuoteImplCopyWithImpl<_$CryptoQuoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CryptoQuoteImplToJson(
      this,
    );
  }
}

abstract class _CryptoQuote implements CryptoQuote {
  const factory _CryptoQuote(
      {required final String id,
      required final String symbol,
      required final String name,
      required final double price,
      required final double change24h,
      required final double changePercent24h,
      required final double marketCap}) = _$CryptoQuoteImpl;

  factory _CryptoQuote.fromJson(Map<String, dynamic> json) =
      _$CryptoQuoteImpl.fromJson;

  @override
  String get id;
  @override
  String get symbol;
  @override
  String get name;
  @override
  double get price;
  @override
  double get change24h;
  @override
  double get changePercent24h;
  @override
  double get marketCap;
  @override
  @JsonKey(ignore: true)
  _$$CryptoQuoteImplCopyWith<_$CryptoQuoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CryptoSearchResult _$CryptoSearchResultFromJson(Map<String, dynamic> json) {
  return _CryptoSearchResult.fromJson(json);
}

/// @nodoc
mixin _$CryptoSearchResult {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  int? get marketCapRank => throw _privateConstructorUsedError;
  String get thumb => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CryptoSearchResultCopyWith<CryptoSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CryptoSearchResultCopyWith<$Res> {
  factory $CryptoSearchResultCopyWith(
          CryptoSearchResult value, $Res Function(CryptoSearchResult) then) =
      _$CryptoSearchResultCopyWithImpl<$Res, CryptoSearchResult>;
  @useResult
  $Res call(
      {String id,
      String name,
      String symbol,
      int? marketCapRank,
      String thumb});
}

/// @nodoc
class _$CryptoSearchResultCopyWithImpl<$Res, $Val extends CryptoSearchResult>
    implements $CryptoSearchResultCopyWith<$Res> {
  _$CryptoSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? symbol = null,
    Object? marketCapRank = freezed,
    Object? thumb = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      marketCapRank: freezed == marketCapRank
          ? _value.marketCapRank
          : marketCapRank // ignore: cast_nullable_to_non_nullable
              as int?,
      thumb: null == thumb
          ? _value.thumb
          : thumb // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CryptoSearchResultImplCopyWith<$Res>
    implements $CryptoSearchResultCopyWith<$Res> {
  factory _$$CryptoSearchResultImplCopyWith(_$CryptoSearchResultImpl value,
          $Res Function(_$CryptoSearchResultImpl) then) =
      __$$CryptoSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String symbol,
      int? marketCapRank,
      String thumb});
}

/// @nodoc
class __$$CryptoSearchResultImplCopyWithImpl<$Res>
    extends _$CryptoSearchResultCopyWithImpl<$Res, _$CryptoSearchResultImpl>
    implements _$$CryptoSearchResultImplCopyWith<$Res> {
  __$$CryptoSearchResultImplCopyWithImpl(_$CryptoSearchResultImpl _value,
      $Res Function(_$CryptoSearchResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? symbol = null,
    Object? marketCapRank = freezed,
    Object? thumb = null,
  }) {
    return _then(_$CryptoSearchResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      marketCapRank: freezed == marketCapRank
          ? _value.marketCapRank
          : marketCapRank // ignore: cast_nullable_to_non_nullable
              as int?,
      thumb: null == thumb
          ? _value.thumb
          : thumb // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CryptoSearchResultImpl implements _CryptoSearchResult {
  const _$CryptoSearchResultImpl(
      {required this.id,
      required this.name,
      required this.symbol,
      this.marketCapRank,
      required this.thumb});

  factory _$CryptoSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CryptoSearchResultImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String symbol;
  @override
  final int? marketCapRank;
  @override
  final String thumb;

  @override
  String toString() {
    return 'CryptoSearchResult(id: $id, name: $name, symbol: $symbol, marketCapRank: $marketCapRank, thumb: $thumb)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CryptoSearchResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.marketCapRank, marketCapRank) ||
                other.marketCapRank == marketCapRank) &&
            (identical(other.thumb, thumb) || other.thumb == thumb));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, symbol, marketCapRank, thumb);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CryptoSearchResultImplCopyWith<_$CryptoSearchResultImpl> get copyWith =>
      __$$CryptoSearchResultImplCopyWithImpl<_$CryptoSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CryptoSearchResultImplToJson(
      this,
    );
  }
}

abstract class _CryptoSearchResult implements CryptoSearchResult {
  const factory _CryptoSearchResult(
      {required final String id,
      required final String name,
      required final String symbol,
      final int? marketCapRank,
      required final String thumb}) = _$CryptoSearchResultImpl;

  factory _CryptoSearchResult.fromJson(Map<String, dynamic> json) =
      _$CryptoSearchResultImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get symbol;
  @override
  int? get marketCapRank;
  @override
  String get thumb;
  @override
  @JsonKey(ignore: true)
  _$$CryptoSearchResultImplCopyWith<_$CryptoSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
