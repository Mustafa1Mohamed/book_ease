import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/core/theme/app_theme.dart';
import 'package:book_ease/firebase_options.dart';
import 'package:book_ease/injection_container.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupDependencies();

  runApp(
    BlocProvider(create: (_) => getIt<LocaleCubit>(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ScreenUtilPlusInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BookEase',
            theme: AppTheme.lightTheme,

            locale: locale,

            supportedLocales: const [Locale('en'), Locale('ar')],

            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              ],
            home: const MyHomePage(),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appName),
        actions: [
          IconButton(
            onPressed: () {
              context.read<LocaleCubit>().toggleLanguage();
            },
            icon: const Icon(Icons.language),
            tooltip: localization.changeLanguage,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localization.welcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(localization.welcomeSubtitle),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<LocaleCubit>().toggleLanguage();
              },
              child: Text(localization.changeLanguage),
            ),
          ],
        ),
      ),
    );
  }
}
