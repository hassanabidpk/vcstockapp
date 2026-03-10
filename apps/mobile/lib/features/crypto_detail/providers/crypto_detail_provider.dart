import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/features/explore/data/crypto_repository.dart';
import 'package:vc_stocks_mobile/models/stock.dart';

part 'crypto_detail_provider.g.dart';

@riverpod
Future<List<HistoricalPrice>> cryptoHistory(
  CryptoHistoryRef ref,
  String coinId, {
  String range = '1M',
}) async {
  final repository = ref.read(cryptoRepositoryProvider);
  return repository.getHistory(coinId, range: range);
}
