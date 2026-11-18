import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:book_ease/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:book_ease/features/auth/domain/repositories/auth_repository.dart';
import 'package:book_ease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (getIt.isRegistered<FirebaseAuth>() && getIt.isRegistered<AuthCubit>()) {
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
}
