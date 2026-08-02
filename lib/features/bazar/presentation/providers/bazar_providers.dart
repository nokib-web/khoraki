import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bazar_repository_impl.dart';
import '../../domain/entities/bazar_entry_entity.dart';
import '../../domain/repositories/bazar_repository.dart';

final bazarRepositoryProvider = Provider<BazarRepository>((ref) {
  return BazarRepositoryImpl();
});

class MonthYear {
  final int year;
  final int month;

  const MonthYear({required this.year, required this.month});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthYear &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

final selectedMonthYearProvider = StateProvider<MonthYear>((ref) {
  final now = DateTime.now();
  return MonthYear(year: now.year, month: now.month);
});

class MonthlyBazarParams {
  final String messId;
  final int year;
  final int month;

  const MonthlyBazarParams({
    required this.messId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBazarParams &&
          runtimeType == other.runtimeType &&
          messId == other.messId &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => messId.hashCode ^ year.hashCode ^ month.hashCode;
}

final monthlyBazarStreamProvider =
    StreamProvider.family<List<BazarEntryEntity>, MonthlyBazarParams>((ref, params) {
  final repository = ref.watch(bazarRepositoryProvider);
  return repository.watchMonthlyBazarEntries(
    messId: params.messId,
    year: params.year,
    month: params.month,
  );
});
