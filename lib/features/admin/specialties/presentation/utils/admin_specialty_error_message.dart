import '../../../../../core/localization/generated/app_localizations.dart';

String adminSpecialtyErrorMessage(AppLocalizations l10n, String code) =>
    switch (code) {
      'already-exists' => l10n.adminSpecialtyDuplicateName,
      'permission-denied' => l10n.adminSpecialtyPermissionDenied,
      'unauthenticated' => l10n.adminSpecialtySessionExpired,
      'unavailable' ||
      'deadline-exceeded' ||
      'network-request-failed' ||
      'cancelled' => l10n.adminSpecialtyNetworkError,
      'not-found' => l10n.adminSpecialtyServiceUnavailable,
      'invalid-argument' ||
      'failed-precondition' => l10n.adminSpecialtyValidationError,
      _ => l10n.adminSpecialtyUnexpectedError,
    };
