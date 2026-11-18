class PatientHomeException implements Exception {
  const PatientHomeException(this.message);

  final String message;

  @override
  String toString() => message;
}
