import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/admin_specialty.dart';
import '../../domain/errors/admin_specialty_exception.dart';
import '../models/admin_specialty_model.dart';

class AdminSpecialtyRemoteDataSource {
  AdminSpecialtyRemoteDataSource(
    this._firestore, {
    FirebaseFunctions? functions,
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<List<AdminSpecialty>> getAll() async {
    try {
      final snapshot = await _firestore.collection('specialties').get();
      final specialties = snapshot.docs
          .map(AdminSpecialtyModel.fromSnapshot)
          .toList();
      specialties.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
      return specialties;
    } on FirebaseException catch (error) {
      throw AdminSpecialtyException(error.code);
    }
  }

  Future<int> getDoctorCount(String specialtyId) async {
    try {
      final result = await _firestore
          .collection('doctors')
          .where('specialtyId', isEqualTo: specialtyId)
          .count()
          .get();
      final count = result.count;
      if (count == null) {
        throw const AdminSpecialtyException('unavailable');
      }
      return count;
    } on FirebaseException catch (error) {
      throw AdminSpecialtyException(error.code);
    }
  }

  Future<AdminSpecialty> save({
    String? specialtyId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required String iconName,
    required bool isActive,
    required bool clearImage,
  }) async {
    try {
      final result = await _functions.httpsCallable('saveSpecialty').call({
        'specialtyId': ?specialtyId,
        'name': name.trim(),
        'nameAr': nameAr.trim(),
        'description': description.trim(),
        'descriptionAr': descriptionAr.trim(),
        'iconName': iconName,
        'isActive': isActive,
        'clearImage': clearImage,
      });
      final response = result.data;
      final savedSpecialtyId = response is Map ? response['specialtyId'] : null;
      if (savedSpecialtyId is! String || savedSpecialtyId.isEmpty) {
        throw const AdminSpecialtyException('data-loss');
      }
      final snapshot = await _firestore
          .collection('specialties')
          .doc(savedSpecialtyId)
          .get();
      if (!snapshot.exists) {
        throw const AdminSpecialtyException('not-found');
      }
      return AdminSpecialtyModel.fromSnapshot(snapshot);
    } on FirebaseFunctionsException catch (error) {
      throw AdminSpecialtyException(error.code);
    } on FirebaseException catch (error) {
      throw AdminSpecialtyException(error.code);
    }
  }

  Future<void> setActive({
    required String specialtyId,
    required bool isActive,
  }) async {
    try {
      await _functions.httpsCallable('setSpecialtyActive').call({
        'specialtyId': specialtyId,
        'isActive': isActive,
      });
    } on FirebaseFunctionsException catch (error) {
      throw AdminSpecialtyException(error.code);
    }
  }
}
