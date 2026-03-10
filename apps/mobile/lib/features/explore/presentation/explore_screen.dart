import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vc_stocks_mobile/features/explore/presentation/widgets/crypto_price_card.dart';
import 'package:vc_stocks_mobile/features/explore/presentation/widgets/stock_search_card.dart';
import 'package:vc_stocks_mobile/features/explore/providers/crypto_provider.dart';
import 'package:vc_stocks_mobile/features/explore/providers/stock_search_provider.dart';
import 'package:vc_stocks_mobile/shared/widgets/error_retry_widget.dart';
import 'package:vc_stocks_mobile/shared/widgets/loading_skeleton.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _stockSearchController = TextEditingController();
  final _cryptoSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stockSearchController.dispose();
    _cryptoSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stocks'),
            Tab(text: 'Crypto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StocksTab(controller: _stockSearchController),
          _CryptoTab(controller: _cryptoSearchController),
        ],
      ),
    );
  }
}

class _StocksTab extends ConsumerWidget {
  final TextEditingController controller;

  const _StocksTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(stockSearchResultsProvider);
    final query = ref.watch(stockSearchQueryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search stocks (e.g. AAPL, MSFT)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(stockSearchQueryProvider.notifier)
                            .update('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              ref.read(stockSearchQueryProvider.notifier).update(value);
            },
          ),
        ),
        Expanded(
          child: query.length < 2
              ? Center(
                  child: Text(
                    'Search for stocks by symbol or name',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                )
              : searchResults.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'No results found',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final stock = results[index];
                        return StockSearchCard(
                          stock: stock,
                          onTap: () => context.push('/stock/${stock.symbol}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => ErrorRetryWidget(
                    message: 'Failed to search',
                    onRetry: () => ref.invalidate(stockSearchResultsProvider),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CryptoTab extends ConsumerWidget {
  final TextEditingController controller;

  const _CryptoTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cryptoPricesAsync = ref.watch(cryptoPricesProvider);
    final searchQuery = ref.watch(cryptoSearchQueryProvider);
    final searchResults = ref.watch(cryptoSearchResultsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search crypto (e.g. Bitcoin, ETH)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(cryptoSearchQueryProvider.notifier)
                            .update('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              ref.read(cryptoSearchQueryProvider.notifier).update(value);
            },
          ),
        ),
        Expanded(
          child: searchQuery.length >= 2
              ? searchResults.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final r = results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            onTap: () => context.push(
                              '/crypto/${r.id}?name=${Uri.encodeComponent(r.name)}',
                            ),
                            leading: r.thumb.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(r.thumb),
                                    backgroundColor: Colors.transparent,
                                  )
                                : null,
                            title: Text(r.name),
                            subtitle: Text(r.symbol.toUpperCase()),
                            trailing: r.marketCapRank != null
                                ? Text('#${r.marketCapRank}')
                                : null,
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorRetryWidget(
                    message: 'Failed to search',
                    onRetry: () => ref.invalidate(cryptoSearchResultsProvider),
                  ),
                )
              : cryptoPricesAsync.when(
                  data: (prices) => RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(cryptoPricesProvider);
                    },
                    child: ListView.builder(
                      itemCount: prices.length,
                      itemBuilder: (context, index) {
                        final crypto = prices[index];
                        return CryptoPriceCard(
                          crypto: crypto,
                          onTap: () => context.push(
                            '/crypto/${crypto.id}?name=${Uri.encodeComponent(crypto.name)}',
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => ListView.builder(
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: SkeletonCard(),
                    ),
                  ),
                  error: (e, _) => ErrorRetryWidget(
                    message: 'Failed to load prices',
                    onRetry: () => ref.invalidate(cryptoPricesProvider),
                  ),
                ),
        ),
      ],
    );
  }
}
