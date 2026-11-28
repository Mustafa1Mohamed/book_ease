import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_specialty.dart';

abstract final class AdminSpecialtyModel {
  static AdminSpecialty fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final rawAvailability = data.containsKey('isActive')
        ? data['isActive']
        : null;
    final availability = !data.containsKey('isActive')
        ? SpecialtyStatus.legacyActive
        : switch (rawAvailability) {
            true => SpecialtyStatus.active,
            false => SpecialtyStatus.inactive,
            _ => SpecialtyStatus.invalid,
          };
    return AdminSpecialty(
      id: snapshot.id,
      name: _string(data['name']),
      nameAr: _string(data['nameAr']),
      description: _string(data['description']),
      descriptionAr: _string(data['descriptionAr']),
      imageUrl: _string(data['imageUrl']),
      iconName: _string(data['iconName']).isEmpty
          ? 'medical'
          : _string(data['iconName']),
      availability: availability,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static DateTime? _date(Object? value) => switch (value) {
    Timestamp value => value.toDate(),
    DateTime value => value,
    _ => null,
  };
}
