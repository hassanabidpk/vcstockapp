import 'package:intl/intl.dart';

String formatCurrency(double value, {String currency = 'USD'}) {
  final formatter = NumberFormat.currency(
    symbol: currency == 'SGD' ? 'S\$' : '\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

String formatPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

String formatNumber(double value, {int decimals = 2}) {
  final formatter = NumberFormat.decimalPatternDigits(decimalDigits: decimals);
  return formatter.format(value);
}

String formatCompactNumber(double value) {
  if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
  return value.toStringAsFixed(2);
}

/// Compact currency for chart axis labels: `$500`, `$1.2K`, `-$3.5M`
String formatCompactCurrency(double value) {
  final absValue = value.abs();
  final sign = value < 0 ? '-' : '';
  if (absValue >= 1e6) return '$sign\$${(absValue / 1e6).toStringAsFixed(1)}M';
  if (absValue >= 1e3) return '$sign\$${(absValue / 1e3).toStringAsFixed(1)}K';
  return '$sign\$${absValue.toStringAsFixed(0)}';
}

String formatPrice(double value) {
  if (value >= 1) return value.toStringAsFixed(2);
  if (value >= 0.01) return value.toStringAsFixed(4);
  return value.toStringAsFixed(6);
}

String timeAgo(String? dateString) {
  if (dateString == null) return '';
  final date = DateTime.tryParse(dateString);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(date);
}
