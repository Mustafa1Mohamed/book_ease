import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_specialty.dart';
import '../../domain/errors/admin_specialty_exception.dart';
import '../models/admin_specialty_model.dart';
import '../utils/specialty_name_policy.dart';

class AdminSpecialtyRemoteDataSource {
  const AdminSpecialtyRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

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
      debugPrint('Admin specialty list read failed (${error.code}).');
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
      debugPrint('Admin specialty doctor count failed (${error.code}).');
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
      final trimmedName = name.trim();
      final normalizedName = normalizeSpecialtyName(trimmedName);
      if (trimmedName.isEmpty ||
          normalizedName.isEmpty ||
          trimmedName.length > 100 ||
          nameAr.trim().isEmpty ||
          nameAr.trim().length > 100 ||
          description.trim().length > 2000 ||
          descriptionAr.trim().length > 2000 ||
          !const {
            'medical',
            'heart',
            'dental',
            'skin',
            'neurology',
            'pediatrics',
            'orthopedics',
          }.contains(iconName)) {
        throw const AdminSpecialtyException('invalid-argument');
      }

      final collection = _firestore.collection('specialties');
      final snapshot = await collection.get();
      for (final document in snapshot.docs) {
        if (document.id == specialtyId) continue;
        if (specialtyNamesConflict(
          existingData: document.data(),
          name: trimmedName,
          nameAr: nameAr.trim(),
        )) {
          throw const AdminSpecialtyException('already-exists');
        }
      }

      final currentSnapshot = specialtyId == null
          ? null
          : await collection.doc(specialtyId).get();
      if (specialtyId != null && !currentSnapshot!.exists) {
        throw const AdminSpecialtyException('not-found');
      }
      final currentData = currentSnapshot?.data() ?? const <String, dynamic>{};
      final imageUrl = clearImage ? '' : _string(currentData['imageUrl']);
      final data = <String, dynamic>{
        'name': trimmedName,
        'nameLower': normalizedName,
        'nameAr': nameAr.trim(),
        'description': description.trim(),
        'descriptionAr': descriptionAr.trim(),
        'iconName': iconName,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        if (currentData.containsKey('createdAt'))
          'createdAt': currentData['createdAt'],
      };
      if (specialtyId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        final created = await collection.add(data);
        final createdSnapshot = await created.get();
        return AdminSpecialtyModel.fromSnapshot(createdSnapshot);
      }

      final document = collection.doc(specialtyId);
      await document.update(data);
      return AdminSpecialtyModel.fromSnapshot(await document.get());
    } on FirebaseException catch (error) {
      debugPrint('Admin specialty save failed (${error.code}).');
      throw AdminSpecialtyException(error.code);
    }
  }

  Future<void> setActive({
    required String specialtyId,
    required bool isActive,
  }) async {
    try {
      final document = _firestore.collection('specialties').doc(specialtyId);
      final snapshot = await document.get();
      if (!snapshot.exists) {
        throw const AdminSpecialtyException('not-found');
      }
      final current = snapshot.data() ?? const <String, dynamic>{};
      final updated = <String, dynamic>{
        'name': _string(current['name']),
        'nameLower': normalizeSpecialtyName(
          current['nameLower'] is String
              ? current['nameLower'] as String
              : _string(current['name']),
        ),
        'nameAr': _string(current['nameAr']),
        'description': _string(current['description']),
        'descriptionAr': _string(current['descriptionAr']),
        'iconName': _string(current['iconName']).isEmpty
            ? 'medical'
            : _string(current['iconName']),
        'imageUrl': _string(current['imageUrl']),
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        if (current.containsKey('createdAt')) 'createdAt': current['createdAt'],
      };
      await document.update(updated);
    } on FirebaseException catch (error) {
      debugPrint('Admin specialty activation failed (${error.code}).');
      throw AdminSpecialtyException(error.code);
    } on AdminSpecialtyException {
      rethrow;
    }
  }

  String _string(Object? value) => value is String ? value.trim() : '';
}
