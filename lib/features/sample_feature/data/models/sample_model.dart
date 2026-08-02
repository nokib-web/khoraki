import '../../domain/entities/sample_entity.dart';

class SampleModel extends SampleEntity {
  const SampleModel({
    required super.id,
    required super.title,
  });

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    return SampleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
