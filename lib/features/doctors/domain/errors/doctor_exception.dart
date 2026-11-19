class DoctorException implements Exception {
  const DoctorException(this.message);

  final String message;

  @override
  String toString() => message;
}
