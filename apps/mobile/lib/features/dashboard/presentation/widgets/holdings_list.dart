import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/constants/app_constants.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/widgets/holding_card.dart';
import 'package:vc_stocks_mobile/models/holding.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

class HoldingsList extends StatelessWidget {
  final Map<String, AssetTypeSummary> byAssetType;
  final void Function(HoldingWithPrice holding) onHoldingTap;

  const HoldingsList({
    super.key,
    required this.byAssetType,
    required this.onHoldingTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = byAssetType.entries
        .where((e) => e.value.holdings.isNotEmpty)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 32,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No holdings yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap + to add your first holding',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    int globalIndex = 0;

    return Column(
      children: entries.map((entry) {
        final label = kAssetTypeLabels[entry.key] ?? entry.key;
        final summary = entry.value;
        final plColor =
            summary.totalPL >= 0 ? AppColors.profit : AppColors.loss;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          formatCurrency(summary.totalValue),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${summary.totalPL >= 0 ? "+" : ""}${formatPercent(summary.totalPLPercent)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: plColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...summary.holdings.map(
              (holding) {
                final idx = globalIndex++;
                return HoldingCard(
                  holding: holding,
                  index: idx,
                  onTap: () => onHoldingTap(holding),
                );
              },
            ),
          ],
        );
      }).toList(),
    );
  }
}
