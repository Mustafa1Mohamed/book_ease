import 'package:book_ease/features/admin/specialties/domain/entities/admin_specialty.dart';
import 'package:book_ease/features/admin/specialties/domain/errors/admin_specialty_exception.dart';
import 'package:book_ease/features/admin/specialties/domain/repositories/admin_specialty_repository.dart';
import 'package:book_ease/features/admin/specialties/presentation/cubit/admin_specialties_cubit.dart';
import 'package:book_ease/features/admin/specialties/presentation/cubit/admin_specialties_state.dart';
import 'package:flutter_test/flutter_test.dart';

AdminSpecialty _specialty({
  String id = 'heart',
  String name = 'Cardiology',
  String nameAr = 'أمراض القلب',
  SpecialtyStatus status = SpecialtyStatus.active,
}) => AdminSpecialty(
  id: id,
  name: name,
  nameAr: nameAr,
  description: '',
  descriptionAr: '',
  imageUrl: '',
  iconName: 'heart',
  availability: status,
  createdAt: null,
  updatedAt: null,
);

class _FakeAdminSpecialtyRepository implements AdminSpecialtyRepository {
  List<AdminSpecialty> specialties = [
    _specialty(),
    _specialty(
      id: 'legacy',
      name: 'Legacy Care',
      nameAr: 'رعاية قديمة',
      status: SpecialtyStatus.legacyActive,
    ),
    _specialty(
      id: 'inactive',
      name: 'Inactive Care',
      nameAr: 'رعاية غير نشطة',
      status: SpecialtyStatus.inactive,
    ),
  ];
  bool failLoad = false;
  String? saveError;
  String? activeError;
  int doctorCount = 4;

  @override
  Future<List<AdminSpecialty>> getAll() async {
    if (failLoad) throw const AdminSpecialtyException('unavailable');
    return specialties;
  }

  @override
  Future<int> getDoctorCount(String specialtyId) async => doctorCount;

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
  }) async {
    if (saveError != null) {
      throw AdminSpecialtyException(saveError!);
    }
    final saved = _specialty(
      id: specialtyId ?? 'new-specialty',
      name: name,
      nameAr: nameAr,
      status: isActive ? SpecialtyStatus.active : SpecialtyStatus.inactive,
    );
    specialties = [
      for (final item in specialties)
        if (item.id != saved.id) item,
      saved,
    ];
    return saved;
  }

  @override
  Future<void> setActive({
    required String specialtyId,
    required bool isActive,
  }) async {
    if (activeError != null) {
      throw AdminSpecialtyException(activeError!);
    }
    specialties = [
      for (final item in specialties)
        if (item.id == specialtyId)
          _specialty(
            id: item.id,
            name: item.name,
            nameAr: item.nameAr,
            status: isActive
                ? SpecialtyStatus.active
                : SpecialtyStatus.inactive,
          )
        else
          item,
    ];
  }
}

void main() {
  test('loads, searches both language names, and filters statuses', () async {
    final repository = _FakeAdminSpecialtyRepository();
    final cubit = AdminSpecialtiesCubit(repository);
    await cubit.load();

    expect(cubit.state.specialties, hasLength(3));
    cubit.updateQuery('القلب');
    expect(cubit.state.visibleSpecialties.single.id, 'heart');
    cubit.updateQuery('');
    cubit.updateFilter(SpecialtyListFilter.inactive);
    expect(cubit.state.visibleSpecialties.single.id, 'inactive');

    await cubit.close();
  });

  test('surfaces load errors and supports retry', () async {
    final repository = _FakeAdminSpecialtyRepository()..failLoad = true;
    final cubit = AdminSpecialtiesCubit(repository);
    await cubit.load();
    expect(cubit.state.loadError, 'unavailable');

    repository.failLoad = false;
    await cubit.load();
    expect(cubit.state.specialties, hasLength(3));
    expect(cubit.state.loadError, isNull);
    await cubit.close();
  });

  test('saves specialty state and reports duplicate names', () async {
    final repository = _FakeAdminSpecialtyRepository();
    final cubit = AdminSpecialtiesCubit(repository);
    await cubit.load();
    final saved = await cubit.save(
      name: 'Neurology',
      nameAr: 'الأعصاب',
      description: '',
      descriptionAr: '',
      iconName: 'neurology',
      isActive: true,
      clearImage: false,
    );
    expect(saved, isTrue);
    expect(
      cubit.state.specialties.any((item) => item.name == 'Neurology'),
      isTrue,
    );

    repository.saveError = 'already-exists';
    final duplicate = await cubit.save(
      name: 'Neurology',
      nameAr: 'الأعصاب',
      description: '',
      descriptionAr: '',
      iconName: 'neurology',
      isActive: true,
      clearImage: false,
    );
    expect(duplicate, isFalse);
    expect(cubit.state.mutationError, 'already-exists');
    await cubit.close();
  });

  test(
    'activation remains a soft update and linked doctor count loads',
    () async {
      final repository = _FakeAdminSpecialtyRepository();
      final cubit = AdminSpecialtiesCubit(repository);
      await cubit.load();

      final inactive = await cubit.setActive(
        specialty: cubit.state.specialties.first,
        isActive: false,
      );
      expect(inactive, isTrue);
      expect(
        cubit.specialtyById('heart')?.availability,
        SpecialtyStatus.inactive,
      );

      await cubit.loadDoctorCount('heart');
      expect(cubit.state.doctorCount, 4);
      await cubit.close();
    },
  );
}
