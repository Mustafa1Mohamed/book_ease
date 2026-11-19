import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => switch (state) {
        ProfileInitial() ||
        ProfileLoading() => const Center(child: CircularProgressIndicator()),
        ProfileFailure(:final message) => _ProfileFailure(
          message: message,
          onRetry: context.read<ProfileCubit>().load,
          onSignOut: () => _signOut(context),
        ),
        ProfileLoaded(:final user) => _ProfileForm(user: user),
      },
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  try {
    await context.read<AuthCubit>().signOut();
  } on Exception {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
    }
  }
}

class _ProfileFailure extends StatelessWidget {
  const _ProfileFailure({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                TextButton(onPressed: onSignOut, child: const Text('Sign out')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.user});

  final AppUser user;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileCubit>().state as ProfileLoaded;
    final user = state.user;
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  HomeAvatar(imageUrl: user.profileImageUrl, radius: 48),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: 'Change profile photo',
                      onPressed: state.isUploadingImage || state.isSaving
                          ? null
                          : context.read<ProfileCubit>().uploadProfileImage,
                      icon: const Icon(Icons.camera_alt_rounded),
                    ),
                  ),
                ],
              ),
              if (state.isUploadingImage) ...[
                SizedBox(height: 12.h),
                LinearProgressIndicator(value: state.uploadProgress),
                SizedBox(height: 4.h),
                Text('${(state.uploadProgress * 100).round()}%'),
              ],
            ],
          ),
        ),
        SizedBox(height: 28.h),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                enabled: !state.isSaving && !state.isUploadingImage,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your full name'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                initialValue: user.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Email cannot be changed here.',
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                enabled: !state.isSaving && !state.isUploadingImage,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              if (state.errorMessage case final message?) ...[
                SizedBox(height: 12.h),
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              if (state.successMessage case final message?) ...[
                SizedBox(height: 12.h),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSaving || state.isUploadingImage
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<ProfileCubit>().save(
                              fullName: _fullNameController.text,
                              phoneNumber: _phoneController.text,
                            );
                          }
                        },
                  child: state.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save profile'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        OutlinedButton.icon(
          onPressed: () async {
            final shouldSignOut = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Sign out?'),
                content: const Text(
                  'You will need to sign in again to continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            );
            if (shouldSignOut == true && context.mounted) {
              await _signOut(context);
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}
