import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/home_catalog_data.dart';
import '../../domain/entities/patient_home_data.dart';
import '../../domain/errors/patient_home_exception.dart';
import 'patient_home_data_source.dart';
import '../models/patient_profile_model.dart';
import 'patient_home_appointments_remote_data_source.dart';
import 'patient_home_catalog_remote_data_source.dart';

class PatientHomeRemoteDataSource implements PatientHomeDataSource {
  const PatientHomeRemoteDataSource({
    required FirebaseAuth firebaseAuthInstance,
    required FirebaseFirestore firestoreInstance,
    required PatientHomeCatalogRemoteDataSource catalogSource,
    required PatientHomeAppointmentsRemoteDataSource appointmentSource,
  }) : _firebaseAuth = firebaseAuthInstance,
       _firestore = firestoreInstance,
       _catalogDataSource = catalogSource,
       _appointmentsDataSource = appointmentSource;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final PatientHomeCatalogRemoteDataSource _catalogDataSource;
  final PatientHomeAppointmentsRemoteDataSource _appointmentsDataSource;

  @override
  Future<PatientHomeData> loadHomeData() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const PatientHomeException('Please sign in again to continue.');
    }

    final profileSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final profileData = profileSnapshot.data();
    if (profileData == null) {
      throw const PatientHomeException(
        'Your patient profile could not be found. Please sign in again.',
      );
    }

    final profile = PatientProfileModel.fromMap(
      profileData,
      fallbackName: user.displayName ?? '',
    );
    if (profile.role != 'patient') {
      throw const PatientHomeException(
        'This home screen is only available to patient accounts.',
      );
    }

    final catalogFuture = _catalogDataSource.loadCatalog();
    final appointmentFuture = _appointmentsDataSource.loadUpcoming(user.uid);
    final HomeCatalogData catalog = await catalogFuture;
    final appointment = await appointmentFuture;

    return PatientHomeData(
      profile: profile,
      specialties: catalog.specialties,
      featuredDoctors: catalog.featuredDoctors,
      upcomingAppointment: appointment,
    );
  }
}
