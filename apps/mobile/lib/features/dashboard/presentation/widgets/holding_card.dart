import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

// Shared helpers
Color plColor(double v) {
  if (v > 0) return AppColors.profit;
  if (v < 0) return AppColors.loss;
  return AppColors.darkTextSecondary;
}

String plSign(double v) => v >= 0 ? '+' : '';

String firstName(String name) => name.split(RegExp(r'\s+')).first;

/// Fixed left column: company name + ticker symbol.
class HoldingSymbolCell extends StatelessWidget {
  final HoldingWithPrice holding;

  const HoldingSymbolCell({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          firstName(holding.name),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          holding.symbol,
          style: TextStyle(fontSize: 11, color: mutedColor),
        ),
        if (holding.platform.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBorder
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              holding.platform,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// Scrollable data columns: MV/Qty, Price/Cost, Today P/L, Total P/L, % Port.
class HoldingDataCells extends StatelessWidget {
  final HoldingWithPrice holding;
  final double portfolioTotalValue;

  const HoldingDataCells({
    super.key,
    required this.holding,
    required this.portfolioTotalValue,
  });

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayPL = h.change * h.shares;
    final pctPortfolio = portfolioTotalValue > 0
        ? (h.marketValue / portfolioTotalValue) * 100
        : 0.0;

    final mutedColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey.shade600;
    const numStyle = TextStyle(
      fontSize: 13,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final subStyle = TextStyle(
      fontSize: 11,
      color: mutedColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      children: [
        // MV / Qty
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatNumber(h.marketValue),
                style: numStyle.copyWith(fontWeight: FontWeight.w500),
              ),
              Text('${h.shares}', style: subStyle),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Price / Cost
        SizedBox(
          width: 76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(formatNumber(h.currentPrice), style: numStyle),
              Text(formatNumber(h.avgBuyPrice), style: subStyle),
              if (h.priceUpdatedAt != null && h.priceUpdatedAt!.isNotEmpty)
                Text(
                  timeAgo(h.priceUpdatedAt),
                  style: TextStyle(
                    fontSize: 9,
                    color: mutedColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Today's P/L
        SizedBox(
          width: 76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${plSign(todayPL)}${formatNumber(todayPL.abs())}',
                style: numStyle.copyWith(color: plColor(todayPL)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Total P/L $ / %
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${plSign(h.profitLoss)}${formatNumber(h.profitLoss.abs())}',
                style: numStyle.copyWith(color: plColor(h.profitLoss)),
              ),
              Text(
                '${plSign(h.profitLossPercent)}${h.profitLossPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: plColor(h.profitLossPercent),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // % Portfolio
        SizedBox(
          width: 56,
          child: Text(
            '${pctPortfolio.toStringAsFixed(2)}%',
            textAlign: TextAlign.end,
            style: numStyle,
          ),
        ),
      ],
    );
  }
}
