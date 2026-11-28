import '../../../../core/firebase/specialty_status.dart';
import '../../domain/entities/medical_specialty.dart';

abstract final class MedicalSpecialtyModel {
  static MedicalSpecialty? fromMap(String id, Map<String, dynamic> data) {
    final name = _string(data['name']).trim();
    if (name.isEmpty || !specialtyIsAvailableForPatients(data)) return null;

    return MedicalSpecialty(
      id: id,
      name: name,
      nameAr: _string(data['nameAr']).trim(),
      imageUrl: _string(data['imageUrl']),
      iconName: _string(data['iconName']),
    );
  }

  static String _string(Object? value) => value is String ? value : '';
}
