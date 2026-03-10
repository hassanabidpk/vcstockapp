import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/valuation.dart';

class ValuationMetricsCard extends StatelessWidget {
  final ValuationMetrics valuation;

  const ValuationMetricsCard({super.key, required this.valuation});

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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Valuation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (valuation.verdict != null)
                  _VerdictBadge(valuation: valuation),
              ],
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Current Price',
              value: formatCurrency(valuation.currentPrice),
            ),
            if (valuation.peRatio != null)
              _MetricRow(
                label: 'P/E Ratio',
                value: valuation.peRatio!.toStringAsFixed(2),
              ),
            if (valuation.forwardPE != null)
              _MetricRow(
                label: 'Forward P/E',
                value: valuation.forwardPE!.toStringAsFixed(2),
              ),
            if (valuation.pegRatio != null)
              _MetricRow(
                label: 'PEG Ratio',
                value: valuation.pegRatio!.toStringAsFixed(2),
              ),
            if (valuation.eps != null)
              _MetricRow(
                label: 'EPS',
                value: formatCurrency(valuation.eps!),
              ),
            if (valuation.bookValuePerShare != null)
              _MetricRow(
                label: 'Book Value/Share',
                value: formatCurrency(valuation.bookValuePerShare!),
              ),
            if (valuation.priceToBook != null)
              _MetricRow(
                label: 'P/B Ratio',
                value: valuation.priceToBook!.toStringAsFixed(2),
              ),
            if (valuation.priceToSales != null)
              _MetricRow(
                label: 'P/S Ratio',
                value: valuation.priceToSales!.toStringAsFixed(2),
              ),
            if (valuation.grahamNumber != null)
              _MetricRow(
                label: 'Graham Number',
                value: formatCurrency(valuation.grahamNumber!),
                highlight: true,
              ),
            if (valuation.dcfValue != null)
              _MetricRow(
                label: 'DCF Value',
                value: formatCurrency(valuation.dcfValue!),
                highlight: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  final ValuationMetrics valuation;

  const _VerdictBadge({required this.valuation});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (valuation.verdict) {
      case 'undervalued':
        color = AppColors.profit;
        icon = Icons.thumb_up_outlined;
      case 'overvalued':
        color = AppColors.loss;
        icon = Icons.thumb_down_outlined;
      default:
        color = AppColors.yellow;
        icon = Icons.horizontal_rule;
    }

    final label = valuation.verdict != null
        ? '${valuation.verdict![0].toUpperCase()}${valuation.verdict!.substring(1)}'
        : '';

    final upsideText = valuation.upside != null
        ? ' (${formatPercent(valuation.upside!)})'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label$upsideText',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MetricRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: highlight
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? AppColors.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}
