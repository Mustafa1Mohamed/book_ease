import 'package:book_ease/features/auth/domain/entities/app_user.dart';
import 'package:book_ease/features/auth/domain/entities/user_role.dart';
import 'package:book_ease/features/profile/domain/repositories/profile_repository.dart';
import 'package:book_ease/features/profile/domain/usecases/get_current_profile.dart';
import 'package:book_ease/features/profile/domain/usecases/pick_and_upload_profile_image.dart';
import 'package:book_ease/features/profile/domain/usecases/update_profile.dart';
import 'package:book_ease/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:book_ease/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _ProfileRepository implements ProfileRepository {
  @override
  Future<AppUser> getCurrentProfile() async => _profile;

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async => _profile;

  @override
  Future<AppUser?> pickAndUploadProfileImage({
    required void Function(double progress) onProgress,
  }) async => null;
}

const _profile = AppUser(
  uid: 'patient-1',
  fullName: 'Taylor Patient',
  email: 'taylor@example.test',
  phoneNumber: '',
  role: UserRole.patient,
);

void main() {
  testWidgets('profile page keeps email read-only and exposes no role editor', (
    tester,
  ) async {
    final repository = _ProfileRepository();
    final cubit = ProfileCubit(
      GetCurrentProfile(repository),
      UpdateProfile(repository),
      PickAndUploadProfileImage(repository),
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: ProfilePage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Taylor Patient'), findsOneWidget);
    expect(find.text('taylor@example.test'), findsOneWidget);
    expect(find.text('role'), findsNothing);
    final emailField = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .firstWhere((field) => field.initialValue == _profile.email);
    expect(emailField.initialValue, _profile.email);
    final emailEditor = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .firstWhere((field) => field.controller.text == _profile.email);
    expect(emailEditor.readOnly, isTrue);
  });
}
