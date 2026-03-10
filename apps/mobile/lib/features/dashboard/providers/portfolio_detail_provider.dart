import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/core/constants/app_constants.dart';
import 'package:vc_stocks_mobile/features/dashboard/data/portfolio_repository.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_list_provider.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

part 'portfolio_detail_provider.g.dart';

@riverpod
Future<Portfolio?> portfolioDetail(PortfolioDetailRef ref) async {
  final selectedId = ref.watch(selectedPortfolioProvider);
  if (selectedId == null) return null;

  final timer = Timer.periodic(kRefreshInterval, (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final repository = ref.read(portfolioRepositoryProvider);

  // Try cache first
  final cached = await repository.getPortfolioCached(selectedId);
  if (cached != null) {
    // Background refresh — updates cache, timer handles next UI update
    Future.microtask(() async {
      try {
        await repository.getPortfolioRemote(selectedId);
      } catch (_) {
        // Silent fail — cached data is still valid
      }
    });
    return cached;
  }

  return repository.getPortfolioRemote(selectedId);
}
