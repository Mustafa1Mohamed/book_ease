import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/core/router/app_router.dart';
import 'package:book_ease/features/admin/domain/entities/admin_patient.dart';
import 'package:book_ease/features/admin/domain/entities/admin_patient_appointments_page.dart';
import 'package:book_ease/features/admin/domain/entities/admin_patient_page.dart';
import 'package:book_ease/features/admin/domain/errors/admin_patient_exception.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_patient_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_details_cubit.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_patient_list_cubit.dart';
import 'package:book_ease/features/admin/presentation/pages/admin_patient_details_page.dart';
import 'package:book_ease/features/admin/presentation/pages/admin_patient_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;

class _PatientPageRepository implements AdminPatientRepository {
  _PatientPageRepository({this.fail = false});

  final bool fail;
  final patient = const AdminPatient(
    uid: 'patient-1',
    fullName: 'Patient One',
    email: 'patient@example.com',
    phoneNumber: '',
    profileImageUrl: '',
    role: 'patient',
  );

  @override
  Future<AdminPatientPage> getPatients({
    required String search,
    AdminPatientCursor? cursor,
  }) async {
    if (fail) throw const AdminPatientException('unavailable');
    return AdminPatientPage(
      patients: search.isEmpty ? [patient] : const [],
      hasMore: false,
    );
  }

  @override
  Future<AdminPatient?> getPatient(String uid) async =>
      uid == patient.uid ? patient : null;

  @override
  Future<AdminPatientAppointmentsPage> getAppointments({
    required String patientUid,
    AdminPatientAppointmentCursor? cursor,
  }) async =>
      const AdminPatientAppointmentsPage(appointments: [], hasMore: false);
}

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool fail = false,
  }) async {
    final cubit = AdminPatientListCubit(_PatientPageRepository(fail: fail));
    await cubit.load();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocProvider.value(
            value: cubit,
            child: const AdminPatientListPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return;
  }

  testWidgets('renders directory, search and Arabic RTL layout', (
    tester,
  ) async {
    await pumpPage(tester, locale: const Locale('ar'));

    expect(find.text('دليل المرضى'), findsOneWidget);
    expect(find.text('Patient One'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.rtl,
      ),
      findsWidgets,
    );
  });

  testWidgets('renders no-match and error states', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No patients match this search.'), findsOneWidget);

    await pumpPage(tester, fail: true);
    expect(
      find.text(
        'Patients could not be loaded. Check admin access and your connection, then retry.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows available profile data and empty appointment history', (
    tester,
  ) async {
    final cubit = AdminPatientDetailsCubit(_PatientPageRepository());
    await cubit.load('patient-1');
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocProvider.value(
            value: cubit,
            child: const AdminPatientDetailsPage(patientId: 'patient-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Patient One'), findsOneWidget);
    expect(find.text('patient@example.com'), findsWidgets);
    expect(find.text('50% complete'), findsOneWidget);
    expect(find.text('No appointment history was found.'), findsOneWidget);
  });

  testWidgets('patient list items open their dedicated profile route', (
    tester,
  ) async {
    final cubit = AdminPatientListCubit(_PatientPageRepository());
    await cubit.load();
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: '/admin/patients',
      routes: [
        GoRoute(
          path: '/admin/patients',
          name: AppRouter.adminPatients,
          builder: (_, _) => BlocProvider.value(
            value: cubit,
            child: const AdminPatientListPage(),
          ),
          routes: [
            GoRoute(
              path: ':patientId',
              name: AppRouter.adminPatientDetails,
              builder: (_, state) => Scaffold(
                body: Text(
                  'Patient details ${state.pathParameters['patientId']}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp.router(
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient One'));
    await tester.pumpAndSettle();

    expect(find.text('Patient details patient-1'), findsOneWidget);
  });
}
