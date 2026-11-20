enum AppointmentCategory {
  upcoming('Upcoming'),
  completed('Completed'),
  cancelled('Cancelled');

  const AppointmentCategory(this.label);

  final String label;
}
