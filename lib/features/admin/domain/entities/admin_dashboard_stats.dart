import 'package:equatable/equatable.dart';

class AdminDashboardStats extends Equatable {
  const AdminDashboardStats({
    required this.totalPatients,
    required this.totalDoctors,
    required this.pendingDoctors,
    required this.approvedDoctors,
    required this.totalSpecialties,
    required this.totalAppointments,
    required this.upcomingAppointments,
    required this.completedAppointments,
  });

  static const metricCount = 8;

  final int? totalPatients;
  final int? totalDoctors;
  final int? pendingDoctors;
  final int? approvedDoctors;
  final int? totalSpecialties;
  final int? totalAppointments;
  final int? upcomingAppointments;
  final int? completedAppointments;

  int get availableMetricCount => [
    totalPatients,
    totalDoctors,
    pendingDoctors,
    approvedDoctors,
    totalSpecialties,
    totalAppointments,
    upcomingAppointments,
    completedAppointments,
  ].whereType<int>().length;

  bool get hasUnavailableMetrics => availableMetricCount < metricCount;
  bool get hasAvailableMetrics => availableMetricCount > 0;

  @override
  List<Object?> get props => [
    totalPatients,
    totalDoctors,
    pendingDoctors,
    approvedDoctors,
    totalSpecialties,
    totalAppointments,
    upcomingAppointments,
    completedAppointments,
  ];
}
