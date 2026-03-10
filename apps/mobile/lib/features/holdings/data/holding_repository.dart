import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/api_endpoints.dart';
import 'package:vc_stocks_mobile/core/network/api_client.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

final holdingRepositoryProvider = Provider<HoldingRepository>((ref) {
  return HoldingRepository(client: ref.read(apiClientProvider));
});

class HoldingRepository {
  final ApiClient _client;

  HoldingRepository({required ApiClient client}) : _client = client;

  Future<void> create(
    String portfolioId,
    CreateHoldingInput input,
  ) async {
    await _client.post(
      ApiEndpoints.createHolding(portfolioId),
      data: input.toJson(),
    );
  }

  Future<void> update(
    String holdingId,
    UpdateHoldingInput input,
  ) async {
    await _client.put(
      ApiEndpoints.updateHolding(holdingId),
      data: input.toJson(),
    );
  }

  Future<void> delete(String holdingId) async {
    await _client.delete(ApiEndpoints.deleteHolding(holdingId));
  }
}
