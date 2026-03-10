// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$portfolioListHash() => r'8e9f320be53b2589c22ae6b5258ea9f35e9198d2';

/// See also [portfolioList].
@ProviderFor(portfolioList)
final portfolioListProvider =
    AutoDisposeFutureProvider<List<PortfolioInfo>>.internal(
  portfolioList,
  name: r'portfolioListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$portfolioListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PortfolioListRef = AutoDisposeFutureProviderRef<List<PortfolioInfo>>;
String _$selectedPortfolioHash() => r'5b37258670a93e9532fed08d1c0e6a3bb97997f2';

/// See also [SelectedPortfolio].
@ProviderFor(SelectedPortfolio)
final selectedPortfolioProvider =
    NotifierProvider<SelectedPortfolio, String?>.internal(
  SelectedPortfolio.new,
  name: r'selectedPortfolioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPortfolioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedPortfolio = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
