// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cryptoHistoryHash() => r'2171149ea156e6400cf123cd36f78fd08a9d1adf';

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

/// See also [cryptoHistory].
@ProviderFor(cryptoHistory)
const cryptoHistoryProvider = CryptoHistoryFamily();

/// See also [cryptoHistory].
class CryptoHistoryFamily extends Family<AsyncValue<List<HistoricalPrice>>> {
  /// See also [cryptoHistory].
  const CryptoHistoryFamily();

  /// See also [cryptoHistory].
  CryptoHistoryProvider call(
    String coinId, {
    String range = '1M',
  }) {
    return CryptoHistoryProvider(
      coinId,
      range: range,
    );
  }

  @override
  CryptoHistoryProvider getProviderOverride(
    covariant CryptoHistoryProvider provider,
  ) {
    return call(
      provider.coinId,
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
  String? get name => r'cryptoHistoryProvider';
}

/// See also [cryptoHistory].
class CryptoHistoryProvider
    extends AutoDisposeFutureProvider<List<HistoricalPrice>> {
  /// See also [cryptoHistory].
  CryptoHistoryProvider(
    String coinId, {
    String range = '1M',
  }) : this._internal(
          (ref) => cryptoHistory(
            ref as CryptoHistoryRef,
            coinId,
            range: range,
          ),
          from: cryptoHistoryProvider,
          name: r'cryptoHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cryptoHistoryHash,
          dependencies: CryptoHistoryFamily._dependencies,
          allTransitiveDependencies:
              CryptoHistoryFamily._allTransitiveDependencies,
          coinId: coinId,
          range: range,
        );

  CryptoHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coinId,
    required this.range,
  }) : super.internal();

  final String coinId;
  final String range;

  @override
  Override overrideWith(
    FutureOr<List<HistoricalPrice>> Function(CryptoHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CryptoHistoryProvider._internal(
        (ref) => create(ref as CryptoHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coinId: coinId,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HistoricalPrice>> createElement() {
    return _CryptoHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CryptoHistoryProvider &&
        other.coinId == coinId &&
        other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coinId.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CryptoHistoryRef on AutoDisposeFutureProviderRef<List<HistoricalPrice>> {
  /// The parameter `coinId` of this provider.
  String get coinId;

  /// The parameter `range` of this provider.
  String get range;
}

class _CryptoHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<HistoricalPrice>>
    with CryptoHistoryRef {
  _CryptoHistoryProviderElement(super.provider);

  @override
  String get coinId => (origin as CryptoHistoryProvider).coinId;
  @override
  String get range => (origin as CryptoHistoryProvider).range;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
