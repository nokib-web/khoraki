import '../../domain/entities/member_settlement_summary.dart';
import '../../domain/entities/settlement_entity.dart';

class MemberSettlementSummaryModel extends MemberSettlementSummary {
  const MemberSettlementSummaryModel({
    required super.userId,
    required super.userName,
    required super.mealsEaten,
    required super.amountOwed,
    required super.depositTotal,
    required super.balance,
  });

  factory MemberSettlementSummaryModel.fromJson(Map<String, dynamic> json) {
    return MemberSettlementSummaryModel(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Member',
      mealsEaten: (json['mealsEaten'] as num?)?.toDouble() ?? 0.0,
      amountOwed: (json['amountOwed'] as num?)?.toDouble() ?? 0.0,
      depositTotal: (json['depositTotal'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'mealsEaten': mealsEaten,
      'amountOwed': amountOwed,
      'depositTotal': depositTotal,
      'balance': balance,
    };
  }
}

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.messId,
    required super.yearMonth,
    required super.totalMeals,
    required super.totalBazarCost,
    required super.mealRate,
    required super.closedByUserId,
    required super.closedByUserName,
    required super.closedAt,
    required super.memberSummaries,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final summariesList = (json['memberSummaries'] as List<dynamic>?)
            ?.map((e) => MemberSettlementSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SettlementModel(
      id: docId ?? json['id'] as String? ?? '',
      messId: json['messId'] as String? ?? '',
      yearMonth: json['yearMonth'] as String? ?? '',
      totalMeals: (json['totalMeals'] as num?)?.toDouble() ?? 0.0,
      totalBazarCost: (json['totalBazarCost'] as num?)?.toDouble() ?? 0.0,
      mealRate: (json['mealRate'] as num?)?.toDouble() ?? 0.0,
      closedByUserId: json['closedByUserId'] as String? ?? '',
      closedByUserName: json['closedByUserName'] as String? ?? 'Manager',
      closedAt: json['closedAt'] != null
          ? DateTime.tryParse(json['closedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      memberSummaries: summariesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messId': messId,
      'yearMonth': yearMonth,
      'totalMeals': totalMeals,
      'totalBazarCost': totalBazarCost,
      'mealRate': mealRate,
      'closedByUserId': closedByUserId,
      'closedByUserName': closedByUserName,
      'closedAt': closedAt.toIso8601String(),
      'memberSummaries': memberSummaries
          .map((m) => MemberSettlementSummaryModel(
                userId: m.userId,
                userName: m.userName,
                mealsEaten: m.mealsEaten,
                amountOwed: m.amountOwed,
                depositTotal: m.depositTotal,
                balance: m.balance,
              ).toJson())
          .toList(),
    };
  }
}
