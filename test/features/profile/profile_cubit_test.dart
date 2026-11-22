import 'package:book_ease/features/auth/domain/entities/app_user.dart';
import 'package:book_ease/features/auth/domain/entities/user_role.dart';
import 'package:book_ease/features/profile/domain/repositories/profile_repository.dart';
import 'package:book_ease/features/profile/domain/errors/profile_exception.dart';
import 'package:book_ease/features/profile/domain/usecases/get_current_profile.dart';
import 'package:book_ease/features/profile/domain/usecases/pick_and_upload_profile_image.dart';
import 'package:book_ease/features/profile/domain/usecases/update_profile.dart';
import 'package:book_ease/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:book_ease/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  AppUser user = _profile;
  String? savedName;
  String? savedPhone;
  ProfileException? uploadError;

  @override
  Future<AppUser> getCurrentProfile() async => user;

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    savedName = fullName;
    savedPhone = phoneNumber;
    user = AppUser(
      uid: user.uid,
      fullName: fullName,
      email: user.email,
      phoneNumber: phoneNumber,
      role: user.role,
      profileImageUrl: user.profileImageUrl,
    );
    return user;
  }

  @override
  Future<AppUser?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  }) async {
    if (uploadError != null) throw uploadError!;
    onProgress(0.6);
    user = AppUser(
      uid: user.uid,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      role: user.role,
      profileImageUrl: 'https://example.test/profile.jpg',
    );
    return user;
  }
}

const _profile = AppUser(
  uid: 'patient-1',
  fullName: 'Taylor Patient',
  email: 'taylor@example.test',
  phoneNumber: '5550100',
  role: UserRole.patient,
);

void main() {
  late _FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = _FakeProfileRepository();
    cubit = ProfileCubit(
      GetCurrentProfile(repository),
      UpdateProfile(repository),
      PickAndUploadProfileImage(repository),
    );
  });

  tearDown(() async => cubit.close());

  test('updates only editable profile fields', () async {
    await cubit.load();
    await cubit.save(fullName: 'Taylor P.', phoneNumber: '5550101');

    final state = cubit.state as ProfileLoaded;
    expect(state.user.fullName, 'Taylor P.');
    expect(state.user.phoneNumber, '5550101');
    expect(state.user.email, _profile.email);
    expect(state.user.role, _profile.role);
    expect(repository.savedName, 'Taylor P.');
  });

  test('uploads a profile image and reports progress', () async {
    await cubit.load();
    final observedProgress = <double>[];
    final subscription = cubit.stream.listen((state) {
      if (state case ProfileLoaded(:final uploadProgress)) {
        observedProgress.add(uploadProgress);
      }
    });

    await cubit.uploadProfileImage();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    final state = cubit.state as ProfileLoaded;
    expect(observedProgress, contains(0.6));
    expect(state.user.profileImageUrl, 'https://example.test/profile.jpg');
    expect(state.isUploadingImage, isFalse);
  });

  test('loads every supported account role', () async {
    for (final role in const [
      UserRole.patient,
      UserRole.doctor,
      UserRole.admin,
    ]) {
      repository.user = AppUser(
        uid: '${role.name}-1',
        fullName: '${role.name} account',
        email: '${role.name}@example.test',
        phoneNumber: '',
        role: role,
      );
      await cubit.load();

      final state = cubit.state as ProfileLoaded;
      expect(state.user.role, role);
    }
  });

  test('shows an upload failure and clears uploading state', () async {
    await cubit.load();
    repository.uploadError = const ProfileException(
      'You do not have permission to upload a profile photo.',
    );

    await cubit.uploadProfileImage();

    final state = cubit.state as ProfileLoaded;
    expect(state.isUploadingImage, isFalse);
    expect(
      state.errorMessage,
      'You do not have permission to upload a profile photo.',
    );
  });
}
