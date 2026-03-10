import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/explore/data/stock_repository.dart';
import 'package:vc_stocks_mobile/models/stock.dart';

part 'stock_search_provider.g.dart';

@riverpod
class StockSearchQuery extends _$StockSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

@riverpod
Future<List<StockSearchResult>> stockSearchResults(
  StockSearchResultsRef ref,
) async {
  final query = ref.watch(stockSearchQueryProvider);
  if (query.length < 2) return [];

  // Debounce: wait 300ms after last change
  await Future.delayed(const Duration(milliseconds: 300));

  // Check if query changed during debounce
  if (ref.watch(stockSearchQueryProvider) != query) {
    throw Exception('cancelled');
  }

  final repository = ref.read(stockRepositoryProvider);
  return repository.search(query);
}
