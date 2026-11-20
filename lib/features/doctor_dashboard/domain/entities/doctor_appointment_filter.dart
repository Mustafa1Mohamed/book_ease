enum DoctorAppointmentFilter {
  all('All'),
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const DoctorAppointmentFilter(this.label);

  final String label;

  bool matches(String status) {
    final normalized = status.trim().toLowerCase();
    return switch (this) {
      DoctorAppointmentFilter.all => true,
      DoctorAppointmentFilter.pending => normalized == 'pending',
      DoctorAppointmentFilter.confirmed =>
        normalized == 'confirmed' ||
            normalized == 'scheduled' ||
            normalized == 'booked',
      DoctorAppointmentFilter.completed => normalized == 'completed',
      DoctorAppointmentFilter.cancelled =>
        normalized == 'cancelled' ||
            normalized == 'canceled' ||
            normalized == 'rejected',
    };
  }
}
