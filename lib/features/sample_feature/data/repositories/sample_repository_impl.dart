import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/sample_entity.dart';
import '../../domain/repositories/sample_repository.dart';
import '../models/sample_model.dart';

class SampleRepositoryImpl implements SampleRepository {
  final FirestoreService _firestoreService;

  SampleRepositoryImpl(this._firestoreService);

  @override
  Future<List<SampleEntity>> getSamples() async {
    // Example implementation using core service
    final snapshot = await _firestoreService.getDocument('samples/test');
    if (snapshot.exists && snapshot.data() != null) {
      return [SampleModel.fromJson(snapshot.data()!)];
    }
    return [];
  }
}
