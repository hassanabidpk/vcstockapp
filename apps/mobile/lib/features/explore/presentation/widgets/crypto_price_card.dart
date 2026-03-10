import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/crypto.dart';
import 'package:vc_stocks_mobile/shared/widgets/pl_badge.dart';

class CryptoPriceCard extends StatelessWidget {
  final CryptoQuote crypto;
  final VoidCallback onTap;

  const CryptoPriceCard({
    super.key,
    required this.crypto,
    required this.onTap,
  });

  Color _symbolColor(String symbol) {
    // Generate a consistent color per symbol
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFA8E6CF),
      const Color(0xFFDDA0DD),
      const Color(0xFF98D8C8),
      const Color(0xFFF7DC6F),
    ];
    return colors[symbol.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _symbolColor(crypto.symbol);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, accent.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              crypto.symbol.toUpperCase().substring(
                    0,
                    crypto.symbol.length > 2 ? 2 : crypto.symbol.length,
                  ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          crypto.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          formatCurrency(crypto.price),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'MCap: ${formatCompactNumber(crypto.marketCap)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            PlBadge(value: crypto.changePercent24h),
          ],
        ),
      ),
    );
  }
}
