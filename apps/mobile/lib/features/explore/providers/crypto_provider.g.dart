// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cryptoPricesHash() => r'4f66a45b22911f566fe9305d6051c056a7bde5f2';

/// See also [cryptoPrices].
@ProviderFor(cryptoPrices)
final cryptoPricesProvider =
    AutoDisposeFutureProvider<List<CryptoQuote>>.internal(
  cryptoPrices,
  name: r'cryptoPricesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cryptoPricesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CryptoPricesRef = AutoDisposeFutureProviderRef<List<CryptoQuote>>;
String _$cryptoSearchResultsHash() =>
    r'32435a9afef660d54635e2329993bf726db35da3';

/// See also [cryptoSearchResults].
@ProviderFor(cryptoSearchResults)
final cryptoSearchResultsProvider =
    AutoDisposeFutureProvider<List<CryptoSearchResult>>.internal(
  cryptoSearchResults,
  name: r'cryptoSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cryptoSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CryptoSearchResultsRef
    = AutoDisposeFutureProviderRef<List<CryptoSearchResult>>;
String _$cryptoSearchQueryHash() => r'c598298bff8e1aee4240cb857b67fbb7c0ac0191';

/// See also [CryptoSearchQuery].
@ProviderFor(CryptoSearchQuery)
final cryptoSearchQueryProvider =
    AutoDisposeNotifierProvider<CryptoSearchQuery, String>.internal(
  CryptoSearchQuery.new,
  name: r'cryptoSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cryptoSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CryptoSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
