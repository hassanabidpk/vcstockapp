import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_snapshot.freezed.dart';
part 'portfolio_snapshot.g.dart';

@freezed
class PortfolioSnapshot with _$PortfolioSnapshot {
  const factory PortfolioSnapshot({
    required String date,
    required double totalValue,
    required double totalCost,
    required double totalPL,
  }) = _PortfolioSnapshot;

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PortfolioSnapshotFromJson(json);
}
