import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:book_ease/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:book_ease/features/auth/domain/repositories/auth_repository.dart';
import 'package:book_ease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:book_ease/features/home/data/datasources/patient_appointment_details_remote_data_source.dart';
import 'package:book_ease/features/home/data/datasources/patient_home_appointments_remote_data_source.dart';
import 'package:book_ease/features/home/data/datasources/patient_home_catalog_remote_data_source.dart';
import 'package:book_ease/features/home/data/datasources/patient_home_data_source.dart';
import 'package:book_ease/features/home/data/datasources/patient_home_remote_data_source.dart';
import 'package:book_ease/features/home/data/repositories/patient_home_repository_impl.dart';
import 'package:book_ease/features/home/domain/repositories/patient_home_repository.dart';
import 'package:book_ease/features/home/domain/usecases/get_patient_home_data.dart';
import 'package:book_ease/features/home/presentation/cubit/patient_home_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (getIt.isRegistered<FirebaseAuth>() &&
      getIt.isRegistered<AuthCubit>() &&
      getIt.isRegistered<PatientHomeCubit>()) {
    return;
  }

  // Firebase
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  if (!getIt.isRegistered<FirebaseStorage>()) {
    getIt.registerLazySingleton<FirebaseStorage>(
      () => FirebaseStorage.instance,
    );
  }

  // Local Storage
  if (!getIt.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  if (!getIt.isRegistered<LocaleCubit>()) {
    getIt.registerFactory<LocaleCubit>(
      () => LocaleCubit(getIt<SharedPreferences>()),
    );
  }

  await GoogleSignIn.instance.initialize();

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        firebaseAuth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        repository: getIt<AuthRepository>(),
        firebaseAuth: getIt<FirebaseAuth>(),
      ),
    );
  }

  if (!getIt.isRegistered<PatientHomeRemoteDataSource>()) {
    getIt.registerLazySingleton<PatientHomeRemoteDataSource>(
      () => PatientHomeRemoteDataSource(
        firebaseAuthInstance: getIt<FirebaseAuth>(),
        firestoreInstance: getIt<FirebaseFirestore>(),
        catalogSource: getIt<PatientHomeCatalogRemoteDataSource>(),
        appointmentSource: getIt<PatientHomeAppointmentsRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<PatientHomeCatalogRemoteDataSource>()) {
    getIt.registerLazySingleton<PatientHomeCatalogRemoteDataSource>(
      () => PatientHomeCatalogRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }

  if (!getIt.isRegistered<PatientHomeAppointmentsRemoteDataSource>()) {
    getIt.registerLazySingleton<PatientHomeAppointmentsRemoteDataSource>(
      () => PatientHomeAppointmentsRemoteDataSource(
        database: getIt<FirebaseFirestore>(),
        detailLoader: getIt<PatientAppointmentDetailsRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<PatientAppointmentDetailsRemoteDataSource>()) {
    getIt.registerLazySingleton<PatientAppointmentDetailsRemoteDataSource>(
      () => PatientAppointmentDetailsRemoteDataSource(
        getIt<FirebaseFirestore>(),
      ),
    );
  }

  if (!getIt.isRegistered<PatientHomeRepository>()) {
    getIt.registerLazySingleton<PatientHomeRepository>(
      () => PatientHomeRepositoryImpl(getIt<PatientHomeDataSource>()),
    );
  }

  if (!getIt.isRegistered<PatientHomeDataSource>()) {
    getIt.registerLazySingleton<PatientHomeDataSource>(
      () => getIt<PatientHomeRemoteDataSource>(),
    );
  }

  if (!getIt.isRegistered<GetPatientHomeData>()) {
    getIt.registerLazySingleton<GetPatientHomeData>(
      () => GetPatientHomeData(getIt<PatientHomeRepository>()),
    );
  }

  if (!getIt.isRegistered<PatientHomeCubit>()) {
    getIt.registerFactory<PatientHomeCubit>(
      () => PatientHomeCubit(getIt<GetPatientHomeData>()),
    );
  }
}
