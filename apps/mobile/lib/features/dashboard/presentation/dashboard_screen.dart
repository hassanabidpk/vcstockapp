import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/features/auth/providers/auth_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/widgets/holdings_list.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/widgets/portfolio_pl_chart.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/widgets/portfolio_summary_cards.dart';
import 'package:vc_stocks_mobile/features/dashboard/data/portfolio_repository.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_detail_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_history_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_list_provider.dart';
import 'package:vc_stocks_mobile/features/holdings/presentation/add_holding_sheet.dart';
import 'package:vc_stocks_mobile/features/holdings/presentation/edit_holding_sheet.dart';
import 'package:vc_stocks_mobile/shared/widgets/error_retry_widget.dart';
import 'package:vc_stocks_mobile/shared/widgets/loading_skeleton.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-select first portfolio when list loads
    ref.listenManual(portfolioListProvider, (prev, next) {
      next.whenData((portfolios) {
        if (portfolios.isNotEmpty &&
            ref.read(selectedPortfolioProvider) == null) {
          ref
              .read(selectedPortfolioProvider.notifier)
              .select(portfolios.first.id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioListAsync = ref.watch(portfolioListProvider);
    final portfolioDetailAsync = ref.watch(portfolioDetailProvider);
    final historyAsync = ref.watch(portfolioHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Portfolio'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(portfolioDetailProvider);
          ref.invalidate(portfolioHistoryProvider);
        },
        child: ListView(
          children: [
            // Portfolio selector
            portfolioListAsync.when(
              data: (portfolios) {
                if (portfolios.isEmpty) {
                  return const SizedBox.shrink();
                }
                final selectedId = ref.watch(selectedPortfolioProvider);
                return SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: portfolios.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final p = portfolios[index];
                      final isSelected = p.id == selectedId;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(p.name),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) {
                          ref
                              .read(selectedPortfolioProvider.notifier)
                              .select(p.id);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingSkeleton(height: 32, width: 120),
              ),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            // Portfolio detail
            portfolioDetailAsync.when(
              data: (portfolio) {
                if (portfolio == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text('Select a portfolio'),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    PortfolioSummaryCards(
                      summary: portfolio.summary,
                      usdToSgd: portfolio.usdToSgd,
                    ),
                    const SizedBox(height: 16),

                    // P/L Chart
                    historyAsync.when(
                      data: (snapshots) =>
                          PortfolioPlChart(snapshots: snapshots),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SkeletonCard(),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),

                    // Holdings
                    HoldingsList(
                      byAssetType: portfolio.summary.byAssetType,
                      portfolioTotalValue: portfolio.summary.totalValue,
                      onHoldingTap: (holding) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => EditHoldingSheet(
                            holding: holding,
                            onSaved: () {
                              final id = ref.read(selectedPortfolioProvider);
                              if (id != null) {
                                ref.read(portfolioRepositoryProvider).clearDetailCache(id);
                              }
                              ref.invalidate(portfolioDetailProvider);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SkeletonCard(),
                    SizedBox(height: 8),
                    SkeletonCard(),
                    SizedBox(height: 8),
                    SkeletonCard(),
                  ],
                ),
              ),
              error: (e, _) => ErrorRetryWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(portfolioDetailProvider),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            final selectedId = ref.read(selectedPortfolioProvider);
            if (selectedId == null) return;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddHoldingSheet(
                portfolioId: selectedId,
                onSaved: () {
                  ref.read(portfolioRepositoryProvider).clearDetailCache(selectedId);
                  ref.invalidate(portfolioDetailProvider);
                },
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
