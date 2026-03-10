import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/explore/data/stock_repository.dart';
import 'package:vc_stocks_mobile/models/valuation.dart';

part 'valuation_provider.g.dart';

@riverpod
Future<ValuationMetrics> valuation(ValuationRef ref, String symbol) async {
  final repository = ref.read(stockRepositoryProvider);
  return repository.getValuation(symbol);
}
