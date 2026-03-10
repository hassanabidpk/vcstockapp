// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PortfolioSnapshot _$PortfolioSnapshotFromJson(Map<String, dynamic> json) {
  return _PortfolioSnapshot.fromJson(json);
}

/// @nodoc
mixin _$PortfolioSnapshot {
  String get date => throw _privateConstructorUsedError;
  double get totalValue => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;
  double get totalPL => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PortfolioSnapshotCopyWith<PortfolioSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioSnapshotCopyWith<$Res> {
  factory $PortfolioSnapshotCopyWith(
          PortfolioSnapshot value, $Res Function(PortfolioSnapshot) then) =
      _$PortfolioSnapshotCopyWithImpl<$Res, PortfolioSnapshot>;
  @useResult
  $Res call({String date, double totalValue, double totalCost, double totalPL});
}

/// @nodoc
class _$PortfolioSnapshotCopyWithImpl<$Res, $Val extends PortfolioSnapshot>
    implements $PortfolioSnapshotCopyWith<$Res> {
  _$PortfolioSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PortfolioSnapshotImplCopyWith<$Res>
    implements $PortfolioSnapshotCopyWith<$Res> {
  factory _$$PortfolioSnapshotImplCopyWith(_$PortfolioSnapshotImpl value,
          $Res Function(_$PortfolioSnapshotImpl) then) =
      __$$PortfolioSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, double totalValue, double totalCost, double totalPL});
}

/// @nodoc
class __$$PortfolioSnapshotImplCopyWithImpl<$Res>
    extends _$PortfolioSnapshotCopyWithImpl<$Res, _$PortfolioSnapshotImpl>
    implements _$$PortfolioSnapshotImplCopyWith<$Res> {
  __$$PortfolioSnapshotImplCopyWithImpl(_$PortfolioSnapshotImpl _value,
      $Res Function(_$PortfolioSnapshotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalValue = null,
    Object? totalCost = null,
    Object? totalPL = null,
  }) {
    return _then(_$PortfolioSnapshotImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PortfolioSnapshotImpl implements _PortfolioSnapshot {
  const _$PortfolioSnapshotImpl(
      {required this.date,
      required this.totalValue,
      required this.totalCost,
      required this.totalPL});

  factory _$PortfolioSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortfolioSnapshotImplFromJson(json);

  @override
  final String date;
  @override
  final double totalValue;
  @override
  final double totalCost;
  @override
  final double totalPL;

  @override
  String toString() {
    return 'PortfolioSnapshot(date: $date, totalValue: $totalValue, totalCost: $totalCost, totalPL: $totalPL)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioSnapshotImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.totalPL, totalPL) || other.totalPL == totalPL));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, totalValue, totalCost, totalPL);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioSnapshotImplCopyWith<_$PortfolioSnapshotImpl> get copyWith =>
      __$$PortfolioSnapshotImplCopyWithImpl<_$PortfolioSnapshotImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PortfolioSnapshotImplToJson(
      this,
    );
  }
}

abstract class _PortfolioSnapshot implements PortfolioSnapshot {
  const factory _PortfolioSnapshot(
      {required final String date,
      required final double totalValue,
      required final double totalCost,
      required final double totalPL}) = _$PortfolioSnapshotImpl;

  factory _PortfolioSnapshot.fromJson(Map<String, dynamic> json) =
      _$PortfolioSnapshotImpl.fromJson;

  @override
  String get date;
  @override
  double get totalValue;
  @override
  double get totalCost;
  @override
  double get totalPL;
  @override
  @JsonKey(ignore: true)
  _$$PortfolioSnapshotImplCopyWith<_$PortfolioSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
