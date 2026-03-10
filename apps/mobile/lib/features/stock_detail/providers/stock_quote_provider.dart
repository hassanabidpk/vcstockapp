import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/explore/data/stock_repository.dart';
import 'package:vc_stocks_mobile/models/stock.dart';

part 'stock_quote_provider.g.dart';

@riverpod
Future<StockQuote> stockQuote(StockQuoteRef ref, String symbol) async {
  final repository = ref.read(stockRepositoryProvider);
  return repository.getQuote(symbol);
}
