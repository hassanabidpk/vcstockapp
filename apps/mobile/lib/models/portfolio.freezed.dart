// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PortfolioInfo _$PortfolioInfoFromJson(Map<String, dynamic> json) {
  return _PortfolioInfo.fromJson(json);
}

/// @nodoc
mixin _$PortfolioInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PortfolioInfoCopyWith<PortfolioInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioInfoCopyWith<$Res> {
  factory $PortfolioInfoCopyWith(
          PortfolioInfo value, $Res Function(PortfolioInfo) then) =
      _$PortfolioInfoCopyWithImpl<$Res, PortfolioInfo>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$PortfolioInfoCopyWithImpl<$Res, $Val extends PortfolioInfo>
    implements $PortfolioInfoCopyWith<$Res> {
  _$PortfolioInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PortfolioInfoImplCopyWith<$Res>
    implements $PortfolioInfoCopyWith<$Res> {
  factory _$$PortfolioInfoImplCopyWith(
          _$PortfolioInfoImpl value, $Res Function(_$PortfolioInfoImpl) then) =
      __$$PortfolioInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$PortfolioInfoImplCopyWithImpl<$Res>
    extends _$PortfolioInfoCopyWithImpl<$Res, _$PortfolioInfoImpl>
    implements _$$PortfolioInfoImplCopyWith<$Res> {
  __$$PortfolioInfoImplCopyWithImpl(
      _$PortfolioInfoImpl _value, $Res Function(_$PortfolioInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$PortfolioInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioInfoImpl implements _PortfolioInfo {
  const _$PortfolioInfoImpl({required this.id, required this.name});

  factory _$PortfolioInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'PortfolioInfo(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioInfoImplCopyWith<_$PortfolioInfoImpl> get copyWith =>
      __$$PortfolioInfoImplCopyWithImpl<_$PortfolioInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioInfoImplToJson(
      this,
    );
  }
}

abstract class _PortfolioInfo implements PortfolioInfo {
  const factory _PortfolioInfo(
      {required final String id,
      required final String name}) = _$PortfolioInfoImpl;

  factory _PortfolioInfo.fromJson(Map<String, dynamic> json) =
      _$PortfolioInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$PortfolioInfoImplCopyWith<_$PortfolioInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Portfolio _$PortfolioFromJson(Map<String, dynamic> json) {
  return _Portfolio.fromJson(json);
}

/// @nodoc
mixin _$Portfolio {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<HoldingWithPrice> get holdings => throw _privateConstructorUsedError;
  PortfolioSummary get summary => throw _privateConstructorUsedError;
  double? get usdToSgd => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PortfolioCopyWith<Portfolio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioCopyWith<$Res> {
  factory $PortfolioCopyWith(Portfolio value, $Res Function(Portfolio) then) =
      _$PortfolioCopyWithImpl<$Res, Portfolio>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<HoldingWithPrice> holdings,
      PortfolioSummary summary,
      double? usdToSgd});

  $PortfolioSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$PortfolioCopyWithImpl<$Res, $Val extends Portfolio>
    implements $PortfolioCopyWith<$Res> {
  _$PortfolioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? holdings = null,
    Object? summary = null,
    Object? usdToSgd = freezed,
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
      holdings: null == holdings
          ? _value.holdings
          : holdings // ignore: cast_nullable_to_non_nullable
              as List<HoldingWithPrice>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PortfolioSummary,
      usdToSgd: freezed == usdToSgd
          ? _value.usdToSgd
          : usdToSgd // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PortfolioSummaryCopyWith<$Res> get summary {
    return $PortfolioSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PortfolioImplCopyWith<$Res>
    implements $PortfolioCopyWith<$Res> {
  factory _$$PortfolioImplCopyWith(
          _$PortfolioImpl value, $Res Function(_$PortfolioImpl) then) =
      __$$PortfolioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<HoldingWithPrice> holdings,
      PortfolioSummary summary,
      double? usdToSgd});

  @override
  $PortfolioSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$PortfolioImplCopyWithImpl<$Res>
    extends _$PortfolioCopyWithImpl<$Res, _$PortfolioImpl>
    implements _$$PortfolioImplCopyWith<$Res> {
  __$$PortfolioImplCopyWithImpl(
      _$PortfolioImpl _value, $Res Function(_$PortfolioImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? holdings = null,
    Object? summary = null,
    Object? usdToSgd = freezed,
  }) {
    return _then(_$PortfolioImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      holdings: null == holdings
          ? _value._holdings
          : holdings // ignore: cast_nullable_to_non_nullable
              as List<HoldingWithPrice>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PortfolioSummary,
      usdToSgd: freezed == usdToSgd
          ? _value.usdToSgd
          : usdToSgd // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioImpl implements _Portfolio {
  const _$PortfolioImpl(
      {required this.id,
      required this.name,
      required final List<HoldingWithPrice> holdings,
      required this.summary,
      this.usdToSgd})
      : _holdings = holdings;

  factory _$PortfolioImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<HoldingWithPrice> _holdings;
  @override
  List<HoldingWithPrice> get holdings {
    if (_holdings is EqualUnmodifiableListView) return _holdings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_holdings);
  }

  @override
  final PortfolioSummary summary;
  @override
  final double? usdToSgd;

  @override
  String toString() {
    return 'Portfolio(id: $id, name: $name, holdings: $holdings, summary: $summary, usdToSgd: $usdToSgd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._holdings, _holdings) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.usdToSgd, usdToSgd) ||
                other.usdToSgd == usdToSgd));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name,
      const DeepCollectionEquality().hash(_holdings), summary, usdToSgd);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioImplCopyWith<_$PortfolioImpl> get copyWith =>
      __$$PortfolioImplCopyWithImpl<_$PortfolioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioImplToJson(
      this,
    );
  }
}

abstract class _Portfolio implements Portfolio {
  const factory _Portfolio(
      {required final String id,
      required final String name,
      required final List<HoldingWithPrice> holdings,
      required final PortfolioSummary summary,
      final double? usdToSgd}) = _$PortfolioImpl;

  factory _Portfolio.fromJson(Map<String, dynamic> json) =
      _$PortfolioImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<HoldingWithPrice> get holdings;
  @override
  PortfolioSummary get summary;
  @override
  double? get usdToSgd;
  @override
  @JsonKey(ignore: true)
  _$$PortfolioImplCopyWith<_$PortfolioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PortfolioSummary _$PortfolioSummaryFromJson(Map<String, dynamic> json) {
  return _PortfolioSummary.fromJson(json);
}

/// @nodoc
mixin _$PortfolioSummary {
  double get totalValue => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;
  double get totalPL => throw _privateConstructorUsedError;
  double get totalPLPercent => throw _privateConstructorUsedError;
  double get dayChange => throw _privateConstructorUsedError;
  double get dayChangePercent => throw _privateConstructorUsedError;
  Map<String, AssetTypeSummary> get byAssetType =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PortfolioSummaryCopyWith<PortfolioSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioSummaryCopyWith<$Res> {
  factory $PortfolioSummaryCopyWith(
          PortfolioSummary value, $Res Function(PortfolioSummary) then) =
      _$PortfolioSummaryCopyWithImpl<$Res, PortfolioSummary>;
  @useResult
  $Res call(
      {double totalValue,
      double totalCost,
      double totalPL,
      double totalPLPercent,
      double dayChange,
      double dayChangePercent,
      Map<String, AssetTypeSummary> byAssetType});
}

/// @nodoc
class _$PortfolioSummaryCopyWithImpl<$Res, $Val extends PortfolioSummary>
    implements $PortfolioSummaryCopyWith<$Res> {
  _$PortfolioSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
    Object? totalPLPercent = null,
    Object? dayChange = null,
    Object? dayChangePercent = null,
    Object? byAssetType = null,
  }) {
    return _then(_value.copyWith(
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalPL: null == totalPL
          ? _value.totalPL
          : totalPL // ignore: cast_nullable_to_non_nullable
              as double,
      totalPLPercent: null == totalPLPercent
          ? _value.totalPLPercent
          : totalPLPercent // ignore: cast_nullable_to_non_nullable
              as double,
      dayChange: null == dayChange
          ? _value.dayChange
          : dayChange // ignore: cast_nullable_to_non_nullable
              as double,
      dayChangePercent: null == dayChangePercent
          ? _value.dayChangePercent
          : dayChangePercent // ignore: cast_nullable_to_non_nullable
              as double,
      byAssetType: null == byAssetType
          ? _value.byAssetType
          : byAssetType // ignore: cast_nullable_to_non_nullable
              as Map<String, AssetTypeSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PortfolioSummaryImplCopyWith<$Res>
    implements $PortfolioSummaryCopyWith<$Res> {
  factory _$$PortfolioSummaryImplCopyWith(_$PortfolioSummaryImpl value,
          $Res Function(_$PortfolioSummaryImpl) then) =
      __$$PortfolioSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalValue,
      double totalCost,
      double totalPL,
      double totalPLPercent,
      double dayChange,
      double dayChangePercent,
      Map<String, AssetTypeSummary> byAssetType});
}

/// @nodoc
class __$$PortfolioSummaryImplCopyWithImpl<$Res>
    extends _$PortfolioSummaryCopyWithImpl<$Res, _$PortfolioSummaryImpl>
    implements _$$PortfolioSummaryImplCopyWith<$Res> {
  __$$PortfolioSummaryImplCopyWithImpl(_$PortfolioSummaryImpl _value,
      $Res Function(_$PortfolioSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
    Object? totalPLPercent = null,
    Object? dayChange = null,
    Object? dayChangePercent = null,
    Object? byAssetType = null,
  }) {
    return _then(_$PortfolioSummaryImpl(
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalPL: null == totalPL
          ? _value.totalPL
          : totalPL // ignore: cast_nullable_to_non_nullable
              as double,
      totalPLPercent: null == totalPLPercent
          ? _value.totalPLPercent
          : totalPLPercent // ignore: cast_nullable_to_non_nullable
              as double,
      dayChange: null == dayChange
          ? _value.dayChange
          : dayChange // ignore: cast_nullable_to_non_nullable
              as double,
      dayChangePercent: null == dayChangePercent
          ? _value.dayChangePercent
          : dayChangePercent // ignore: cast_nullable_to_non_nullable
              as double,
      byAssetType: null == byAssetType
          ? _value._byAssetType
          : byAssetType // ignore: cast_nullable_to_non_nullable
              as Map<String, AssetTypeSummary>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioSummaryImpl implements _PortfolioSummary {
  const _$PortfolioSummaryImpl(
      {required this.totalValue,
      required this.totalCost,
      required this.totalPL,
      required this.totalPLPercent,
      required this.dayChange,
      required this.dayChangePercent,
      required final Map<String, AssetTypeSummary> byAssetType})
      : _byAssetType = byAssetType;

  factory _$PortfolioSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioSummaryImplFromJson(json);

  @override
  final double totalValue;
  @override
  final double totalCost;
  @override
  final double totalPL;
  @override
  final double totalPLPercent;
  @override
  final double dayChange;
  @override
  final double dayChangePercent;
  final Map<String, AssetTypeSummary> _byAssetType;
  @override
  Map<String, AssetTypeSummary> get byAssetType {
    if (_byAssetType is EqualUnmodifiableMapView) return _byAssetType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byAssetType);
  }

  @override
  String toString() {
    return 'PortfolioSummary(totalValue: $totalValue, totalCost: $totalCost, totalPL: $totalPL, totalPLPercent: $totalPLPercent, dayChange: $dayChange, dayChangePercent: $dayChangePercent, byAssetType: $byAssetType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioSummaryImpl &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.totalPL, totalPL) || other.totalPL == totalPL) &&
            (identical(other.totalPLPercent, totalPLPercent) ||
                other.totalPLPercent == totalPLPercent) &&
            (identical(other.dayChange, dayChange) ||
                other.dayChange == dayChange) &&
            (identical(other.dayChangePercent, dayChangePercent) ||
                other.dayChangePercent == dayChangePercent) &&
            const DeepCollectionEquality()
                .equals(other._byAssetType, _byAssetType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalValue,
      totalCost,
      totalPL,
      totalPLPercent,
      dayChange,
      dayChangePercent,
      const DeepCollectionEquality().hash(_byAssetType));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioSummaryImplCopyWith<_$PortfolioSummaryImpl> get copyWith =>
      __$$PortfolioSummaryImplCopyWithImpl<_$PortfolioSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioSummaryImplToJson(
      this,
    );
  }
}

abstract class _PortfolioSummary implements PortfolioSummary {
  const factory _PortfolioSummary(
          {required final double totalValue,
          required final double totalCost,
          required final double totalPL,
          required final double totalPLPercent,
          required final double dayChange,
          required final double dayChangePercent,
          required final Map<String, AssetTypeSummary> byAssetType}) =
      _$PortfolioSummaryImpl;

  factory _PortfolioSummary.fromJson(Map<String, dynamic> json) =
      _$PortfolioSummaryImpl.fromJson;

  @override
  double get totalValue;
  @override
  double get totalCost;
  @override
  double get totalPL;
  @override
  double get totalPLPercent;
  @override
  double get dayChange;
  @override
  double get dayChangePercent;
  @override
  Map<String, AssetTypeSummary> get byAssetType;
  @override
  @JsonKey(ignore: true)
  _$$PortfolioSummaryImplCopyWith<_$PortfolioSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssetTypeSummary _$AssetTypeSummaryFromJson(Map<String, dynamic> json) {
  return _AssetTypeSummary.fromJson(json);
}

/// @nodoc
mixin _$AssetTypeSummary {
  double get totalValue => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;
  double get totalPL => throw _privateConstructorUsedError;
  double get totalPLPercent => throw _privateConstructorUsedError;
  List<HoldingWithPrice> get holdings => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssetTypeSummaryCopyWith<AssetTypeSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetTypeSummaryCopyWith<$Res> {
  factory $AssetTypeSummaryCopyWith(
          AssetTypeSummary value, $Res Function(AssetTypeSummary) then) =
      _$AssetTypeSummaryCopyWithImpl<$Res, AssetTypeSummary>;
  @useResult
  $Res call(
      {double totalValue,
      double totalCost,
      double totalPL,
      double totalPLPercent,
      List<HoldingWithPrice> holdings});
}

/// @nodoc
class _$AssetTypeSummaryCopyWithImpl<$Res, $Val extends AssetTypeSummary>
    implements $AssetTypeSummaryCopyWith<$Res> {
  _$AssetTypeSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
    Object? totalPLPercent = null,
    Object? holdings = null,
  }) {
    return _then(_value.copyWith(
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalPL: null == totalPL
          ? _value.totalPL
          : totalPL // ignore: cast_nullable_to_non_nullable
              as double,
      totalPLPercent: null == totalPLPercent
          ? _value.totalPLPercent
          : totalPLPercent // ignore: cast_nullable_to_non_nullable
              as double,
      holdings: null == holdings
          ? _value.holdings
          : holdings // ignore: cast_nullable_to_non_nullable
              as List<HoldingWithPrice>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssetTypeSummaryImplCopyWith<$Res>
    implements $AssetTypeSummaryCopyWith<$Res> {
  factory _$$AssetTypeSummaryImplCopyWith(_$AssetTypeSummaryImpl value,
          $Res Function(_$AssetTypeSummaryImpl) then) =
      __$$AssetTypeSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalValue,
      double totalCost,
      double totalPL,
      double totalPLPercent,
      List<HoldingWithPrice> holdings});
}

/// @nodoc
class __$$AssetTypeSummaryImplCopyWithImpl<$Res>
    extends _$AssetTypeSummaryCopyWithImpl<$Res, _$AssetTypeSummaryImpl>
    implements _$$AssetTypeSummaryImplCopyWith<$Res> {
  __$$AssetTypeSummaryImplCopyWithImpl(_$AssetTypeSummaryImpl _value,
      $Res Function(_$AssetTypeSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
    Object? totalPLPercent = null,
    Object? holdings = null,
  }) {
    return _then(_$AssetTypeSummaryImpl(
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _value.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalPL: null == totalPL
          ? _value.totalPL
          : totalPL // ignore: cast_nullable_to_non_nullable
              as double,
      totalPLPercent: null == totalPLPercent
          ? _value.totalPLPercent
          : totalPLPercent // ignore: cast_nullable_to_non_nullable
              as double,
      holdings: null == holdings
          ? _value._holdings
          : holdings // ignore: cast_nullable_to_non_nullable
              as List<HoldingWithPrice>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssetTypeSummaryImpl implements _AssetTypeSummary {
  const _$AssetTypeSummaryImpl(
      {required this.totalValue,
      required this.totalCost,
      required this.totalPL,
      required this.totalPLPercent,
      required final List<HoldingWithPrice> holdings})
      : _holdings = holdings;

  factory _$AssetTypeSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssetTypeSummaryImplFromJson(json);

  @override
  final double totalValue;
  @override
  final double totalCost;
  @override
  final double totalPL;
  @override
  final double totalPLPercent;
  final List<HoldingWithPrice> _holdings;
  @override
  List<HoldingWithPrice> get holdings {
    if (_holdings is EqualUnmodifiableListView) return _holdings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_holdings);
  }

  @override
  String toString() {
    return 'AssetTypeSummary(totalValue: $totalValue, totalCost: $totalCost, totalPL: $totalPL, totalPLPercent: $totalPLPercent, holdings: $holdings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetTypeSummaryImpl &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.totalPL, totalPL) || other.totalPL == totalPL) &&
            (identical(other.totalPLPercent, totalPLPercent) ||
                other.totalPLPercent == totalPLPercent) &&
            const DeepCollectionEquality().equals(other._holdings, _holdings));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalValue, totalCost, totalPL,
      totalPLPercent, const DeepCollectionEquality().hash(_holdings));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetTypeSummaryImplCopyWith<_$AssetTypeSummaryImpl> get copyWith =>
      __$$AssetTypeSummaryImplCopyWithImpl<_$AssetTypeSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssetTypeSummaryImplToJson(
      this,
    );
  }
}

abstract class _AssetTypeSummary implements AssetTypeSummary {
  const factory _AssetTypeSummary(
      {required final double totalValue,
      required final double totalCost,
      required final double totalPL,
      required final double totalPLPercent,
      required final List<HoldingWithPrice> holdings}) = _$AssetTypeSummaryImpl;

  factory _AssetTypeSummary.fromJson(Map<String, dynamic> json) =
      _$AssetTypeSummaryImpl.fromJson;

  @override
  double get totalValue;
  @override
  double get totalCost;
  @override
  double get totalPL;
  @override
  double get totalPLPercent;
  @override
  List<HoldingWithPrice> get holdings;
  @override
  @JsonKey(ignore: true)
  _$$AssetTypeSummaryImplCopyWith<_$AssetTypeSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
