import '../../domain/entities/admin_specialty.dart';
import '../../domain/repositories/admin_specialty_repository.dart';
import '../datasources/admin_specialty_remote_data_source.dart';

class AdminSpecialtyRepositoryImpl implements AdminSpecialtyRepository {
  const AdminSpecialtyRepositoryImpl(this._remoteDataSource);

  final AdminSpecialtyRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminSpecialty>> getAll() => _remoteDataSource.getAll();

  @override
  Future<int> getDoctorCount(String specialtyId) =>
      _remoteDataSource.getDoctorCount(specialtyId);

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
  }) => _remoteDataSource.save(
    specialtyId: specialtyId,
    name: name,
    nameAr: nameAr,
    description: description,
    descriptionAr: descriptionAr,
    iconName: iconName,
    isActive: isActive,
    clearImage: clearImage,
  );

  @override
  Future<void> setActive({
    required String specialtyId,
    required bool isActive,
  }) =>
      _remoteDataSource.setActive(specialtyId: specialtyId, isActive: isActive);
}
