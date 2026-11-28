import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/doctor_application.dart';
import '../cubit/doctor_application_cubit.dart';
import '../cubit/doctor_application_state.dart';

class DoctorApplicationFormPage extends StatefulWidget {
  const DoctorApplicationFormPage({super.key});

  @override
  State<DoctorApplicationFormPage> createState() =>
      _DoctorApplicationFormPageState();
}

class _DoctorApplicationFormPageState extends State<DoctorApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _qualification = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();
  final _fee = TextEditingController();
  final _address = TextEditingController();
  String? _specialtyId;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _qualification.dispose();
    _experience.dispose();
    _bio.dispose();
    _fee.dispose();
    _address.dispose();
    super.dispose();
  }

  void _initialize(DoctorApplicationState state) {
    if (_initialized) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _name.text = authState.user.fullName;
      _phone.text = authState.user.phoneNumber;
    }
    if (state.specialties.isNotEmpty) {
      _specialtyId = state.specialties.first.id;
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorApplicationFormTitle)),
      body: BlocConsumer<DoctorApplicationCubit, DoctorApplicationState>(
        listener: (context, state) {
          if (state.isSubmitted) Navigator.of(context).pop(true);
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && !state.isForm) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(state.errorMessage!, textAlign: TextAlign.center),
              ),
            );
          }
          _initialize(state);
          final existing = state.application;
          if (existing?.status == DoctorApplicationStatus.pending ||
              existing?.status == DoctorApplicationStatus.approved) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existing!.status == DoctorApplicationStatus.pending
                          ? l10n.doctorApplicationPending
                          : l10n.doctorApplicationApproved,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.doctorApplicationTitle),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildForm(context, state, l10n);
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    DoctorApplicationState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<DoctorApplicationCubit>();
    final busy = state.isSubmitting;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 720 ? 680.0 : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: width,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  Text(
                    l10n.doctorApplicationCredentialNotice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (state.specialties.isEmpty) ...[
                    SizedBox(height: 12.h),
                    Text(
                      l10n.doctorApplicationSpecialtiesUnavailable,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  TextFormField(
                    controller: _name,
                    enabled: !busy,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationFullName,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: _required(l10n, 120),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _phone,
                    enabled: !busy,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationPhone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return l10n.doctorApplicationValidationRequired;
                      }
                      return RegExp(r'^[0-9+() .-]{7,24}$').hasMatch(text)
                          ? null
                          : l10n.doctorApplicationValidationPhone;
                    },
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: _specialtyId,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationSpecialty,
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                    ),
                    items: [
                      for (final specialty in state.specialties)
                        DropdownMenuItem(
                          value: specialty.id,
                          child: Text(specialty.name),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (value) => setState(() => _specialtyId = value),
                    validator: (value) => value == null
                        ? l10n.doctorApplicationValidationRequired
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _qualification,
                    enabled: !busy,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationQualification,
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                    validator: _required(l10n, 250),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _experience,
                    enabled: !busy,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationExperience,
                      prefixIcon: const Icon(Icons.workspace_premium_outlined),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value?.trim() ?? '');
                      return parsed != null && parsed >= 0 && parsed <= 80
                          ? null
                          : l10n.doctorApplicationValidationExperience;
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _fee,
                    enabled: !busy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationFee,
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      return parsed != null &&
                              parsed.isFinite &&
                              parsed >= 0 &&
                              parsed <= 1000000
                          ? null
                          : l10n.doctorApplicationValidationFee;
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _address,
                    enabled: !busy,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationClinicAddress,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    validator: _required(l10n, 500),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _bio,
                    enabled: !busy,
                    minLines: 4,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: l10n.doctorApplicationBio,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                        (value?.trim().length ?? 0) >= 30 &&
                            (value?.trim().length ?? 0) <= 5000
                        ? null
                        : l10n.doctorApplicationValidationBio,
                  ),
                  if (state.errorMessage case final message?) ...[
                    SizedBox(height: 12.h),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 20.h),
                  FilledButton(
                    onPressed: busy || state.specialties.isEmpty
                        ? null
                        : () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            cubit.submit(
                              fullName: _name.text,
                              phoneNumber: _phone.text,
                              specialtyId: _specialtyId!,
                              qualification: _qualification.text,
                              experienceYears: int.parse(_experience.text),
                              bio: _bio.text,
                              consultationFee: double.parse(_fee.text),
                              clinicAddress: _address.text,
                            );
                          },
                    child: busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.doctorApplicationSubmit),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  FormFieldValidator<String> _required(AppLocalizations l10n, int maxLength) =>
      (value) {
        final text = value?.trim() ?? '';
        return text.isNotEmpty && text.length <= maxLength
            ? null
            : l10n.doctorApplicationValidationRequired;
      };
}
