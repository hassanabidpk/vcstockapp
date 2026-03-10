// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockHistoryHash() => r'd5950dd053225d3368387bb24dc2db816f27b549';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [stockHistory].
@ProviderFor(stockHistory)
const stockHistoryProvider = StockHistoryFamily();

/// See also [stockHistory].
class StockHistoryFamily extends Family<AsyncValue<List<HistoricalPrice>>> {
  /// See also [stockHistory].
  const StockHistoryFamily();

  /// See also [stockHistory].
  StockHistoryProvider call(
    String symbol, {
    String range = '1M',
  }) {
    return StockHistoryProvider(
      symbol,
      range: range,
    );
  }

  @override
  StockHistoryProvider getProviderOverride(
    covariant StockHistoryProvider provider,
  ) {
    return call(
      provider.symbol,
      range: provider.range,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stockHistoryProvider';
}

/// See also [stockHistory].
class StockHistoryProvider
    extends AutoDisposeFutureProvider<List<HistoricalPrice>> {
  /// See also [stockHistory].
  StockHistoryProvider(
    String symbol, {
    String range = '1M',
  }) : this._internal(
          (ref) => stockHistory(
            ref as StockHistoryRef,
            symbol,
            range: range,
          ),
          from: stockHistoryProvider,
          name: r'stockHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stockHistoryHash,
          dependencies: StockHistoryFamily._dependencies,
          allTransitiveDependencies:
              StockHistoryFamily._allTransitiveDependencies,
          symbol: symbol,
          range: range,
        );

  StockHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.range,
  }) : super.internal();

  final String symbol;
  final String range;

  @override
  Override overrideWith(
    FutureOr<List<HistoricalPrice>> Function(StockHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StockHistoryProvider._internal(
        (ref) => create(ref as StockHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HistoricalPrice>> createElement() {
    return _StockHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockHistoryProvider &&
        other.symbol == symbol &&
        other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StockHistoryRef on AutoDisposeFutureProviderRef<List<HistoricalPrice>> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `range` of this provider.
  String get range;
}

class _StockHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<HistoricalPrice>>
    with StockHistoryRef {
  _StockHistoryProviderElement(super.provider);

  @override
  String get symbol => (origin as StockHistoryProvider).symbol;
  @override
  String get range => (origin as StockHistoryProvider).range;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
