import '../entities/explore_catalog.dart';

abstract interface class ExploreRepository {
  Future<ExploreCatalog> loadCatalog();
}
