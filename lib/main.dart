import 'package:book_ease/app.dart';
import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:book_ease/firebase_options.dart';
import 'package:book_ease/injection_container.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
