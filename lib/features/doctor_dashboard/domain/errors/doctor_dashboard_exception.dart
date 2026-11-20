class DoctorDashboardException implements Exception {
  const DoctorDashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
