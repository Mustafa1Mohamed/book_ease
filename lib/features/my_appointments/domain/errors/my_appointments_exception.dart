class MyAppointmentsException implements Exception {
  const MyAppointmentsException(this.message);

  final String message;

  @override
  String toString() => message;
}
