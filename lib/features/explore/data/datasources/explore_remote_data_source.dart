import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../home/data/models/featured_doctor_model.dart';
import '../../../home/data/models/medical_specialty_model.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/domain/entities/home_section_data.dart';
import '../../../home/domain/entities/medical_specialty.dart';
import '../../domain/entities/explore_catalog.dart';
import 'explore_data_source.dart';

class ExploreRemoteDataSource implements ExploreDataSource {
  const ExploreRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<ExploreCatalog> loadCatalog() async {
    final results = await Future.wait<_QueryResult>([
      _loadQuery(_firestore.collection('specialties').get()),
      _loadQuery(
        _firestore
            .collection('doctors')
            .where('approvalStatus', isEqualTo: 'approved')
            .where('administrativeStatus', isEqualTo: 'active')
            .get(),
      ),
    ]);

    final specialties =
        (results[0].documents ?? [])
            .map(
              (document) =>
                  MedicalSpecialtyModel.fromMap(document.id, document.data()),
            )
            .whereType<MedicalSpecialty>()
            .toList()
          ..sort((first, second) => first.name.compareTo(second.name));
    final specialtyNames = {
      for (final specialty in specialties) specialty.id: specialty.name,
    };
    final doctors = (results[1].documents ?? [])
        .map(
          (document) => FeaturedDoctorModel.fromMap(
            document.id,
            document.data(),
            specialtyNamesById: specialtyNames,
          ),
        )
        .whereType<FeaturedDoctor>()
        .toList();

    return ExploreCatalog(
      specialties: HomeSectionData(
        value: specialties,
        hasError: results[0].hasError,
      ),
      doctors: HomeSectionData(value: doctors, hasError: results[1].hasError),
    );
  }

  Future<_QueryResult> _loadQuery(
    Future<QuerySnapshot<Map<String, dynamic>>> query,
  ) async {
    try {
      final result = await query;
      return _QueryResult(documents: result.docs);
    } on FirebaseException {
      return const _QueryResult(hasError: true);
    }
  }
}

class _QueryResult {
  const _QueryResult({this.documents, this.hasError = false});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>>? documents;
  final bool hasError;
}
