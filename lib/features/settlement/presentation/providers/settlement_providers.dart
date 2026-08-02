import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settlement_repository_impl.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  return SettlementRepositoryImpl();
});

final messSettlementsStreamProvider =
    StreamProvider.family<List<SettlementEntity>, String>((ref, messId) {
  final repository = ref.watch(settlementRepositoryProvider);
  return repository.watchMessSettlements(messId: messId);
});
