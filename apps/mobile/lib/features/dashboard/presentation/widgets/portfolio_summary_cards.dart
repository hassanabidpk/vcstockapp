import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

class PortfolioSummaryCards extends StatelessWidget {
  final PortfolioSummary summary;
  final double? usdToSgd;

  const PortfolioSummaryCards({
    super.key,
    required this.summary,
    this.usdToSgd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plColor =
        summary.dayChange >= 0 ? AppColors.profit : AppColors.loss;
    final sign = summary.dayChange >= 0 ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Net Assets
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Assets',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(summary.totalValue),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (usdToSgd != null) ...[
                const SizedBox(height: 2),
                Text(
                  '≈ S\$${formatNumber(summary.totalValue * usdToSgd!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
          // Right: Today's P/L
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Today's P/L",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$sign${formatCurrency(summary.dayChange)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: plColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatPercent(summary.dayChangePercent),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: plColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
