class MemberSettlementSummary {
  final String userId;
  final String userName;
  final double mealsEaten;
  final double amountOwed;
  final double depositTotal;
  final double balance; // depositTotal - amountOwed

  const MemberSettlementSummary({
    required this.userId,
    required this.userName,
    required this.mealsEaten,
    required this.amountOwed,
    required this.depositTotal,
    required this.balance,
  });

  bool get isOwedToMember => balance >= 0;
}
