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
import 'package:book_ease/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:book_ease/features/explore/data/datasources/explore_data_source.dart';
import 'package:book_ease/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:book_ease/features/explore/domain/repositories/explore_repository.dart';
import 'package:book_ease/features/explore/domain/usecases/get_explore_catalog.dart';
import 'package:book_ease/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:book_ease/features/doctors/data/datasources/doctor_remote_data_source.dart';
import 'package:book_ease/features/doctors/data/repositories/doctor_repository_impl.dart';
import 'package:book_ease/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:book_ease/features/doctors/domain/usecases/get_doctor_details.dart';
import 'package:book_ease/features/doctors/presentation/cubit/doctor_details_cubit.dart';
import 'package:book_ease/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:book_ease/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:book_ease/features/booking/domain/repositories/booking_repository.dart';
import 'package:book_ease/features/booking/domain/usecases/book_appointment.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_dates.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_slots.dart';
import 'package:book_ease/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:book_ease/features/profile/data/datasources/profile_image_picker_data_source.dart';
import 'package:book_ease/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:book_ease/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:book_ease/features/profile/domain/repositories/profile_repository.dart';
import 'package:book_ease/features/profile/domain/usecases/get_current_profile.dart';
import 'package:book_ease/features/profile/domain/usecases/pick_and_upload_profile_image.dart';
import 'package:book_ease/features/profile/domain/usecases/update_profile.dart';
import 'package:book_ease/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:book_ease/features/my_appointments/data/datasources/my_appointments_remote_data_source.dart';
import 'package:book_ease/features/my_appointments/data/repositories/my_appointments_repository_impl.dart';
import 'package:book_ease/features/my_appointments/domain/repositories/my_appointments_repository.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_cancellation_policy.dart';
import 'package:book_ease/features/my_appointments/domain/services/appointment_category_policy.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/cancel_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/get_my_appointment.dart';
import 'package:book_ease/features/my_appointments/domain/usecases/get_my_appointments.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/appointment_details_cubit.dart';
import 'package:book_ease/features/my_appointments/presentation/cubit/my_appointments_cubit.dart';
import 'package:book_ease/features/doctor_dashboard/data/datasources/doctor_dashboard_remote_data_source.dart';
import 'package:book_ease/features/doctor_dashboard/data/repositories/doctor_dashboard_repository_impl.dart';
import 'package:book_ease/features/doctor_dashboard/domain/repositories/doctor_dashboard_repository.dart';
import 'package:book_ease/features/doctor_dashboard/domain/services/doctor_appointment_policy.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/complete_doctor_appointment.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/get_doctor_appointment.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/get_doctor_dashboard.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_appointment_details_cubit.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:book_ease/features/doctor_profile/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:book_ease/features/doctor_profile/data/repositories/doctor_profile_repository_impl.dart';
import 'package:book_ease/features/doctor_profile/domain/repositories/doctor_profile_repository.dart';
import 'package:book_ease/features/doctor_profile/presentation/cubit/doctor_profile_cubit.dart';
import 'package:book_ease/features/doctor_applications/data/datasources/doctor_application_remote_data_source.dart';
import 'package:book_ease/features/doctor_applications/data/repositories/doctor_application_repository_impl.dart';
import 'package:book_ease/features/doctor_applications/domain/repositories/doctor_application_repository.dart';
import 'package:book_ease/features/doctor_applications/presentation/cubit/doctor_application_cubit.dart';
import 'package:book_ease/features/doctor_applications/presentation/cubit/admin_doctor_applications_cubit.dart';
import 'package:book_ease/features/admin/data/datasources/admin_dashboard_remote_data_source.dart';
import 'package:book_ease/features/admin/data/repositories/admin_dashboard_repository_impl.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:book_ease/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_actions_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_actions_remote_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_details_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_details_remote_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_list_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_doctor_remote_data_source.dart';
import 'package:book_ease/features/admin/data/repositories/admin_doctor_repository_impl.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_doctor_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_doctor_details_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_doctor_list_cubit.dart';
import 'package:book_ease/features/admin/data/datasources/admin_patient_data_source.dart';
import 'package:book_ease/features/admin/data/datasources/admin_patient_remote_data_source.dart';
import 'package:book_ease/features/admin/data/repositories/admin_patient_repository_impl.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_patient_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_details_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_list_cubit.dart';
import 'package:book_ease/features/admin/specialties/data/datasources/admin_specialty_remote_data_source.dart';
import 'package:book_ease/features/admin/specialties/data/repositories/admin_specialty_repository_impl.dart';
import 'package:book_ease/features/admin/specialties/domain/repositories/admin_specialty_repository.dart';
import 'package:book_ease/features/admin/specialties/presentation/cubit/admin_specialties_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (getIt.isRegistered<FirebaseAuth>() &&
      getIt.isRegistered<AuthCubit>() &&
      getIt.isRegistered<PatientHomeCubit>() &&
      getIt.isRegistered<ExploreCubit>() &&
      getIt.isRegistered<DoctorDetailsCubit>() &&
      getIt.isRegistered<BookingCubit>() &&
      getIt.isRegistered<ProfileCubit>() &&
      getIt.isRegistered<MyAppointmentsCubit>() &&
      getIt.isRegistered<AppointmentDetailsCubit>() &&
      getIt.isRegistered<DoctorDashboardCubit>() &&
      getIt.isRegistered<DoctorAppointmentDetailsCubit>() &&
      getIt.isRegistered<DoctorProfileCubit>() &&
      getIt.isRegistered<DoctorApplicationCubit>() &&
      getIt.isRegistered<AdminDoctorApplicationsCubit>() &&
      getIt.isRegistered<AdminDoctorApplicationDetailsCubit>() &&
      getIt.isRegistered<AdminDashboardCubit>() &&
      getIt.isRegistered<AdminDoctorListCubit>() &&
      getIt.isRegistered<AdminDoctorDetailsCubit>() &&
      getIt.isRegistered<AdminPatientListCubit>() &&
      getIt.isRegistered<AdminPatientDetailsCubit>() &&
      getIt.isRegistered<AdminSpecialtiesCubit>()) {
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
      () =>
          PatientAppointmentDetailsRemoteDataSource(getIt<FirebaseFirestore>()),
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

  if (!getIt.isRegistered<ExploreRemoteDataSource>()) {
    getIt.registerLazySingleton<ExploreRemoteDataSource>(
      () => ExploreRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }

  if (!getIt.isRegistered<ExploreDataSource>()) {
    getIt.registerLazySingleton<ExploreDataSource>(
      () => getIt<ExploreRemoteDataSource>(),
    );
  }

  if (!getIt.isRegistered<ExploreRepository>()) {
    getIt.registerLazySingleton<ExploreRepository>(
      () => ExploreRepositoryImpl(getIt<ExploreDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetExploreCatalog>()) {
    getIt.registerLazySingleton<GetExploreCatalog>(
      () => GetExploreCatalog(getIt<ExploreRepository>()),
    );
  }

  if (!getIt.isRegistered<ExploreCubit>()) {
    getIt.registerFactory<ExploreCubit>(
      () => ExploreCubit(getIt<GetExploreCatalog>()),
    );
  }

  if (!getIt.isRegistered<DoctorRemoteDataSource>()) {
    getIt.registerLazySingleton<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }

  if (!getIt.isRegistered<DoctorRepository>()) {
    getIt.registerLazySingleton<DoctorRepository>(
      () => DoctorRepositoryImpl(getIt<DoctorRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetDoctorDetails>()) {
    getIt.registerLazySingleton<GetDoctorDetails>(
      () => GetDoctorDetails(getIt<DoctorRepository>()),
    );
  }

  if (!getIt.isRegistered<DoctorDetailsCubit>()) {
    getIt.registerFactory<DoctorDetailsCubit>(
      () => DoctorDetailsCubit(getIt<GetDoctorDetails>()),
    );
  }

  if (!getIt.isRegistered<BookingRemoteDataSource>()) {
    getIt.registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>(),
      ),
    );
  }

  if (!getIt.isRegistered<BookingRepository>()) {
    getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt<BookingRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAvailableDates>()) {
    getIt.registerLazySingleton<GetAvailableDates>(
      () => GetAvailableDates(getIt<BookingRepository>()),
    );
  }

  if (!getIt.isRegistered<GetAvailableSlots>()) {
    getIt.registerLazySingleton<GetAvailableSlots>(
      () => GetAvailableSlots(getIt<BookingRepository>()),
    );
  }

  if (!getIt.isRegistered<BookAppointment>()) {
    getIt.registerLazySingleton<BookAppointment>(
      () => BookAppointment(getIt<BookingRepository>()),
    );
  }

  if (!getIt.isRegistered<BookingCubit>()) {
    getIt.registerFactory<BookingCubit>(
      () => BookingCubit(
        getIt<GetDoctorDetails>(),
        getIt<GetAvailableDates>(),
        getIt<GetAvailableSlots>(),
        getIt<BookAppointment>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(
        getIt<FirebaseAuth>(),
        getIt<FirebaseFirestore>(),
        Supabase.instance.client,
      ),
    );
  }

  if (!getIt.isRegistered<ProfileImagePickerDataSource>()) {
    getIt.registerLazySingleton<ProfileImagePickerDataSource>(
      () => ProfileImagePickerDataSource(),
    );
  }

  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        getIt<ProfileRemoteDataSource>(),
        getIt<ProfileImagePickerDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetCurrentProfile>()) {
    getIt.registerLazySingleton<GetCurrentProfile>(
      () => GetCurrentProfile(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateProfile>()) {
    getIt.registerLazySingleton<UpdateProfile>(
      () => UpdateProfile(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<PickAndUploadProfileImage>()) {
    getIt.registerLazySingleton<PickAndUploadProfileImage>(
      () => PickAndUploadProfileImage(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<ProfileCubit>()) {
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getIt<GetCurrentProfile>(),
        getIt<UpdateProfile>(),
        getIt<PickAndUploadProfileImage>(),
      ),
    );
  }

  if (!getIt.isRegistered<DoctorProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<DoctorProfileRemoteDataSource>(
      () => DoctorProfileRemoteDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>(),
      ),
    );
  }

  if (!getIt.isRegistered<DoctorProfileRepository>()) {
    getIt.registerLazySingleton<DoctorProfileRepository>(
      () => DoctorProfileRepositoryImpl(
        getIt<DoctorProfileRemoteDataSource>(),
        getIt<ProfileImagePickerDataSource>(),
        getIt<ProfileRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<DoctorProfileCubit>()) {
    getIt.registerFactory<DoctorProfileCubit>(
      () => DoctorProfileCubit(getIt<DoctorProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<AppointmentCategoryPolicy>()) {
    getIt.registerLazySingleton<AppointmentCategoryPolicy>(
      () => const AppointmentCategoryPolicy(),
    );
  }

  if (!getIt.isRegistered<AppointmentCancellationPolicy>()) {
    getIt.registerLazySingleton<AppointmentCancellationPolicy>(
      () => AppointmentCancellationPolicy(),
    );
  }

  if (!getIt.isRegistered<MyAppointmentsRemoteDataSource>()) {
    getIt.registerLazySingleton<MyAppointmentsRemoteDataSource>(
      () => MyAppointmentsRemoteDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>(),
        getIt<AppointmentCancellationPolicy>(),
      ),
    );
  }

  if (!getIt.isRegistered<MyAppointmentsRepository>()) {
    getIt.registerLazySingleton<MyAppointmentsRepository>(
      () =>
          MyAppointmentsRepositoryImpl(getIt<MyAppointmentsRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetMyAppointments>()) {
    getIt.registerLazySingleton<GetMyAppointments>(
      () => GetMyAppointments(getIt<MyAppointmentsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetMyAppointment>()) {
    getIt.registerLazySingleton<GetMyAppointment>(
      () => GetMyAppointment(getIt<MyAppointmentsRepository>()),
    );
  }

  if (!getIt.isRegistered<CancelAppointment>()) {
    getIt.registerLazySingleton<CancelAppointment>(
      () => CancelAppointment(getIt<MyAppointmentsRepository>()),
    );
  }

  if (!getIt.isRegistered<MyAppointmentsCubit>()) {
    getIt.registerFactory<MyAppointmentsCubit>(
      () => MyAppointmentsCubit(
        getIt<GetMyAppointments>(),
        getIt<AppointmentCategoryPolicy>(),
      ),
    );
  }

  if (!getIt.isRegistered<AppointmentDetailsCubit>()) {
    getIt.registerFactory<AppointmentDetailsCubit>(
      () => AppointmentDetailsCubit(
        getIt<GetMyAppointment>(),
        getIt<CancelAppointment>(),
        getIt<AppointmentCancellationPolicy>(),
      ),
    );
  }

  if (!getIt.isRegistered<DoctorAppointmentPolicy>()) {
    getIt.registerLazySingleton<DoctorAppointmentPolicy>(
      () => const DoctorAppointmentPolicy(),
    );
  }

  if (!getIt.isRegistered<DoctorDashboardRemoteDataSource>()) {
    getIt.registerLazySingleton<DoctorDashboardRemoteDataSource>(
      () => DoctorDashboardRemoteDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>(),
        getIt<DoctorAppointmentPolicy>(),
      ),
    );
  }

  if (!getIt.isRegistered<DoctorDashboardRepository>()) {
    getIt.registerLazySingleton<DoctorDashboardRepository>(
      () => DoctorDashboardRepositoryImpl(
        getIt<DoctorDashboardRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetDoctorDashboard>()) {
    getIt.registerLazySingleton<GetDoctorDashboard>(
      () => GetDoctorDashboard(getIt<DoctorDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<GetDoctorAppointment>()) {
    getIt.registerLazySingleton<GetDoctorAppointment>(
      () => GetDoctorAppointment(getIt<DoctorDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<CompleteDoctorAppointment>()) {
    getIt.registerLazySingleton<CompleteDoctorAppointment>(
      () => CompleteDoctorAppointment(getIt<DoctorDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<DoctorDashboardCubit>()) {
    getIt.registerFactory<DoctorDashboardCubit>(
      () => DoctorDashboardCubit(getIt<GetDoctorDashboard>()),
    );
  }

  if (!getIt.isRegistered<DoctorAppointmentDetailsCubit>()) {
    getIt.registerFactory<DoctorAppointmentDetailsCubit>(
      () => DoctorAppointmentDetailsCubit(
        getIt<GetDoctorAppointment>(),
        getIt<CompleteDoctorAppointment>(),
        getIt<DoctorAppointmentPolicy>(),
      ),
    );
  }

  if (!getIt.isRegistered<AdminDashboardRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminDashboardRemoteDataSource>(
      () => AdminDashboardRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }

  if (!getIt.isRegistered<AdminDashboardRepository>()) {
    getIt.registerLazySingleton<AdminDashboardRepository>(
      () =>
          AdminDashboardRepositoryImpl(getIt<AdminDashboardRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetAdminDashboardStats>()) {
    getIt.registerLazySingleton<GetAdminDashboardStats>(
      () => GetAdminDashboardStats(getIt<AdminDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<AdminDashboardCubit>()) {
    getIt.registerFactory<AdminDashboardCubit>(
      () => AdminDashboardCubit(getIt<GetAdminDashboardStats>()),
    );
  }

  if (!getIt.isRegistered<AdminDoctorRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorRemoteDataSource>(
      () => AdminDoctorRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }
  if (!getIt.isRegistered<AdminDoctorListDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorListDataSource>(
      () => getIt<AdminDoctorRemoteDataSource>(),
    );
  }
  if (!getIt.isRegistered<AdminDoctorDetailsRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorDetailsRemoteDataSource>(
      () => AdminDoctorDetailsRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }
  if (!getIt.isRegistered<AdminDoctorDetailsDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorDetailsDataSource>(
      () => getIt<AdminDoctorDetailsRemoteDataSource>(),
    );
  }
  if (!getIt.isRegistered<AdminDoctorActionsRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorActionsRemoteDataSource>(
      AdminDoctorActionsRemoteDataSource.new,
    );
  }
  if (!getIt.isRegistered<AdminDoctorActionsDataSource>()) {
    getIt.registerLazySingleton<AdminDoctorActionsDataSource>(
      () => getIt<AdminDoctorActionsRemoteDataSource>(),
    );
  }
  if (!getIt.isRegistered<AdminDoctorRepository>()) {
    getIt.registerLazySingleton<AdminDoctorRepository>(
      () => AdminDoctorRepositoryImpl(
        getIt<AdminDoctorListDataSource>(),
        getIt<AdminDoctorDetailsDataSource>(),
        getIt<AdminDoctorActionsDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<AdminDoctorListCubit>()) {
    getIt.registerFactory<AdminDoctorListCubit>(
      () => AdminDoctorListCubit(getIt<AdminDoctorRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminDoctorDetailsCubit>()) {
    getIt.registerFactory<AdminDoctorDetailsCubit>(
      () => AdminDoctorDetailsCubit(getIt<AdminDoctorRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminPatientRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminPatientRemoteDataSource>(
      () => AdminPatientRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }
  if (!getIt.isRegistered<AdminPatientDataSource>()) {
    getIt.registerLazySingleton<AdminPatientDataSource>(
      () => getIt<AdminPatientRemoteDataSource>(),
    );
  }
  if (!getIt.isRegistered<AdminPatientRepository>()) {
    getIt.registerLazySingleton<AdminPatientRepository>(
      () => AdminPatientRepositoryImpl(getIt<AdminPatientDataSource>()),
    );
  }
  if (!getIt.isRegistered<AdminPatientListCubit>()) {
    getIt.registerFactory<AdminPatientListCubit>(
      () => AdminPatientListCubit(getIt<AdminPatientRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminPatientDetailsCubit>()) {
    getIt.registerFactory<AdminPatientDetailsCubit>(
      () => AdminPatientDetailsCubit(getIt<AdminPatientRepository>()),
    );
  }

  if (!getIt.isRegistered<DoctorApplicationRemoteDataSource>()) {
    getIt.registerLazySingleton<DoctorApplicationRemoteDataSource>(
      () => DoctorApplicationRemoteDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>(),
      ),
    );
  }
  if (!getIt.isRegistered<DoctorApplicationRepository>()) {
    getIt.registerLazySingleton<DoctorApplicationRepository>(
      () => DoctorApplicationRepositoryImpl(
        getIt<DoctorApplicationRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<DoctorApplicationCubit>()) {
    getIt.registerFactory<DoctorApplicationCubit>(
      () => DoctorApplicationCubit(getIt<DoctorApplicationRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminDoctorApplicationsCubit>()) {
    getIt.registerFactory<AdminDoctorApplicationsCubit>(
      () => AdminDoctorApplicationsCubit(getIt<DoctorApplicationRepository>()),
    );
  }
  if (!getIt.isRegistered<AdminDoctorApplicationDetailsCubit>()) {
    getIt.registerFactory<AdminDoctorApplicationDetailsCubit>(
      () => AdminDoctorApplicationDetailsCubit(
        getIt<DoctorApplicationRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<AdminSpecialtyRemoteDataSource>()) {
    getIt.registerLazySingleton<AdminSpecialtyRemoteDataSource>(
      () => AdminSpecialtyRemoteDataSource(getIt<FirebaseFirestore>()),
    );
  }
  if (!getIt.isRegistered<AdminSpecialtyRepository>()) {
    getIt.registerLazySingleton<AdminSpecialtyRepository>(
      () =>
          AdminSpecialtyRepositoryImpl(getIt<AdminSpecialtyRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<AdminSpecialtiesCubit>()) {
    getIt.registerFactory<AdminSpecialtiesCubit>(
      () => AdminSpecialtiesCubit(getIt<AdminSpecialtyRepository>()),
    );
  }
}
