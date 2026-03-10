import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/features/holdings/data/holding_repository.dart';

// Re-export for convenience
final holdingMutationProvider = Provider<HoldingRepository>((ref) {
  return ref.read(holdingRepositoryProvider);
});
