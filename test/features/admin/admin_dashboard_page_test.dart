import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/features/admin/domain/entities/admin_dashboard_stats.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:book_ease/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:book_ease/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:book_ease/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:book_ease/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAdminDashboardRepository implements AdminDashboardRepository {
  _FakeAdminDashboardRepository(this.stats);

  final AdminDashboardStats stats;

  @override
  Future<AdminDashboardStats> getDashboardStats() async => stats;
}

const _stats = AdminDashboardStats(
  totalPatients: 10,
  totalDoctors: 8,
  pendingDoctors: 3,
  approvedDoctors: 4,
  totalSpecialties: 6,
  totalAppointments: 20,
  upcomingAppointments: 7,
  completedAppointments: 9,
);

void main() {
  Future<void> pumpDashboard(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    final cubit = AdminDashboardCubit(
      GetAdminDashboardStats(_FakeAdminDashboardRepository(_stats)),
    );
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
            child: const AdminDashboardPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all dashboard metrics and values', (tester) async {
    await pumpDashboard(tester);

    expect(find.byType(AdminStatCard), findsNWidgets(8));
    expect(find.text('Total patients'), findsOneWidget);
    expect(find.text('Total doctors'), findsOneWidget);
    expect(find.text('Pending doctors'), findsOneWidget);
    expect(find.text('Approved doctors'), findsOneWidget);
    expect(find.text('Total specialties'), findsOneWidget);
    expect(find.text('Total appointments'), findsOneWidget);
    expect(find.text('Upcoming appointments'), findsOneWidget);
    expect(find.text('Completed appointments'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('renders unavailable metrics and Arabic RTL direction', (
    tester,
  ) async {
    const partialStats = AdminDashboardStats(
      totalPatients: null,
      totalDoctors: 8,
      pendingDoctors: null,
      approvedDoctors: 4,
      totalSpecialties: 6,
      totalAppointments: 20,
      upcomingAppointments: 7,
      completedAppointments: 9,
    );
    final cubit = AdminDashboardCubit(
      GetAdminDashboardStats(_FakeAdminDashboardRepository(partialStats)),
    );
    await cubit.load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocProvider.value(
            value: cubit,
            child: const AdminDashboardPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إجمالي المرضى'), findsOneWidget);
    expect(find.text('غير متاح'), findsNWidgets(2));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.rtl,
      ),
      findsWidgets,
    );
  });

  testWidgets('patient and doctor dashboard cards open their directories', (
    tester,
  ) async {
    final cubit = AdminDashboardCubit(
      GetAdminDashboardStats(_FakeAdminDashboardRepository(_stats)),
    );
    await cubit.load();
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: '/admin',
      routes: [
        GoRoute(
          path: '/admin',
          name: AppRouter.adminDashboard,
          builder: (_, _) => BlocProvider.value(
            value: cubit,
            child: const AdminDashboardPage(),
          ),
          routes: [
            GoRoute(
              path: 'patients',
              name: AppRouter.adminPatients,
              builder: (_, _) =>
                  const Scaffold(body: Text('Patient directory')),
            ),
            GoRoute(
              path: 'doctors',
              name: AppRouter.adminDoctors,
              builder: (_, state) => Scaffold(
                body: Text(
                  'Doctor directory: '
                  '${state.uri.queryParameters['filter'] ?? 'all'}',
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

    await tester.ensureVisible(find.text('Total patients'));
    await tester.tap(find.text('Total patients'));
    await tester.pumpAndSettle();
    expect(find.text('Patient directory'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pending doctors'));
    await tester.tap(find.text('Pending doctors'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor directory: pending'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Approved doctors'));
    await tester.tap(find.text('Approved doctors'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor directory: approved'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Total doctors'));
    await tester.tap(find.text('Total doctors'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor directory: all'), findsOneWidget);
  });
}
