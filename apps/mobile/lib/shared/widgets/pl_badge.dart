import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';

class PlBadge extends StatelessWidget {
  final double value;
  final bool showSign;

  const PlBadge({
    super.key,
    required this.value,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final color = isPositive ? AppColors.profit : AppColors.loss;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color,
            size: 14,
          ),
          Text(
            formatPercent(value),
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
