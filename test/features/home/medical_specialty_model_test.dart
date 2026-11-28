import 'package:book_ease/features/home/data/models/medical_specialty_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses bilingual legacy specialties as available', () {
    final specialty = MedicalSpecialtyModel.fromMap('cardiology', {
      'name': 'Cardiology',
      'nameAr': 'أمراض القلب',
      'iconName': 'heart',
    });

    expect(specialty?.name, 'Cardiology');
    expect(specialty?.nameAr, 'أمراض القلب');
  });

  test('excludes inactive or malformed records from discovery', () {
    for (final status in [false, null, 'active', 1]) {
      expect(
        MedicalSpecialtyModel.fromMap('hidden', {
          'name': 'Hidden',
          'isActive': status,
        }),
        isNull,
      );
    }
  });
}
