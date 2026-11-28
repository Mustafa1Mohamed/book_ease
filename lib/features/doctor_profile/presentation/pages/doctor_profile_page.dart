import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../cubit/doctor_profile_cubit.dart';
import '../cubit/doctor_profile_state.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
            builder: (context, state) => IconButton(
              tooltip: 'Edit profile',
              onPressed: state is DoctorProfileLoaded
                  ? () => context.pushNamed(AppRouter.doctorProfileEdit)
                  : null,
              icon: const Icon(Icons.edit_rounded),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
        builder: (context, state) => switch (state) {
          DoctorProfileInitial() || DoctorProfileLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DoctorProfileFailure(:final message) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  FilledButton(
                    onPressed: context.read<DoctorProfileCubit>().load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          DoctorProfileLoaded(
            :final profile,
            :final isUploadingImage,
            :final uploadProgress,
          ) =>
            ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                Center(
                  child: Column(
                    children: [
                      HomeAvatar(
                        imageUrl: profile.profileImageUrl,
                        fallbackIcon: Icons.medical_services_rounded,
                        radius: 48,
                      ),
                      if (isUploadingImage) ...[
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: 180.w,
                          child: LinearProgressIndicator(value: uploadProgress),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (profile.specialtyName.isNotEmpty)
                  Text(
                    profile.specialtyName,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 16.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Detail('Email', profile.email),
                        _Detail('Phone', profile.phoneNumber),
                        _Detail(
                          'Consultation fee',
                          profile.consultationFee?.toStringAsFixed(2) ?? '',
                        ),
                        _Detail('Biography', profile.biography),
                        _Detail(
                          'Years of experience',
                          profile.yearsExperience?.toString() ?? '',
                        ),
                        _Detail('Clinic', profile.clinicName),
                        _Detail('Clinic address', profile.clinicAddress),
                        _Detail(
                          'Approval status',
                          profile.lifecycle.approvalStatus.name,
                        ),
                        _Detail(
                          'Administrative status',
                          profile.lifecycle.administrativeStatus.name,
                        ),
                        _Detail(
                          'Profile completeness',
                          '${(profile.profileCompleteness * 100).round()}%',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () =>
                      context.pushNamed(AppRouter.doctorProfileEdit),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        SizedBox(height: 2.h),
        Text(value.isEmpty ? 'Not provided' : value),
      ],
    ),
  );
}
