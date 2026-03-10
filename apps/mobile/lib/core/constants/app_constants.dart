const Duration kRefreshInterval = Duration(seconds: 60);

const Map<String, String> kAssetTypeLabels = {
  'us_stock': 'US Stocks',
  'sg_stock': 'SG Stocks',
  'crypto': 'Crypto',
};

const List<String> kRangeOptions = ['1W', '1M', '3M', '6M', '1Y', '5Y'];

const List<String> kPlatformOptions = [
  'Moomoo',
  'Tiger',
  'IBKR',
  'OKX',
  'CoinHako',
  'Other',
];
