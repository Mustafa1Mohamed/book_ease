import '../entities/explore_catalog.dart';
import '../repositories/explore_repository.dart';

class GetExploreCatalog {
  const GetExploreCatalog(this._repository);

  final ExploreRepository _repository;

  Future<ExploreCatalog> call() => _repository.loadCatalog();
}
