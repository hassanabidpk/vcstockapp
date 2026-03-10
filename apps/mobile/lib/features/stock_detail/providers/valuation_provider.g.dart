// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$valuationHash() => r'0640ad96b7b695efba49d516e49304a729385194';

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

/// See also [valuation].
@ProviderFor(valuation)
const valuationProvider = ValuationFamily();

/// See also [valuation].
class ValuationFamily extends Family<AsyncValue<ValuationMetrics>> {
  /// See also [valuation].
  const ValuationFamily();

  /// See also [valuation].
  ValuationProvider call(
    String symbol,
  ) {
    return ValuationProvider(
      symbol,
    );
  }

  @override
  ValuationProvider getProviderOverride(
    covariant ValuationProvider provider,
  ) {
    return call(
      provider.symbol,
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
  String? get name => r'valuationProvider';
}

/// See also [valuation].
class ValuationProvider extends AutoDisposeFutureProvider<ValuationMetrics> {
  /// See also [valuation].
  ValuationProvider(
    String symbol,
  ) : this._internal(
          (ref) => valuation(
            ref as ValuationRef,
            symbol,
          ),
          from: valuationProvider,
          name: r'valuationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$valuationHash,
          dependencies: ValuationFamily._dependencies,
          allTransitiveDependencies: ValuationFamily._allTransitiveDependencies,
          symbol: symbol,
        );

  ValuationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
  }) : super.internal();

  final String symbol;

  @override
  Override overrideWith(
    FutureOr<ValuationMetrics> Function(ValuationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ValuationProvider._internal(
        (ref) => create(ref as ValuationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ValuationMetrics> createElement() {
    return _ValuationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ValuationProvider && other.symbol == symbol;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ValuationRef on AutoDisposeFutureProviderRef<ValuationMetrics> {
  /// The parameter `symbol` of this provider.
  String get symbol;
}

class _ValuationProviderElement
    extends AutoDisposeFutureProviderElement<ValuationMetrics>
    with ValuationRef {
  _ValuationProviderElement(super.provider);

  @override
  String get symbol => (origin as ValuationProvider).symbol;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
