import '../../../home/domain/entities/featured_doctor.dart';
import '../../../my_appointments/domain/entities/my_appointment.dart';

class DoctorDashboardData {
  const DoctorDashboardData({
    required this.doctor,
    required this.appointments,
  });

  final FeaturedDoctor doctor;
  final List<MyAppointment> appointments;
}
