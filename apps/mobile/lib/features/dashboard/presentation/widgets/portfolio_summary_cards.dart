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
    final dayPlColor =
        summary.dayChange >= 0 ? AppColors.profit : AppColors.loss;
    final daySign = summary.dayChange >= 0 ? '+' : '';
    final totalPlColor =
        summary.totalPL >= 0 ? AppColors.profit : AppColors.loss;
    final totalSign = summary.totalPL >= 0 ? '+' : '';

    final labelStyle = TextStyle(
      fontSize: 13,
      color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Net Assets
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Assets', style: labelStyle),
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
          ),
          // Right: Total P/L + Today's P/L
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total P/L
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total P/L', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    '$totalSign${formatCurrency(summary.totalPL)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: totalPlColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalSign}${summary.totalPLPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: totalPlColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Today's P/L
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Today's P/L", style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    '$daySign${formatCurrency(summary.dayChange)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dayPlColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPercent(summary.dayChangePercent),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dayPlColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
