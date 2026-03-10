import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/explore/data/stock_repository.dart';
import 'package:vc_stocks_mobile/models/stock.dart';

part 'stock_history_provider.g.dart';

@riverpod
Future<List<HistoricalPrice>> stockHistory(
  StockHistoryRef ref,
  String symbol, {
  String range = '1M',
}) async {
  final repository = ref.read(stockRepositoryProvider);
  return repository.getHistory(symbol, range: range);
}
