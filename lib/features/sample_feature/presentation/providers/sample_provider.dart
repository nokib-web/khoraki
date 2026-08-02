import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../data/repositories/sample_repository_impl.dart';
import '../../domain/repositories/sample_repository.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final sampleRepositoryProvider = Provider<SampleRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SampleRepositoryImpl(firestoreService);
});
