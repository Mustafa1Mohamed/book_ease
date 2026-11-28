import 'package:book_ease/core/localization/generated/app_localizations_en.dart';
import 'package:book_ease/core/localization/generated/app_localizations_ar.dart';
import 'package:book_ease/features/admin/specialties/presentation/utils/admin_specialty_error_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final l10nAr = AppLocalizationsAr();

  test('maps callable and Firestore errors to distinct localized messages', () {
    expect(
      adminSpecialtyErrorMessage(l10n, 'not-found'),
      l10n.adminSpecialtyServiceUnavailable,
    );
    expect(
      adminSpecialtyErrorMessage(l10n, 'permission-denied'),
      l10n.adminSpecialtyPermissionDenied,
    );
    expect(
      adminSpecialtyErrorMessage(l10n, 'unavailable'),
      l10n.adminSpecialtyNetworkError,
    );
    expect(
      adminSpecialtyErrorMessage(l10n, 'already-exists'),
      l10n.adminSpecialtyDuplicateName,
    );
    expect(
      adminSpecialtyErrorMessage(l10n, 'invalid-argument'),
      l10n.adminSpecialtyValidationError,
    );
    expect(
      adminSpecialtyErrorMessage(l10n, 'internal'),
      l10n.adminSpecialtyUnexpectedError,
    );
  });

  test('shows a localized deployment diagnostic in Arabic', () {
    expect(
      adminSpecialtyErrorMessage(l10nAr, 'not-found'),
      l10nAr.adminSpecialtyServiceUnavailable,
    );
  });
}
