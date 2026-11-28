String normalizeSpecialtyName(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

bool specialtyNamesConflict({
  required Map<String, dynamic> existingData,
  required String name,
  required String nameAr,
}) {
  final requestedNames = {
    normalizeSpecialtyName(name),
    normalizeSpecialtyName(nameAr),
  };
  final existingNames = {
    normalizeSpecialtyName(
      existingData['nameLower'] is String
          ? existingData['nameLower'] as String
          : _string(existingData['name']),
    ),
    normalizeSpecialtyName(_string(existingData['nameAr'])),
  };
  return existingNames.any(
    (existingName) =>
        existingName.isNotEmpty && requestedNames.contains(existingName),
  );
}

String _string(Object? value) => value is String ? value.trim() : '';
