import 'member_settlement_summary.dart';

class SettlementEntity {
  final String id; // e.g. 2026-08
  final String messId;
  final String yearMonth; // e.g. 2026-08
  final double totalMeals;
  final double totalBazarCost;
  final double mealRate;
  final String closedByUserId;
  final String closedByUserName;
  final DateTime closedAt;
  final List<MemberSettlementSummary> memberSummaries;

  const SettlementEntity({
    required this.id,
    required this.messId,
    required this.yearMonth,
    required this.totalMeals,
    required this.totalBazarCost,
    required this.mealRate,
    required this.closedByUserId,
    required this.closedByUserName,
    required this.closedAt,
    required this.memberSummaries,
  });

  /// Formats the settlement into a shareable text message for group chats
  String formatShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('📋 *KHORAKI MESS SETTLEMENT ($yearMonth)*');
    buffer.writeln('-----------------------------------');
    buffer.writeln('🛒 Total Bazar: ৳${totalBazarCost.toStringAsFixed(2)}');
    buffer.writeln('🍲 Total Meals: ${totalMeals.toInt()}');
    buffer.writeln('📊 Meal Rate: ৳${mealRate.toStringAsFixed(2)} / meal');
    buffer.writeln('-----------------------------------');
    buffer.writeln('👤 *MEMBER BREAKDOWN:*');

    for (final member in memberSummaries) {
      final sign = member.balance >= 0 ? '+' : '';
      final statusText = member.balance >= 0
          ? 'Credit: ৳${member.balance.toStringAsFixed(2)}'
          : 'Owes: ৳${member.balance.abs().toStringAsFixed(2)}';

      buffer.writeln('\n• *${member.userName}*');
      buffer.writeln('  Meals: ${member.mealsEaten.toInt()} | Owed: ৳${member.amountOwed.toStringAsFixed(2)} | Paid: ৳${member.depositTotal.toStringAsFixed(2)}');
      buffer.writeln('  Status: $sign$statusText');
    }

    buffer.writeln('\n-----------------------------------');
    buffer.writeln('Closed by: $closedByUserName');
    buffer.writeln('Generated via Khoraki App');
    return buffer.toString();
  }
}
