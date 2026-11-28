class DoctorApplicationException implements Exception {
  const DoctorApplicationException(this.message, {this.code = 'unknown'});

  final String message;
  final String code;
}
