class MealSelectionEntity {
  final String id;
  final String messId;
  final String userId;
  final String userName;
  final String date; // YYYY-MM-DD
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final DateTime? updatedAt;

  const MealSelectionEntity({
    required this.id,
    required this.messId,
    required this.userId,
    required this.userName,
    required this.date,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
    this.updatedAt,
  });

  double get totalMeals =>
      (breakfast ? 1.0 : 0.0) + (lunch ? 1.0 : 0.0) + (dinner ? 1.0 : 0.0);

  MealSelectionEntity copyWith({
    String? id,
    String? messId,
    String? userId,
    String? userName,
    String? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
    DateTime? updatedAt,
  }) {
    return MealSelectionEntity(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
