import 'dart:async';

import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_details.dart';
import 'package:book_ease/features/admin/domain/entities/admin_doctor_filter.dart';
import 'package:book_ease/features/admin/domain/errors/admin_doctor_exception.dart';
import 'package:book_ease/features/admin/domain/repositories/admin_doctor_repository.dart';
import 'package:book_ease/features/admin/presentation/cubit/admin_doctor_list_cubit.dart';
import 'package:book_ease/features/admin/presentation/pages/admin_doctor_list_page.dart';
import 'package:book_ease/features/auth/domain/entities/doctor_lifecycle_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;

class _ListRepository implements AdminDoctorRepository {
  _ListRepository({this.fail = false, this.empty = false, this.response});

  final bool fail;
  final bool empty;
  final Completer<AdminDoctorPage>? response;

  @override
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  }) {
    if (response != null) return response!.future;
    return _getPage();
  }

  Future<AdminDoctorPage> _getPage() async {
    if (fail) throw const AdminDoctorException('permission-denied');
    return AdminDoctorPage(
      doctors: empty ? const [] : [_doctor],
      hasMore: false,
    );
  }

  @override
  Future<List<AdminDoctorSpecialty>> getSpecialties() async => const [];

  @override
  Future<AdminDoctorDetails> getDoctorDetails(String doctorId) =>
      throw UnimplementedError();

  @override
  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  }) => throw UnimplementedError();

  @override
  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  }) => throw UnimplementedError();
}

final _doctor = AdminDoctor(
  id: 'profile-1',
  uid: 'doctor-1',
  name: 'Dr. Example',
  email: 'doctor@example.com',
  phoneNumber: '',
  profileImageUrl: '',
  specialtyId: 'specialty-1',
  specialtyName: 'Family medicine',
  consultationFee: 50,
  biography: '',
  qualifications: const [],
  yearsExperience: null,
  languages: const [],
  clinicName: '',
  clinicAddress: '',
  lifecycle: DoctorLifecycleStatus.pending,
  warnings: const [],
  identityVerified: true,
);

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool fail = false,
    bool empty = false,
    Completer<AdminDoctorPage>? response,
  }) async {
    final cubit = AdminDoctorListCubit(
      _ListRepository(fail: fail, empty: empty, response: response),
    );
    final load = cubit.load();
    if (response == null) await load;
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
            child: const AdminDoctorListPage(),
          ),
        ),
      ),
    );
    if (response == null) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('renders doctor results and Arabic RTL layout', (tester) async {
    await pumpPage(tester, locale: const Locale('ar'));

    expect(find.text('إدارة الأطباء'), findsOneWidget);
    expect(find.text('Dr. Example'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.rtl,
      ),
      findsWidgets,
    );
  });

  testWidgets('renders the empty state', (tester) async {
    await pumpPage(tester, empty: true);

    expect(find.text('No doctors match these filters.'), findsOneWidget);
  });

  testWidgets('renders a loading indicator while the first page is pending', (
    tester,
  ) async {
    final response = Completer<AdminDoctorPage>();
    await pumpPage(tester, response: response);

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    response.complete(const AdminDoctorPage(doctors: [], hasMore: false));
    await tester.pumpAndSettle();
    expect(find.text('No doctors match these filters.'), findsOneWidget);
  });

  testWidgets('renders a retry state after a repository failure', (
    tester,
  ) async {
    await pumpPage(tester, fail: true);

    expect(
      find.text(
        'Doctors could not be loaded. Check access and connection, then retry.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
