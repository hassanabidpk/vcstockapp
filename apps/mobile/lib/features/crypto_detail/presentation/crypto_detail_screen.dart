import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/features/crypto_detail/providers/crypto_detail_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_detail_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_list_provider.dart';
import 'package:vc_stocks_mobile/features/holdings/presentation/add_holding_sheet.dart';
import 'package:vc_stocks_mobile/features/stock_detail/presentation/widgets/price_chart.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

class CryptoDetailScreen extends ConsumerStatefulWidget {
  final String coinId;
  final String name;

  const CryptoDetailScreen({
    super.key,
    required this.coinId,
    required this.name,
  });

  @override
  ConsumerState<CryptoDetailScreen> createState() =>
      _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends ConsumerState<CryptoDetailScreen> {
  String _selectedRange = '1M';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      cryptoHistoryProvider(widget.coinId, range: _selectedRange),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.name.isNotEmpty ? widget.name : widget.coinId)),
      body: ListView(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                final portfolioId = ref.read(selectedPortfolioProvider);
                if (portfolioId == null) return;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddHoldingSheet(
                    portfolioId: portfolioId,
                    prefillSymbol: widget.coinId,
                    prefillName: widget.name,
                    prefillAssetType: AssetType.crypto,
                    onSaved: () {
                      ref.invalidate(portfolioDetailProvider);
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Portfolio'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
