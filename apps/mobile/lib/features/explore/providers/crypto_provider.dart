import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/core/constants/app_constants.dart';
import 'package:vc_stocks_mobile/features/explore/data/crypto_repository.dart';
import 'package:vc_stocks_mobile/models/crypto.dart';

part 'crypto_provider.g.dart';

@riverpod
Future<List<CryptoQuote>> cryptoPrices(CryptoPricesRef ref) async {
  final timer = Timer.periodic(kRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final repository = ref.read(cryptoRepositoryProvider);
  return repository.getPrices();
}

@riverpod
class CryptoSearchQuery extends _$CryptoSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

@riverpod
Future<List<CryptoSearchResult>> cryptoSearchResults(
  CryptoSearchResultsRef ref,
) async {
  final query = ref.watch(cryptoSearchQueryProvider);
  if (query.length < 2) return [];

  await Future.delayed(const Duration(milliseconds: 300));
  if (ref.watch(cryptoSearchQueryProvider) != query) {
    throw Exception('cancelled');
  }

  final repository = ref.read(cryptoRepositoryProvider);
  return repository.search(query);
}
