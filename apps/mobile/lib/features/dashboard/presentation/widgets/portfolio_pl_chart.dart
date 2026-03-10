import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/portfolio_snapshot.dart';

class PortfolioPlChart extends StatefulWidget {
  final List<PortfolioSnapshot> snapshots;

  const PortfolioPlChart({super.key, required this.snapshots});

  @override
  State<PortfolioPlChart> createState() => _PortfolioPlChartState();
}

class _PortfolioPlChartState extends State<PortfolioPlChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Calculate a "nice" grid interval that divides the range into ~4 lines.
  double _gridInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 0) return 1;
    final raw = range / 4;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final normalized = raw / magnitude;
    if (normalized <= 1) return magnitude;
    if (normalized <= 2) return 2 * magnitude;
    if (normalized <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = widget.snapshots;
    if (snapshots.length < 2) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Not enough data for chart',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        ),
      );
    }

    final spots = snapshots.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalPL);
    }).toList();

    final lastPL = snapshots.last.totalPL;
    final isProfit = lastPL >= 0;
    final lineColor = isProfit ? AppColors.profit : AppColors.loss;

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final paddedMinY = minY - range * 0.1;
    final paddedMaxY = maxY + range * 0.1;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final axisLabelColor =
        isDark ? AppColors.darkTextMuted : Colors.grey.shade600;

    // Show at most 4-5 evenly-spaced date labels on X axis
    final labelStep = max(1, (snapshots.length / 4).ceil());

    final gridInterval = _gridInterval(paddedMinY, paddedMaxY);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkSurface,
                    lineColor.withValues(alpha: 0.08),
                  ]
                : [
                    Colors.white,
                    lineColor.withValues(alpha: 0.05),
                  ],
          ),
          border: Border.all(
            color: lineColor.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: lineColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isProfit ? Icons.trending_up : Icons.trending_down,
                        color: lineColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'P/L Trend',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lineColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formatCurrency(lastPL),
                        style: TextStyle(
                          color: lineColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: gridInterval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.06),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= snapshots.length) {
                              return const SizedBox.shrink();
                            }
                            // Only show labels at evenly-spaced positions
                            if (idx % labelStep != 0 &&
                                idx != snapshots.length - 1) {
                              return const SizedBox.shrink();
                            }
                            final dateParts =
                                snapshots[idx].date.split('-');
                            if (dateParts.length < 3) {
                              return const SizedBox.shrink();
                            }
                            final month = int.tryParse(dateParts[1]) ?? 0;
                            final day = int.tryParse(dateParts[2]) ?? 0;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '$month/$day',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: axisLabelColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            // Skip edge labels to avoid clipping
                            if (value == meta.min ||
                                value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                formatCompactCurrency(value),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: axisLabelColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: paddedMinY,
                    maxY: paddedMaxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            if (idx >= 0 && idx < snapshots.length) {
                              final snapshot = snapshots[idx];
                              return LineTooltipItem(
                                '${snapshot.date}\n${formatCurrency(snapshot.totalPL)}',
                                TextStyle(
                                  color: lineColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: lineColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              lineColor.withValues(alpha: 0.25),
                              lineColor.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
