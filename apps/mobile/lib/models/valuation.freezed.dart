// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'valuation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ValuationMetrics _$ValuationMetricsFromJson(Map<String, dynamic> json) {
  return _ValuationMetrics.fromJson(json);
}

/// @nodoc
mixin _$ValuationMetrics {
  String get symbol => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get currentPrice => throw _privateConstructorUsedError;
  double? get peRatio => throw _privateConstructorUsedError;
  double? get forwardPE => throw _privateConstructorUsedError;
  double? get pegRatio => throw _privateConstructorUsedError;
  double? get priceToBook => throw _privateConstructorUsedError;
  double? get priceToSales => throw _privateConstructorUsedError;
  double? get eps => throw _privateConstructorUsedError;
  double? get bookValuePerShare => throw _privateConstructorUsedError;
  double? get revenuePerShare => throw _privateConstructorUsedError;
  double? get grahamNumber => throw _privateConstructorUsedError;
  double? get dcfValue => throw _privateConstructorUsedError;
  double? get upside => throw _privateConstructorUsedError;
  String? get verdict => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValuationMetricsCopyWith<ValuationMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValuationMetricsCopyWith<$Res> {
  factory $ValuationMetricsCopyWith(
          ValuationMetrics value, $Res Function(ValuationMetrics) then) =
      _$ValuationMetricsCopyWithImpl<$Res, ValuationMetrics>;
  @useResult
  $Res call(
      {String symbol,
      String name,
      double currentPrice,
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
      String? verdict});
}

/// @nodoc
class _$ValuationMetricsCopyWithImpl<$Res, $Val extends ValuationMetrics>
    implements $ValuationMetricsCopyWith<$Res> {
  _$ValuationMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? currentPrice = null,
    Object? peRatio = freezed,
    Object? forwardPE = freezed,
    Object? pegRatio = freezed,
    Object? priceToBook = freezed,
    Object? priceToSales = freezed,
    Object? eps = freezed,
    Object? bookValuePerShare = freezed,
    Object? revenuePerShare = freezed,
    Object? grahamNumber = freezed,
    Object? dcfValue = freezed,
    Object? upside = freezed,
    Object? verdict = freezed,
  }) {
    return _then(_value.copyWith(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      peRatio: freezed == peRatio
          ? _value.peRatio
          : peRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      forwardPE: freezed == forwardPE
          ? _value.forwardPE
          : forwardPE // ignore: cast_nullable_to_non_nullable
              as double?,
      pegRatio: freezed == pegRatio
          ? _value.pegRatio
          : pegRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      priceToBook: freezed == priceToBook
          ? _value.priceToBook
          : priceToBook // ignore: cast_nullable_to_non_nullable
              as double?,
      priceToSales: freezed == priceToSales
          ? _value.priceToSales
          : priceToSales // ignore: cast_nullable_to_non_nullable
              as double?,
      eps: freezed == eps
          ? _value.eps
          : eps // ignore: cast_nullable_to_non_nullable
              as double?,
      bookValuePerShare: freezed == bookValuePerShare
          ? _value.bookValuePerShare
          : bookValuePerShare // ignore: cast_nullable_to_non_nullable
              as double?,
      revenuePerShare: freezed == revenuePerShare
          ? _value.revenuePerShare
          : revenuePerShare // ignore: cast_nullable_to_non_nullable
              as double?,
      grahamNumber: freezed == grahamNumber
          ? _value.grahamNumber
          : grahamNumber // ignore: cast_nullable_to_non_nullable
              as double?,
      dcfValue: freezed == dcfValue
          ? _value.dcfValue
          : dcfValue // ignore: cast_nullable_to_non_nullable
              as double?,
      upside: freezed == upside
          ? _value.upside
          : upside // ignore: cast_nullable_to_non_nullable
              as double?,
      verdict: freezed == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValuationMetricsImplCopyWith<$Res>
    implements $ValuationMetricsCopyWith<$Res> {
  factory _$$ValuationMetricsImplCopyWith(_$ValuationMetricsImpl value,
          $Res Function(_$ValuationMetricsImpl) then) =
      __$$ValuationMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String symbol,
      String name,
      double currentPrice,
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
      String? verdict});
}

/// @nodoc
class __$$ValuationMetricsImplCopyWithImpl<$Res>
    extends _$ValuationMetricsCopyWithImpl<$Res, _$ValuationMetricsImpl>
    implements _$$ValuationMetricsImplCopyWith<$Res> {
  __$$ValuationMetricsImplCopyWithImpl(_$ValuationMetricsImpl _value,
      $Res Function(_$ValuationMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? currentPrice = null,
    Object? peRatio = freezed,
    Object? forwardPE = freezed,
    Object? pegRatio = freezed,
    Object? priceToBook = freezed,
    Object? priceToSales = freezed,
    Object? eps = freezed,
    Object? bookValuePerShare = freezed,
    Object? revenuePerShare = freezed,
    Object? grahamNumber = freezed,
    Object? dcfValue = freezed,
    Object? upside = freezed,
    Object? verdict = freezed,
  }) {
    return _then(_$ValuationMetricsImpl(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      peRatio: freezed == peRatio
          ? _value.peRatio
          : peRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      forwardPE: freezed == forwardPE
          ? _value.forwardPE
          : forwardPE // ignore: cast_nullable_to_non_nullable
              as double?,
      pegRatio: freezed == pegRatio
          ? _value.pegRatio
          : pegRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      priceToBook: freezed == priceToBook
          ? _value.priceToBook
          : priceToBook // ignore: cast_nullable_to_non_nullable
              as double?,
      priceToSales: freezed == priceToSales
          ? _value.priceToSales
          : priceToSales // ignore: cast_nullable_to_non_nullable
              as double?,
      eps: freezed == eps
          ? _value.eps
          : eps // ignore: cast_nullable_to_non_nullable
              as double?,
      bookValuePerShare: freezed == bookValuePerShare
          ? _value.bookValuePerShare
          : bookValuePerShare // ignore: cast_nullable_to_non_nullable
              as double?,
      revenuePerShare: freezed == revenuePerShare
          ? _value.revenuePerShare
          : revenuePerShare // ignore: cast_nullable_to_non_nullable
              as double?,
      grahamNumber: freezed == grahamNumber
          ? _value.grahamNumber
          : grahamNumber // ignore: cast_nullable_to_non_nullable
              as double?,
      dcfValue: freezed == dcfValue
          ? _value.dcfValue
          : dcfValue // ignore: cast_nullable_to_non_nullable
              as double?,
      upside: freezed == upside
          ? _value.upside
          : upside // ignore: cast_nullable_to_non_nullable
              as double?,
      verdict: freezed == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValuationMetricsImpl implements _ValuationMetrics {
  const _$ValuationMetricsImpl(
      {required this.symbol,
      required this.name,
      required this.currentPrice,
      this.peRatio,
      this.forwardPE,
      this.pegRatio,
      this.priceToBook,
      this.priceToSales,
      this.eps,
      this.bookValuePerShare,
      this.revenuePerShare,
      this.grahamNumber,
      this.dcfValue,
      this.upside,
      this.verdict});

  factory _$ValuationMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValuationMetricsImplFromJson(json);

  @override
  final String symbol;
  @override
  final String name;
  @override
  final double currentPrice;
  @override
  final double? peRatio;
  @override
  final double? forwardPE;
  @override
  final double? pegRatio;
  @override
  final double? priceToBook;
  @override
  final double? priceToSales;
  @override
  final double? eps;
  @override
  final double? bookValuePerShare;
  @override
  final double? revenuePerShare;
  @override
  final double? grahamNumber;
  @override
  final double? dcfValue;
  @override
  final double? upside;
  @override
  final String? verdict;

  @override
  String toString() {
    return 'ValuationMetrics(symbol: $symbol, name: $name, currentPrice: $currentPrice, peRatio: $peRatio, forwardPE: $forwardPE, pegRatio: $pegRatio, priceToBook: $priceToBook, priceToSales: $priceToSales, eps: $eps, bookValuePerShare: $bookValuePerShare, revenuePerShare: $revenuePerShare, grahamNumber: $grahamNumber, dcfValue: $dcfValue, upside: $upside, verdict: $verdict)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValuationMetricsImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.peRatio, peRatio) || other.peRatio == peRatio) &&
            (identical(other.forwardPE, forwardPE) ||
                other.forwardPE == forwardPE) &&
            (identical(other.pegRatio, pegRatio) ||
                other.pegRatio == pegRatio) &&
            (identical(other.priceToBook, priceToBook) ||
                other.priceToBook == priceToBook) &&
            (identical(other.priceToSales, priceToSales) ||
                other.priceToSales == priceToSales) &&
            (identical(other.eps, eps) || other.eps == eps) &&
            (identical(other.bookValuePerShare, bookValuePerShare) ||
                other.bookValuePerShare == bookValuePerShare) &&
            (identical(other.revenuePerShare, revenuePerShare) ||
                other.revenuePerShare == revenuePerShare) &&
            (identical(other.grahamNumber, grahamNumber) ||
                other.grahamNumber == grahamNumber) &&
            (identical(other.dcfValue, dcfValue) ||
                other.dcfValue == dcfValue) &&
            (identical(other.upside, upside) || other.upside == upside) &&
            (identical(other.verdict, verdict) || other.verdict == verdict));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      symbol,
      name,
      currentPrice,
      peRatio,
      forwardPE,
      pegRatio,
      priceToBook,
      priceToSales,
      eps,
      bookValuePerShare,
      revenuePerShare,
      grahamNumber,
      dcfValue,
      upside,
      verdict);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValuationMetricsImplCopyWith<_$ValuationMetricsImpl> get copyWith =>
      __$$ValuationMetricsImplCopyWithImpl<_$ValuationMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValuationMetricsImplToJson(
      this,
    );
  }
}

abstract class _ValuationMetrics implements ValuationMetrics {
  const factory _ValuationMetrics(
      {required final String symbol,
      required final String name,
      required final double currentPrice,
      final double? peRatio,
      final double? forwardPE,
      final double? pegRatio,
      final double? priceToBook,
      final double? priceToSales,
      final double? eps,
      final double? bookValuePerShare,
      final double? revenuePerShare,
      final double? grahamNumber,
      final double? dcfValue,
      final double? upside,
      final String? verdict}) = _$ValuationMetricsImpl;

  factory _ValuationMetrics.fromJson(Map<String, dynamic> json) =
      _$ValuationMetricsImpl.fromJson;

  @override
  String get symbol;
  @override
  String get name;
  @override
  double get currentPrice;
  @override
  double? get peRatio;
  @override
  double? get forwardPE;
  @override
  double? get pegRatio;
  @override
  double? get priceToBook;
  @override
  double? get priceToSales;
  @override
  double? get eps;
  @override
  double? get bookValuePerShare;
  @override
  double? get revenuePerShare;
  @override
  double? get grahamNumber;
  @override
  double? get dcfValue;
  @override
  double? get upside;
  @override
  String? get verdict;
  @override
  @JsonKey(ignore: true)
  _$$ValuationMetricsImplCopyWith<_$ValuationMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
