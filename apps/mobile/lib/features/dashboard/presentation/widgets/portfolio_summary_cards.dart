import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

class PortfolioSummaryCards extends StatefulWidget {
  final PortfolioSummary summary;
  final double? usdToSgd;

  const PortfolioSummaryCards({
    super.key,
    required this.summary,
    this.usdToSgd,
  });

  @override
  State<PortfolioSummaryCards> createState() => _PortfolioSummaryCardsState();
}

class _PortfolioSummaryCardsState extends State<PortfolioSummaryCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    return SizedBox(
      height: 128,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _AnimatedSummaryCard(
            animation: _controller,
            delay: 0.0,
            child: _GradientSummaryCard(
              title: 'Total Value',
              value: formatCurrency(summary.totalValue),
              subtitle: widget.usdToSgd != null
                  ? 'S\$${formatNumber(summary.totalValue * widget.usdToSgd!)}'
                  : 'Cost: ${formatCurrency(summary.totalCost)}',
              icon: Icons.account_balance_wallet_outlined,
              gradientColors: const [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AnimatedSummaryCard(
            animation: _controller,
            delay: 0.1,
            child: _GradientSummaryCard(
              title: 'Total P/L',
              value: formatCurrency(summary.totalPL),
              subtitle: formatPercent(summary.totalPLPercent),
              icon: summary.totalPL >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
              gradientColors: summary.totalPL >= 0
                  ? const [Color(0xFF11998E), Color(0xFF38EF7D)]
                  : const [Color(0xFFEB3349), Color(0xFFF45C43)],
            ),
          ),
          const SizedBox(width: 12),
          _AnimatedSummaryCard(
            animation: _controller,
            delay: 0.2,
            child: _GradientSummaryCard(
              title: 'Day Change',
              value: formatCurrency(summary.dayChange),
              subtitle: formatPercent(summary.dayChangePercent),
              icon: summary.dayChange >= 0
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              gradientColors: summary.dayChange >= 0
                  ? const [Color(0xFF00B4DB), Color(0xFF0083B0)]
                  : const [Color(0xFFFC4A1A), Color(0xFFF7B733)],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSummaryCard extends StatelessWidget {
  final AnimationController animation;
  final double delay;
  final Widget child;

  const _AnimatedSummaryCard({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress =
            ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final curved = Curves.easeOutBack.transform(progress);
        return Opacity(
          opacity: progress,
          child: Transform.scale(
            scale: 0.8 + (0.2 * curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _GradientSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _GradientSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
