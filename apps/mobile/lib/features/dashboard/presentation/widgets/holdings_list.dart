import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/constants/app_constants.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/features/dashboard/presentation/widgets/holding_card.dart';
import 'package:vc_stocks_mobile/models/holding.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

enum _SortField { marketValue, currentPrice, todayPL, totalPL, pctPortfolio }

// Fixed widths matching HoldingDataCells
const _kSymbolWidth = 64.0;
const _kRowHeight = 56.0;
const _kHeaderHeight = 28.0;
// Total scrollable data width: 80+10+76+10+76+10+80+10+56 = 408
const _kDataWidth = 408.0;

class HoldingsList extends StatefulWidget {
  final Map<String, AssetTypeSummary> byAssetType;
  final double portfolioTotalValue;
  final void Function(HoldingWithPrice holding) onHoldingTap;

  const HoldingsList({
    super.key,
    required this.byAssetType,
    required this.portfolioTotalValue,
    required this.onHoldingTap,
  });

  @override
  State<HoldingsList> createState() => _HoldingsListState();
}

class _HoldingsListState extends State<HoldingsList> {
  _SortField _sortField = _SortField.marketValue;
  bool _sortAsc = false;

  void _onSort(_SortField field) {
    setState(() {
      if (_sortField == field) {
        if (!_sortAsc) {
          _sortAsc = true;
        } else {
          _sortField = _SortField.marketValue;
          _sortAsc = false;
        }
      } else {
        _sortField = field;
        _sortAsc = false;
      }
    });
  }

  double _sortValue(HoldingWithPrice h) {
    switch (_sortField) {
      case _SortField.marketValue:
        return h.marketValue;
      case _SortField.currentPrice:
        return h.currentPrice;
      case _SortField.todayPL:
        return h.change * h.shares;
      case _SortField.totalPL:
        return h.profitLoss;
      case _SortField.pctPortfolio:
        return widget.portfolioTotalValue > 0
            ? h.marketValue / widget.portfolioTotalValue
            : 0;
    }
  }

  List<HoldingWithPrice> _sorted(List<HoldingWithPrice> holdings) {
    final sorted = List<HoldingWithPrice>.from(holdings);
    sorted.sort((a, b) {
      final va = _sortValue(a);
      final vb = _sortValue(b);
      return _sortAsc ? va.compareTo(vb) : vb.compareTo(va);
    });
    return sorted;
  }

  Widget _sortableHeader(
      String label, _SortField field, Color color, double width) {
    final isActive = _sortField == field;
    return GestureDetector(
      onTap: () => _onSort(field),
      child: SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? AppColors.primary : color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.byAssetType.entries
        .where((e) => e.value.holdings.isNotEmpty)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 32,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No holdings yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap + to add your first holding',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final mutedColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey.shade600;
    final borderColor =
        isDark ? AppColors.darkBorder : Colors.grey.shade200;

    return Column(
      children: entries.map((entry) {
        final label = kAssetTypeLabels[entry.key] ?? entry.key;
        final summary = entry.value;
        final plColor =
            summary.totalPL >= 0 ? AppColors.profit : AppColors.loss;
        final sortedHoldings = _sorted(summary.holdings);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${summary.totalPL >= 0 ? "+" : ""}${summary.totalPLPercent.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: plColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Table: fixed symbol column + scrollable data columns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED: Symbol column (sticky left)
                  SizedBox(
                    width: _kSymbolWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Symbol header
                        Container(
                          height: _kHeaderHeight,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderColor),
                            ),
                          ),
                          child: Text(
                            'Symbol',
                            style: TextStyle(fontSize: 11, color: mutedColor),
                          ),
                        ),
                        // Symbol cells
                        ...sortedHoldings.map(
                          (h) => GestureDetector(
                            onTap: () => widget.onHoldingTap(h),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: _kRowHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: borderColor),
                                ),
                              ),
                              child: HoldingSymbolCell(holding: h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SCROLLABLE: Data columns
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _kDataWidth,
                        child: Column(
                          children: [
                            // Data headers
                            Container(
                              height: _kHeaderHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: borderColor),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _sortableHeader('MV / Qty',
                                      _SortField.marketValue, mutedColor, 80),
                                  const SizedBox(width: 10),
                                  _sortableHeader('Price / Cost',
                                      _SortField.currentPrice, mutedColor, 76),
                                  const SizedBox(width: 10),
                                  _sortableHeader("Today's P/L",
                                      _SortField.todayPL, mutedColor, 76),
                                  const SizedBox(width: 10),
                                  _sortableHeader('Total P/L',
                                      _SortField.totalPL, mutedColor, 80),
                                  const SizedBox(width: 10),
                                  _sortableHeader('% Port',
                                      _SortField.pctPortfolio, mutedColor, 56),
                                ],
                              ),
                            ),
                            // Data rows
                            ...sortedHoldings.map(
                              (h) => GestureDetector(
                                onTap: () => widget.onHoldingTap(h),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: _kRowHeight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: borderColor),
                                    ),
                                  ),
                                  child: HoldingDataCells(
                                    holding: h,
                                    portfolioTotalValue:
                                        widget.portfolioTotalValue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
