import 'package:book_ease/features/explore/data/datasources/explore_data_source.dart';
import 'package:book_ease/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:book_ease/features/explore/domain/entities/explore_catalog.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExploreDataSource implements ExploreDataSource {
  @override
  Future<ExploreCatalog> loadCatalog() async => const ExploreCatalog(
    specialties: HomeSectionData(value: []),
    doctors: HomeSectionData(value: []),
  );
}

void main() {
  test('repository returns catalog from its data source', () async {
    final repository = ExploreRepositoryImpl(_FakeExploreDataSource());

    final catalog = await repository.loadCatalog();

    expect(catalog.specialties.value, isEmpty);
    expect(catalog.doctors.value, isEmpty);
  });
}
