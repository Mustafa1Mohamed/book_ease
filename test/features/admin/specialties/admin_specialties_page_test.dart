import 'package:book_ease/core/localization/generated/app_localizations.dart';
import 'package:book_ease/features/admin/specialties/domain/entities/admin_specialty.dart';
import 'package:book_ease/features/admin/specialties/domain/repositories/admin_specialty_repository.dart';
import 'package:book_ease/features/admin/specialties/presentation/cubit/admin_specialties_cubit.dart';
import 'package:book_ease/features/admin/specialties/presentation/pages/admin_specialty_form_page.dart';
import 'package:book_ease/features/admin/specialties/presentation/pages/admin_specialties_page.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _SpecialtyRepository implements AdminSpecialtyRepository {
  @override
  Future<List<AdminSpecialty>> getAll() async => const [
    AdminSpecialty(
      id: 'cardiology',
      name: 'Cardiology',
      nameAr: 'أمراض القلب',
      description: '',
      descriptionAr: '',
      imageUrl: '',
      iconName: 'heart',
      availability: SpecialtyStatus.active,
      createdAt: null,
      updatedAt: null,
    ),
    AdminSpecialty(
      id: 'inactive',
      name: 'Inactive',
      nameAr: 'غير نشط',
      description: '',
      descriptionAr: '',
      imageUrl: '',
      iconName: 'medical',
      availability: SpecialtyStatus.inactive,
      createdAt: null,
      updatedAt: null,
    ),
  ];

  @override
  Future<int> getDoctorCount(String specialtyId) async => 0;

  @override
  Future<AdminSpecialty> save({
    String? specialtyId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required String iconName,
    required bool isActive,
    required bool clearImage,
  }) => throw UnimplementedError();

  @override
  Future<void> setActive({
    required String specialtyId,
    required bool isActive,
  }) => throw UnimplementedError();
}

void main() {
  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('lists specialties in ${locale.languageCode}', (tester) async {
      final cubit = AdminSpecialtiesCubit(_SpecialtyRepository())..load();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        ScreenUtilPlusInit(
          designSize: const Size(360, 690),
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: BlocProvider.value(
              value: cubit,
              child: const AdminSpecialtiesPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (locale.languageCode == 'ar') {
        expect(find.text('Cardiology'), findsNothing);
        expect(find.text('أمراض القلب'), findsWidgets);
      } else {
        expect(find.text('Cardiology'), findsOneWidget);
      }

      await tester.tap(
        find.text(locale.languageCode == 'ar' ? 'غير نشط' : 'Inactive').first,
      );
      await tester.pumpAndSettle();
      expect(
        find.text(locale.languageCode == 'ar' ? 'أمراض القلب' : 'Cardiology'),
        findsNothing,
      );
      expect(
        find.text(locale.languageCode == 'ar' ? 'غير نشط' : 'Inactive'),
        findsWidgets,
      );
    });
  }

  testWidgets('requires both specialty names before submitting', (
    tester,
  ) async {
    final cubit = AdminSpecialtiesCubit(_SpecialtyRepository());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocProvider.value(
            value: cubit,
            child: const AdminSpecialtyFormPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.pump();

    expect(
      find.text('Enter a value for both specialty names.'),
      findsNWidgets(2),
    );
  });
}
