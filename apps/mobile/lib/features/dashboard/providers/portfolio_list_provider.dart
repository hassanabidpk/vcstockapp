import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/core/storage/preferences_service.dart';
import 'package:vc_stocks_mobile/features/dashboard/data/portfolio_repository.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

part 'portfolio_list_provider.g.dart';

@riverpod
Future<List<PortfolioInfo>> portfolioList(PortfolioListRef ref) async {
  final repository = ref.read(portfolioRepositoryProvider);

  // Try cache first
  final cached = await repository.listPortfoliosCached();
  if (cached != null && cached.isNotEmpty) {
    // Background refresh — updates cache for next read
    Future.microtask(() async {
      try {
        await repository.listPortfoliosRemote();
      } catch (_) {
        // Silent fail — cached data is still valid
      }
    });
    return cached;
  }

  // No cache — fetch from API
  return repository.listPortfoliosRemote();
}

@Riverpod(keepAlive: true)
class SelectedPortfolio extends _$SelectedPortfolio {
  @override
  String? build() {
    // Restore persisted selection
    final prefs = ref.read(preferencesServiceProvider);
    return prefs.getSelectedPortfolioId();
  }

  void select(String id) {
    state = id;
    // Persist selection
    ref.read(preferencesServiceProvider).setSelectedPortfolioId(id);
  }
}
