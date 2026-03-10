import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/api_endpoints.dart';
import 'package:vc_stocks_mobile/core/network/api_client.dart';
import 'package:vc_stocks_mobile/models/crypto.dart';
import 'package:vc_stocks_mobile/models/stock.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return CryptoRepository(client: ref.read(apiClientProvider));
});

class CryptoRepository {
  final ApiClient _client;

  CryptoRepository({required ApiClient client}) : _client = client;

  Future<List<CryptoQuote>> getPrices() async {
    final data = await _client.get<List<dynamic>>(ApiEndpoints.cryptoPrices);
    return data
        .map((e) => CryptoQuote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HistoricalPrice>> getHistory(
    String coinId, {
    String range = '1M',
  }) async {
    final data = await _client.get<List<dynamic>>(
      ApiEndpoints.cryptoHistory(coinId),
      queryParameters: {'range': range},
    );
    return data
        .map((e) => HistoricalPrice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CryptoSearchResult>> search(String query) async {
    final data = await _client.get<List<dynamic>>(
      ApiEndpoints.cryptoSearch,
      queryParameters: {'q': query},
    );
    return data
        .map((e) => CryptoSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
