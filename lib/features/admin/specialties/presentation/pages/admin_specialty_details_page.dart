import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/localization/generated/app_localizations.dart';
import '../../../../../core/router/app_router.dart';
import '../../domain/entities/admin_specialty.dart';
import '../cubit/admin_specialties_cubit.dart';
import '../cubit/admin_specialties_state.dart';
import '../utils/admin_specialty_error_message.dart';

class AdminSpecialtyDetailsPage extends StatefulWidget {
  const AdminSpecialtyDetailsPage({required this.specialtyId, super.key});

  final String specialtyId;

  @override
  State<AdminSpecialtyDetailsPage> createState() =>
      _AdminSpecialtyDetailsPageState();
}

class _AdminSpecialtyDetailsPageState extends State<AdminSpecialtyDetailsPage> {
  bool _requestedCount = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedCount) return;
    _requestedCount = true;
    context.read<AdminSpecialtiesCubit>().loadDoctorCount(widget.specialtyId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSpecialtyDetails),
        actions: [
          IconButton(
            tooltip: l10n.adminSpecialtyEdit,
            onPressed: () => context.pushNamed(
              AppRouter.adminSpecialtyEdit,
              pathParameters: {'specialtyId': widget.specialtyId},
              extra: context.read<AdminSpecialtiesCubit>(),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: BlocBuilder<AdminSpecialtiesCubit, AdminSpecialtiesState>(
        builder: (context, state) {
          final specialty = context.read<AdminSpecialtiesCubit>().specialtyById(
            widget.specialtyId,
          );
          if (specialty == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  state.loadError == null
                      ? l10n.adminSpecialtiesNoResults
                      : l10n.adminSpecialtiesLoadError,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _DetailsContent(
            specialty: specialty,
            state: state,
            onToggle: () => _toggle(context, specialty, l10n),
          );
        },
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    AdminSpecialty specialty,
    AppLocalizations l10n,
  ) async {
    final nextStatus = !specialty.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          nextStatus
              ? l10n.adminSpecialtyActivateTitle
              : l10n.adminSpecialtyDeactivateTitle,
        ),
        content: Text(
          nextStatus
              ? l10n.adminSpecialtyActivateMessage
              : l10n.adminSpecialtyDeactivateMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              nextStatus
                  ? l10n.adminSpecialtiesActive
                  : l10n.adminSpecialtiesInactive,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await context.read<AdminSpecialtiesCubit>().setActive(
      specialty: specialty,
      isActive: nextStatus,
    );
    if (succeeded && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSpecialtyActivationSuccess)),
      );
    }
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.specialty,
    required this.state,
    required this.onToggle,
  });

  final AdminSpecialty specialty;
  final AdminSpecialtiesState state;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final name = languageCode == 'ar' && specialty.nameAr.isNotEmpty
        ? specialty.nameAr
        : specialty.name;
    final description =
        languageCode == 'ar' && specialty.descriptionAr.isNotEmpty
        ? specialty.descriptionAr
        : specialty.description;
    final status = switch (specialty.availability) {
      SpecialtyStatus.active => l10n.adminSpecialtiesActive,
      SpecialtyStatus.legacyActive => l10n.adminSpecialtiesActive,
      SpecialtyStatus.inactive ||
      SpecialtyStatus.invalid => l10n.adminSpecialtiesInactive,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 900 ? 820.0 : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: width,
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26.r,
                              child: Icon(_iconFor(specialty.iconName)),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isEmpty ? specialty.id : name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  Text(
                                    '${specialty.name} · ${specialty.nameAr}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(description),
                        ],
                        SizedBox(height: 12.h),
                        Text('${l10n.adminSpecialtyStatus}: $status'),
                        if (specialty.availability ==
                            SpecialtyStatus.legacyActive) ...[
                          SizedBox(height: 10.h),
                          _Notice(message: l10n.adminSpecialtyLegacyStatus),
                        ],
                        if (specialty.availability ==
                            SpecialtyStatus.invalid) ...[
                          SizedBox(height: 10.h),
                          _Notice(
                            message: l10n.adminSpecialtyInvalidStatus,
                            isError: true,
                          ),
                        ],
                        if (specialty.imageUrl.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(l10n.adminSpecialtyImagePolicy),
                        ],
                        SizedBox(height: 14.h),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: specialty.isActive,
                          onChanged: state.isMutating
                              ? null
                              : (_) => onToggle(),
                          title: Text(l10n.adminSpecialtyIsActive),
                        ),
                        if (state.mutationError != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            adminSpecialtyErrorMessage(
                              l10n,
                              state.mutationError!,
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        if (state.isMutating) const LinearProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isCountLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (state.countError != null)
                          Wrap(
                            spacing: 8.w,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(l10n.adminSpecialtyDoctorCountUnavailable),
                              TextButton(
                                onPressed: () => context
                                    .read<AdminSpecialtiesCubit>()
                                    .loadDoctorCount(specialty.id),
                                child: Text(l10n.retry),
                              ),
                            ],
                          )
                        else
                          Text(
                            l10n.adminSpecialtyDoctorCount(
                              state.doctorCount ?? 0,
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        SizedBox(height: 6.h),
                        Text(l10n.adminSpecialtyDoctorCountNote),
                        if (specialty.createdAt != null)
                          Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              '${l10n.adminSpecialtyCreatedAt}: '
                              '${_date(context, specialty.createdAt)}',
                            ),
                          ),
                        if (specialty.updatedAt != null)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              '${l10n.adminSpecialtyUpdatedAt}: '
                              '${_date(context, specialty.updatedAt)}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _date(BuildContext context, DateTime? value) => value == null
      ? '—'
      : MaterialLocalizations.of(context).formatMediumDate(value);
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError
        ? colorScheme.errorContainer
        : colorScheme.tertiaryContainer;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(message),
    );
  }
}

IconData _iconFor(String value) => switch (value) {
  'heart' => Icons.favorite_rounded,
  'dental' => Icons.health_and_safety_rounded,
  'skin' => Icons.face_retouching_natural_rounded,
  'neurology' => Icons.psychology_rounded,
  'pediatrics' => Icons.child_care_rounded,
  'orthopedics' => Icons.accessibility_new_rounded,
  _ => Icons.medical_services_rounded,
};
