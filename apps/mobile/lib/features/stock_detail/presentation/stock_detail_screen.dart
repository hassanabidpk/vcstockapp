import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/features/holdings/presentation/add_holding_sheet.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_detail_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_list_provider.dart';
import 'package:vc_stocks_mobile/features/stock_detail/presentation/widgets/price_chart.dart';
import 'package:vc_stocks_mobile/features/stock_detail/presentation/widgets/quote_header.dart';
import 'package:vc_stocks_mobile/features/stock_detail/presentation/widgets/valuation_metrics_card.dart';
import 'package:vc_stocks_mobile/features/stock_detail/providers/stock_history_provider.dart';
import 'package:vc_stocks_mobile/features/stock_detail/providers/stock_quote_provider.dart';
import 'package:vc_stocks_mobile/features/stock_detail/providers/valuation_provider.dart';
import 'package:vc_stocks_mobile/shared/widgets/error_retry_widget.dart';
import 'package:vc_stocks_mobile/shared/widgets/loading_skeleton.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  String _selectedRange = '1M';

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(stockQuoteProvider(widget.symbol));
    final historyAsync =
        ref.watch(stockHistoryProvider(widget.symbol, range: _selectedRange));
    final valuationAsync = ref.watch(valuationProvider(widget.symbol));

    return Scaffold(
      appBar: AppBar(title: Text(widget.symbol)),
      body: quoteAsync.when(
        data: (quote) => ListView(
          children: [
            const SizedBox(height: 8),
            QuoteHeader(quote: quote),
            const SizedBox(height: 16),
            PriceChart(
              history: historyAsync.valueOrNull ?? [],
              selectedRange: _selectedRange,
              onRangeChanged: (range) {
                setState(() => _selectedRange = range);
              },
              isLoading: historyAsync.isLoading,
            ),
            const SizedBox(height: 16),
            valuationAsync.when(
              data: (valuation) =>
                  ValuationMetricsCard(valuation: valuation),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonCard(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF667EEA).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final portfolioId =
                        ref.read(selectedPortfolioProvider);
                    if (portfolioId == null) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddHoldingSheet(
                        portfolioId: portfolioId,
                        prefillSymbol: quote.symbol,
                        prefillName: quote.name,
                        onSaved: () {
                          ref.invalidate(portfolioDetailProvider);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add to Portfolio',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(stockQuoteProvider(widget.symbol)),
        ),
      ),
    );
  }
}
