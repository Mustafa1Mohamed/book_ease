import 'package:book_ease/features/admin/specialties/data/utils/specialty_name_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes names and checks duplicates including legacy records', () {
    expect(normalizeSpecialtyName('  CARDIOLOGY   Care '), 'cardiology care');
    expect(
      specialtyNamesConflict(
        existingData: {'name': 'Cardiology', 'nameAr': 'أمراض القلب'},
        name: ' cardiology ',
        nameAr: 'القلب',
      ),
      isTrue,
    );
    expect(
      specialtyNamesConflict(
        existingData: {
          'name': 'Heart care',
          'nameLower': 'heart care',
          'nameAr': 'رعاية القلب',
        },
        name: 'New specialty',
        nameAr: 'Heart care',
      ),
      isTrue,
    );
    expect(
      specialtyNamesConflict(
        existingData: {'name': 'Cardiology', 'nameAr': 'أمراض القلب'},
        name: 'Neurology',
        nameAr: 'الأعصاب',
      ),
      isFalse,
    );
  });
}
