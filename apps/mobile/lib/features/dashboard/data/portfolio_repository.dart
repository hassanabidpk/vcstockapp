import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/api_endpoints.dart';
import 'package:vc_stocks_mobile/core/network/api_client.dart';
import 'package:vc_stocks_mobile/core/storage/local_cache_service.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';
import 'package:vc_stocks_mobile/models/portfolio_snapshot.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(
    client: ref.read(apiClientProvider),
    cache: ref.read(localCacheServiceProvider),
  );
});

class PortfolioRepository {
  final ApiClient _client;
  final LocalCacheService _cache;

  static const _portfolioListKey = 'portfolio_list';
  static String _portfolioDetailKey(String id) => 'portfolio_detail_$id';
  static String _portfolioHistoryKey(String id) => 'portfolio_history_$id';

  PortfolioRepository({
    required ApiClient client,
    required LocalCacheService cache,
  })  : _client = client,
        _cache = cache;

  // ---------------------------------------------------------------------------
  // Portfolio List
  // ---------------------------------------------------------------------------

  Future<List<PortfolioInfo>?> listPortfoliosCached() async {
    return _cache.readList(_portfolioListKey, PortfolioInfo.fromJson);
  }

  Future<List<PortfolioInfo>> listPortfoliosRemote() async {
    final data = await _client.get<List<dynamic>>(ApiEndpoints.portfolios);
    final portfolios = data
        .map((e) => PortfolioInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    await _cache.writeList(
      _portfolioListKey,
      portfolios.map((p) => p.toJson()).toList(),
    );
    return portfolios;
  }

  Future<List<PortfolioInfo>> listPortfolios() async {
    return listPortfoliosRemote();
  }

  // ---------------------------------------------------------------------------
  // Portfolio Detail
  // ---------------------------------------------------------------------------

  Future<Portfolio?> getPortfolioCached(String id) async {
    return _cache.read(_portfolioDetailKey(id), Portfolio.fromJson);
  }

  Future<Portfolio> getPortfolioRemote(String id) async {
    final data =
        await _client.get<Map<String, dynamic>>(ApiEndpoints.portfolio(id));
    final portfolio = Portfolio.fromJson(data);
    await _cache.write(_portfolioDetailKey(id), portfolio.toJson());
    return portfolio;
  }

  Future<Portfolio> getPortfolio(String id) async {
    return getPortfolioRemote(id);
  }

  /// Clear cached detail so next provider read fetches fresh from API.
  Future<void> clearDetailCache(String id) async {
    await _cache.delete(_portfolioDetailKey(id));
  }

  // ---------------------------------------------------------------------------
  // Portfolio History
  // ---------------------------------------------------------------------------

  Future<List<PortfolioSnapshot>?> getHistoryCached(String id) async {
    return _cache.readList(
      _portfolioHistoryKey(id),
      PortfolioSnapshot.fromJson,
    );
  }

  Future<List<PortfolioSnapshot>> getHistoryRemote(String id) async {
    final data = await _client
        .get<List<dynamic>>(ApiEndpoints.portfolioHistory(id));
    final snapshots = data
        .map((e) => PortfolioSnapshot.fromJson(e as Map<String, dynamic>))
        .toList();
    await _cache.writeList(
      _portfolioHistoryKey(id),
      snapshots.map((s) => s.toJson()).toList(),
    );
    return snapshots;
  }

  Future<List<PortfolioSnapshot>> getHistory(String id) async {
    return getHistoryRemote(id);
  }
}
