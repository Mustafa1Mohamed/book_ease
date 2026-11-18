import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/home_section_data.dart';
import '../../domain/entities/upcoming_appointment.dart';
import '../models/upcoming_appointment_model.dart';
import 'patient_appointment_details_remote_data_source.dart';

class PatientHomeAppointmentsRemoteDataSource {
  const PatientHomeAppointmentsRemoteDataSource({
    required FirebaseFirestore database,
    required PatientAppointmentDetailsRemoteDataSource detailLoader,
  }) : _firestore = database,
       _detailsDataSource = detailLoader;

  final FirebaseFirestore _firestore;
  final PatientAppointmentDetailsRemoteDataSource _detailsDataSource;

  Future<HomeSectionData<UpcomingAppointment?>> loadUpcoming(
    String patientId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      final appointments =
          snapshot.docs
              .map(
                (document) => UpcomingAppointmentModel.fromMap(
                  document.id,
                  document.data(),
                ),
              )
              .whereType<UpcomingAppointment>()
              .where(
                (appointment) => UpcomingAppointmentModel.isUpcoming(
                  appointment,
                  DateTime.now(),
                ),
              )
              .toList()
            ..sort(
              (first, second) =>
                  first.scheduledAt.compareTo(second.scheduledAt),
            );
      if (appointments.isEmpty) {
        return const HomeSectionData(value: null);
      }

      final appointment = appointments.first;
      try {
        return HomeSectionData(
          value: await _detailsDataSource.loadDetails(appointment),
        );
      } on FirebaseException {
        return HomeSectionData(value: appointment, hasError: true);
      }
    } on FirebaseException {
      return const HomeSectionData(value: null, hasError: true);
    }
  }

}
