// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockSearchResultsHash() =>
    r'af913bb99934de4c67970c8a5aac758d8860403e';

/// See also [stockSearchResults].
@ProviderFor(stockSearchResults)
final stockSearchResultsProvider =
    AutoDisposeFutureProvider<List<StockSearchResult>>.internal(
  stockSearchResults,
  name: r'stockSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StockSearchResultsRef
    = AutoDisposeFutureProviderRef<List<StockSearchResult>>;
String _$stockSearchQueryHash() => r'73f2927ae0bae4e0c8d1a3401c8dc401b0bffef7';

/// See also [StockSearchQuery].
@ProviderFor(StockSearchQuery)
final stockSearchQueryProvider =
    AutoDisposeNotifierProvider<StockSearchQuery, String>.internal(
  StockSearchQuery.new,
  name: r'stockSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stockSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StockSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
