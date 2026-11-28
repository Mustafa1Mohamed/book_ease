import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_avatar.dart';
import '../cubit/doctor_profile_cubit.dart';
import '../cubit/doctor_profile_state.dart';

class DoctorProfileEditPage extends StatefulWidget {
  const DoctorProfileEditPage({super.key});

  @override
  State<DoctorProfileEditPage> createState() => _DoctorProfileEditPageState();
}

class _DoctorProfileEditPageState extends State<DoctorProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _fee = TextEditingController();
  final _bio = TextEditingController();
  final _experience = TextEditingController();
  final _clinicName = TextEditingController();
  final _clinicAddress = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _fee.dispose();
    _bio.dispose();
    _experience.dispose();
    _clinicName.dispose();
    _clinicAddress.dispose();
    super.dispose();
  }

  void _initialize(DoctorProfileLoaded state) {
    if (_initialized) return;
    final profile = state.profile;
    _name.text = profile.fullName;
    _phone.text = profile.phoneNumber;
    _fee.text =
        profile.consultationFee?.toStringAsFixed(2).replaceAll('.00', '') ?? '';
    _bio.text = profile.biography;
    _experience.text = profile.yearsExperience?.toString() ?? '';
    _clinicName.text = profile.clinicName;
    _clinicAddress.text = profile.clinicAddress;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
        listener: (context, state) {
          if (state is DoctorProfileLoaded &&
              state.successMessage == 'Profile saved.' &&
              context.mounted) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) => switch (state) {
          DoctorProfileInitial() || DoctorProfileLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DoctorProfileFailure(:final message) => Center(child: Text(message)),
          DoctorProfileLoaded() => _buildForm(context, state),
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, DoctorProfileLoaded state) {
    _initialize(state);
    final cubit = context.read<DoctorProfileCubit>();
    final busy = state.isSaving || state.isUploadingImage;
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  HomeAvatar(
                    imageUrl: state.profile.profileImageUrl,
                    fallbackIcon: Icons.medical_services_rounded,
                    radius: 48,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: 'Change profile photo',
                      onPressed: busy ? null : cubit.uploadProfileImage,
                      icon: const Icon(Icons.camera_alt_rounded),
                    ),
                  ),
                ],
              ),
              if (state.isUploadingImage) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: 180.w,
                  child: LinearProgressIndicator(value: state.uploadProgress),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Specialty: ${state.profile.specialtyName.isEmpty ? 'Not provided' : state.profile.specialtyName}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 8.h),
        Text(
          'Specialty changes require admin review and are not editable here.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 16.h),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your full name'
                    : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                initialValue: state.profile.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _phone,
                enabled: !busy,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _fee,
                enabled: !busy,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Consultation fee',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: _validateOptionalNumber,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _experience,
                enabled: !busy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                ),
                validator: _validateOptionalInteger,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _clinicName,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Clinic name',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _clinicAddress,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Clinic address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _bio,
                enabled: !busy,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Professional bio',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
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
                  onPressed: busy
                      ? null
                      : () {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          cubit.save(
                            fullName: _name.text,
                            phoneNumber: _phone.text,
                            consultationFee: _fee.text.trim().isEmpty
                                ? null
                                : double.tryParse(_fee.text.trim()),
                            biography: _bio.text,
                            yearsExperience: _experience.text.trim().isEmpty
                                ? null
                                : int.tryParse(_experience.text.trim()),
                            clinicName: _clinicName.text,
                            clinicAddress: _clinicAddress.text,
                          );
                        },
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save profile'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _validateOptionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    if (number == null || number < 0) return 'Enter a valid non-negative fee';
    return null;
  }

  String? _validateOptionalInteger(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = int.tryParse(value.trim());
    if (number == null || number < 0) {
      return 'Enter valid years of experience';
    }
    return null;
  }
}
