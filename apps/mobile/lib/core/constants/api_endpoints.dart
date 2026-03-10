class ApiEndpoints {
  ApiEndpoints._();

  static const login = '/v1/auth/login';
  static const logout = '/v1/auth/logout';
  static const portfolios = '/v1/portfolios';

  static String portfolio(String id) => '/v1/portfolios/$id';
  static String portfolioSummary(String id) => '/v1/portfolios/$id/summary';
  static String portfolioHistory(String id) => '/v1/portfolios/$id/history';

  static String createHolding(String portfolioId) =>
      '/v1/portfolios/$portfolioId/holdings';
  static String updateHolding(String holdingId) => '/v1/holdings/$holdingId';
  static String deleteHolding(String holdingId) => '/v1/holdings/$holdingId';

  static String stockQuote(String symbol) => '/v1/stocks/quote/$symbol';
  static String stockHistory(String symbol) => '/v1/stocks/history/$symbol';
  static String stockValuation(String symbol) =>
      '/v1/stocks/valuation/$symbol';
  static String stockProfile(String symbol) => '/v1/stocks/profile/$symbol';
  static const stockSearch = '/v1/stocks/search';

  static const cryptoPrices = '/v1/crypto/prices';
  static String cryptoHistory(String coinId) => '/v1/crypto/history/$coinId';
  static const cryptoSearch = '/v1/crypto/search';
}
