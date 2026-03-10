import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/stock.dart';
import 'package:vc_stocks_mobile/shared/widgets/pl_badge.dart';

class QuoteHeader extends StatelessWidget {
  final StockQuote quote;

  const QuoteHeader({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            quote.symbol.length > 2
                                ? quote.symbol.substring(0, 2)
                                : quote.symbol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote.symbol,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              quote.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(quote.price),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    PlBadge(value: quote.changePercent),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.08),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label: 'Day Range',
                  value:
                      '${formatCurrency(quote.dayLow)} - ${formatCurrency(quote.dayHigh)}',
                  icon: Icons.swap_vert,
                ),
                _MetricChip(
                  label: 'Volume',
                  value: formatCompactNumber(quote.volume),
                  icon: Icons.bar_chart,
                ),
                _MetricChip(
                  label: 'Mkt Cap',
                  value: formatCompactNumber(quote.marketCap),
                  icon: Icons.pie_chart_outline,
                ),
                if (quote.pe != null)
                  _MetricChip(
                    label: 'P/E',
                    value: quote.pe!.toStringAsFixed(2),
                    icon: Icons.calculate_outlined,
                  ),
                if (quote.eps != null)
                  _MetricChip(
                    label: 'EPS',
                    value: formatCurrency(quote.eps!),
                    icon: Icons.attach_money,
                  ),
                _MetricChip(
                  label: 'Exchange',
                  value: quote.exchange,
                  icon: Icons.language,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _MetricChip({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
