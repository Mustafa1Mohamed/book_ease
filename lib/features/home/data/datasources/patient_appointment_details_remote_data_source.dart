import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/upcoming_appointment.dart';
import '../models/featured_doctor_model.dart';
import '../models/upcoming_appointment_model.dart';

class PatientAppointmentDetailsRemoteDataSource {
  const PatientAppointmentDetailsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<UpcomingAppointment> loadDetails(
    UpcomingAppointment appointment,
  ) async {
    var enrichedAppointment = appointment;
    final needsDoctorDetails =
        appointment.doctorId.isNotEmpty &&
        (appointment.doctorName.isEmpty ||
            appointment.specialtyName.isEmpty ||
            appointment.doctorImageUrl.isEmpty);
    if (needsDoctorDetails) {
      final doctors = _firestore.collection('doctors');
      final snapshot = await doctors.doc(appointment.doctorId).get();
      var doctorId = snapshot.id;
      var data = snapshot.data();
      if (data == null) {
        final matchingDoctors = await doctors
            .where('uid', isEqualTo: appointment.doctorId)
            .limit(1)
            .get();
        if (matchingDoctors.docs.isNotEmpty) {
          final doctorDocument = matchingDoctors.docs.first;
          doctorId = doctorDocument.id;
          data = doctorDocument.data();
        }
      }

      final doctor = data == null
          ? null
          : FeaturedDoctorModel.fromMap(
              doctorId,
              data,
              specialtyNamesById: const {},
            );
      enrichedAppointment = UpcomingAppointmentModel.withDoctor(
        appointment,
        doctor,
      );
    }

    if (enrichedAppointment.specialtyName.isNotEmpty ||
        enrichedAppointment.specialtyId.isEmpty) {
      return enrichedAppointment;
    }

    final specialty = await _firestore
        .collection('specialties')
        .doc(enrichedAppointment.specialtyId)
        .get();
    final name = specialty.data()?['name'];
    return UpcomingAppointmentModel.withSpecialtyName(
      enrichedAppointment,
      name is String ? name.trim() : '',
    );
  }
}
