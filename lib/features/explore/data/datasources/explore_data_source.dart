import '../../domain/entities/explore_catalog.dart';

abstract interface class ExploreDataSource {
  Future<ExploreCatalog> loadCatalog();
}
