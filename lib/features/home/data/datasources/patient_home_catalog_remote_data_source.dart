import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/featured_doctor.dart';
import '../../domain/entities/home_catalog_data.dart';
import '../../domain/entities/home_section_data.dart';
import '../../domain/entities/medical_specialty.dart';
import '../models/featured_doctor_model.dart';
import '../models/medical_specialty_model.dart';

class PatientHomeCatalogRemoteDataSource {
  const PatientHomeCatalogRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<HomeCatalogData> loadCatalog() async {
    final results =
        await Future.wait<_QueryResult<QuerySnapshot<Map<String, dynamic>>>>([
          _read(_firestore.collection('specialties').get()),
          _read(
            _firestore
                .collection('doctors')
                .where('isFeatured', isEqualTo: true)
                .where('approvalStatus', isEqualTo: 'approved')
                .where('administrativeStatus', isEqualTo: 'active')
                .get(),
          ),
        ]);

    final specialties =
        (results[0].value?.docs ?? [])
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
    final specialtyNamesAr = {
      for (final specialty in specialties) specialty.id: specialty.nameAr,
    };
    final doctors = (results[1].value?.docs ?? [])
        .map(
          (document) => FeaturedDoctorModel.fromMap(
            document.id,
            document.data(),
            specialtyNamesById: specialtyNames,
            specialtyNamesArById: specialtyNamesAr,
          ),
        )
        .whereType<FeaturedDoctor>()
        .toList();

    return HomeCatalogData(
      specialties: HomeSectionData(
        value: specialties,
        hasError: results[0].hasError,
      ),
      featuredDoctors: HomeSectionData(
        value: doctors,
        hasError: results[1].hasError,
      ),
    );
  }

  Future<_QueryResult<T>> _read<T>(Future<T> request) async {
    try {
      return _QueryResult(value: await request);
    } on FirebaseException {
      return const _QueryResult(hasError: true);
    }
  }
}

class _QueryResult<T> {
  const _QueryResult({this.value, this.hasError = false});

  final T? value;
  final bool hasError;
}
