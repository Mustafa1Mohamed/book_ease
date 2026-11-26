import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_doctor_filter.dart';
import '../cubit/admin_doctor_list_state.dart';

class AdminDoctorListControls extends StatelessWidget {
  const AdminDoctorListControls({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSpecialtyChanged,
  });

  final AdminDoctorListState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AdminDoctorFilter> onFilterChanged;
  final ValueChanged<String> onSpecialtyChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      AdminDoctorFilter.all: l10n.adminDoctorsAll,
      AdminDoctorFilter.pending: l10n.adminDoctorsPending,
      AdminDoctorFilter.approved: l10n.adminDoctorsApproved,
      AdminDoctorFilter.rejected: l10n.adminDoctorsRejected,
      AdminDoctorFilter.suspended: l10n.adminDoctorsSuspended,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminDoctorsSubtitle),
        SizedBox(height: 16.h),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.adminDoctorsSearch,
            prefixIcon: const Icon(Icons.search_rounded),
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            for (final filter in AdminDoctorFilter.values)
              ChoiceChip(
                label: Text(labels[filter]!),
                selected: state.filter == filter,
                onSelected: (_) => onFilterChanged(filter),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        DropdownButtonFormField<String>(
          initialValue: state.specialtyId,
          decoration: InputDecoration(
            labelText: l10n.adminDoctorsSpecialty,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(l10n.adminDoctorsAllSpecialties),
            ),
            ...state.specialties.map(
              (specialty) => DropdownMenuItem(
                value: specialty.id,
                child: Text(specialty.name),
              ),
            ),
          ],
          onChanged: state.specialtiesUnavailable
              ? null
              : (value) {
                  if (value != null) onSpecialtyChanged(value);
                },
        ),
        if (state.specialtiesUnavailable) ...[
          SizedBox(height: 8.h),
          Text(l10n.adminDoctorsSpecialtiesUnavailable),
        ],
        SizedBox(height: 12.h),
        _Notice(
          message: l10n.adminDoctorsLegacyNotice,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(message, style: TextStyle(color: color)),
  );
}
