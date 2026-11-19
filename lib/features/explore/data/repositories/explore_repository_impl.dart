import '../../domain/entities/explore_catalog.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  const ExploreRepositoryImpl(this._dataSource);

  final ExploreDataSource _dataSource;

  @override
  Future<ExploreCatalog> loadCatalog() => _dataSource.loadCatalog();
}
