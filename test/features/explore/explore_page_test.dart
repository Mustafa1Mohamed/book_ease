import 'package:book_ease/features/explore/domain/entities/explore_catalog.dart';
import 'package:book_ease/features/explore/domain/repositories/explore_repository.dart';
import 'package:book_ease/features/explore/domain/usecases/get_explore_catalog.dart';
import 'package:book_ease/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:book_ease/features/explore/presentation/cubit/explore_state.dart';
import 'package:book_ease/features/explore/presentation/pages/explore_page.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:book_ease/features/home/domain/entities/medical_specialty.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeExploreRepository implements ExploreRepository {
  _FakeExploreRepository({this.catalog = _emptyCatalog});

  static const _emptyCatalog = ExploreCatalog(
    specialties: HomeSectionData(value: []),
    doctors: HomeSectionData(value: []),
  );
  final ExploreCatalog catalog;

  @override
  Future<ExploreCatalog> loadCatalog() async => catalog;
}

void main() {
  testWidgets('Explore displays empty states and accepts search input', (
    tester,
  ) async {
    final cubit = ExploreCubit(GetExploreCatalog(_FakeExploreRepository()))
      ..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: ExplorePage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Find the right specialist for you'), findsOneWidget);
    expect(find.text('No specialties found.'), findsOneWidget);
    expect(find.text('No doctors are available yet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'heart');
    await tester.pump();
    expect(cubit.state, isA<ExploreLoaded>());
    if (cubit.state case final ExploreLoaded state) {
      expect(state.query, 'heart');
    }
  });

  testWidgets('selecting a specialty filters doctors', (tester) async {
    const catalog = ExploreCatalog(
      specialties: HomeSectionData(
        value: [
          MedicalSpecialty(
            id: 'cardiology',
            name: 'Cardiology',
            imageUrl: '',
            iconName: '',
          ),
        ],
      ),
      doctors: HomeSectionData(
        value: [
          FeaturedDoctor(
            id: 'doctor-1',
            fullName: 'Dr Heart',
            specialtyId: 'cardiology',
            specialtyName: 'Cardiology',
            imageUrl: '',
            rating: null,
            consultationFee: null,
            isAvailable: null,
          ),
        ],
      ),
    );
    final cubit = ExploreCubit(
      GetExploreCatalog(_FakeExploreRepository(catalog: catalog)),
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: ExplorePage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dr Heart'), findsOneWidget);

    await tester.tap(find.text('Cardiology').first);
    await tester.pumpAndSettle();

    expect(find.text('Cardiology'), findsWidgets);
    expect(cubit.state, isA<ExploreLoaded>());
    if (cubit.state case final ExploreLoaded state) {
      expect(state.filters.specialtyId, 'cardiology');
      expect(state.filteredDoctors.map((doctor) => doctor.id), ['doctor-1']);
    }

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filter doctors'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    if (cubit.state case final ExploreLoaded state) {
      expect(state.filters.specialtyId, isNull);
    }
  });
}
