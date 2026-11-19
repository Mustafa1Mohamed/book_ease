import 'package:book_ease/features/explore/domain/entities/explore_catalog.dart';
import 'package:book_ease/features/explore/domain/repositories/explore_repository.dart';
import 'package:book_ease/features/explore/domain/usecases/get_explore_catalog.dart';
import 'package:book_ease/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:book_ease/features/explore/presentation/cubit/explore_state.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExploreRepository implements ExploreRepository {
  ExploreCatalog catalog = const ExploreCatalog(
    specialties: HomeSectionData(value: []),
    doctors: HomeSectionData(value: []),
  );
  Exception? error;

  @override
  Future<ExploreCatalog> loadCatalog() async {
    if (error case final value?) throw value;
    return catalog;
  }
}

void main() {
  late _FakeExploreRepository repository;
  late ExploreCubit cubit;

  setUp(() {
    repository = _FakeExploreRepository();
    cubit = ExploreCubit(GetExploreCatalog(repository));
  });

  tearDown(() async => cubit.close());

  test('emits loading and loaded states', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const ExploreLoading(),
        ExploreLoaded(catalog: repository.catalog),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('query and filters update locally after loading', () async {
    await cubit.load();
    cubit.updateQuery('cardio');

    final state = cubit.state;
    expect(state, isA<ExploreLoaded>());
    if (state is ExploreLoaded) {
      expect(state.query, 'cardio');
    }
  });

  test('emits a safe error when catalog loading fails', () async {
    repository.error = Exception('Firebase internal detail');
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const ExploreLoading(),
        const ExploreFailure(
          'Explore data could not be loaded. Please try again.',
        ),
      ]),
    );

    await cubit.load();
    await expectation;
  });
}
