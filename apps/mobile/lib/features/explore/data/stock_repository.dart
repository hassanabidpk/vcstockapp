import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/api_endpoints.dart';
import 'package:vc_stocks_mobile/core/network/api_client.dart';
import 'package:vc_stocks_mobile/models/stock.dart';
import 'package:vc_stocks_mobile/models/valuation.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(client: ref.read(apiClientProvider));
});

class StockRepository {
  final ApiClient _client;

  StockRepository({required ApiClient client}) : _client = client;

  Future<List<StockSearchResult>> search(String query) async {
    final data = await _client.get<List<dynamic>>(
      ApiEndpoints.stockSearch,
      queryParameters: {'q': query},
    );
    return data
        .map((e) => StockSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StockQuote> getQuote(String symbol) async {
    final data = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.stockQuote(symbol));
    return StockQuote.fromJson(data);
  }

  Future<List<HistoricalPrice>> getHistory(
    String symbol, {
    String range = '1M',
  }) async {
    final data = await _client.get<List<dynamic>>(
      ApiEndpoints.stockHistory(symbol),
      queryParameters: {'range': range},
    );
    return data
        .map((e) => HistoricalPrice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ValuationMetrics> getValuation(String symbol) async {
    final data = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.stockValuation(symbol));
    return ValuationMetrics.fromJson(data);
  }
}
