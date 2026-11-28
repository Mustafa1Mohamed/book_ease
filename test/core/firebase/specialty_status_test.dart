import 'package:book_ease/core/firebase/specialty_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing status is legacy-active for existing catalog records', () {
    expect(
      specialtyAvailability({'name': 'Legacy'}),
      SpecialtyAvailability.legacyActive,
    );
    expect(specialtyIsAvailableForPatients({'name': 'Legacy'}), isTrue);
  });

  test('only explicit true is active when a status field is present', () {
    expect(
      specialtyAvailability({'isActive': true}),
      SpecialtyAvailability.active,
    );
    expect(
      specialtyAvailability({'isActive': false}),
      SpecialtyAvailability.inactive,
    );
    for (final invalid in [null, 'true', 1]) {
      expect(
        specialtyAvailability({'isActive': invalid}),
        SpecialtyAvailability.invalid,
      );
      expect(specialtyIsAvailableForPatients({'isActive': invalid}), isFalse);
    }
  });
}
