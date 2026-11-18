import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/core/router/app_router.dart';
import 'package:book_ease/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
    import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
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
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'BookEase',
            theme: AppTheme.lightTheme,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) =>
                Directionality(textDirection: TextDirection.ltr, child: child!),
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
