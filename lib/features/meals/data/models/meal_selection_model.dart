import '../../domain/entities/meal_selection_entity.dart';

class MealSelectionModel extends MealSelectionEntity {
  const MealSelectionModel({
    required super.id,
    required super.messId,
    required super.userId,
    required super.userName,
    required super.date,
    super.breakfast = false,
    super.lunch = false,
    super.dinner = false,
    super.updatedAt,
  });

  factory MealSelectionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return MealSelectionModel(
      id: docId ?? json['id'] as String? ?? '',
      messId: json['messId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Member',
      date: json['date'] as String? ?? '',
      breakfast: json['breakfast'] as bool? ?? false,
      lunch: json['lunch'] as bool? ?? false,
      dinner: json['dinner'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messId': messId,
      'userId': userId,
      'userName': userName,
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
