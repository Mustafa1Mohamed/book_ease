import '../entities/admin_specialty.dart';

abstract interface class AdminSpecialtyRepository {
  Future<List<AdminSpecialty>> getAll();
  Future<int> getDoctorCount(String specialtyId);
  Future<AdminSpecialty> save({
    String? specialtyId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required String iconName,
    required bool isActive,
    required bool clearImage,
  });
  Future<void> setActive({required String specialtyId, required bool isActive});
}
