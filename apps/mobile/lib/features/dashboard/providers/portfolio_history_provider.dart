import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/dashboard/data/portfolio_repository.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_list_provider.dart';
import 'package:vc_stocks_mobile/models/portfolio_snapshot.dart';

part 'portfolio_history_provider.g.dart';

@riverpod
Future<List<PortfolioSnapshot>> portfolioHistory(
  PortfolioHistoryRef ref,
) async {
  final selectedId = ref.watch(selectedPortfolioProvider);
  if (selectedId == null) return [];

  final repository = ref.read(portfolioRepositoryProvider);

  // Try cache first
  final cached = await repository.getHistoryCached(selectedId);
  if (cached != null && cached.isNotEmpty) {
    // Background refresh — updates cache for next read
    Future.microtask(() async {
      try {
        await repository.getHistoryRemote(selectedId);
      } catch (_) {
        // Silent fail — cached data is still valid
      }
    });
    return cached;
  }

  return repository.getHistoryRemote(selectedId);
}
