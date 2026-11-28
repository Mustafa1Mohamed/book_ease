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

class AdminSpecialtiesPage extends StatelessWidget {
  const AdminSpecialtiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSpecialtiesTitle),
        actions: [
          IconButton(
            tooltip: l10n.adminSpecialtiesAdd,
            onPressed: () => context.pushNamed(
              AppRouter.adminSpecialtyCreate,
              extra: context.read<AdminSpecialtiesCubit>(),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: BlocBuilder<AdminSpecialtiesCubit, AdminSpecialtiesState>(
        builder: (context, state) {
          final cubit = context.read<AdminSpecialtiesCubit>();
          if (state.isLoading && state.specialties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.loadError != null && state.specialties.isEmpty) {
            return _ErrorView(
              message: l10n.adminSpecialtiesLoadError,
              onRetry: cubit.load,
            );
          }
          final specialties = state.visibleSpecialties;
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth > 1040
                    ? 1000.0
                    : constraints.maxWidth;
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  children: [
                    Center(
                      child: SizedBox(
                        width: width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.adminSpecialtiesSubtitle,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              onChanged: cubit.updateQuery,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search_rounded),
                                hintText: l10n.adminSpecialtiesSearch,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              children: [
                                _FilterChip(
                                  label: l10n.adminSpecialtiesAll,
                                  selected:
                                      state.filter == SpecialtyListFilter.all,
                                  onSelected: () => cubit.updateFilter(
                                    SpecialtyListFilter.all,
                                  ),
                                ),
                                _FilterChip(
                                  label: l10n.adminSpecialtiesActive,
                                  selected:
                                      state.filter ==
                                      SpecialtyListFilter.active,
                                  onSelected: () => cubit.updateFilter(
                                    SpecialtyListFilter.active,
                                  ),
                                ),
                                _FilterChip(
                                  label: l10n.adminSpecialtiesInactive,
                                  selected:
                                      state.filter ==
                                      SpecialtyListFilter.inactive,
                                  onSelected: () => cubit.updateFilter(
                                    SpecialtyListFilter.inactive,
                                  ),
                                ),
                              ],
                            ),
                            if (state.isLoading) ...[
                              SizedBox(height: 12.h),
                              const LinearProgressIndicator(),
                            ],
                            if (state.loadError != null) ...[
                              SizedBox(height: 12.h),
                              Text(
                                l10n.adminSpecialtiesLoadError,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            if (state.mutationError != null) ...[
                              SizedBox(height: 12.h),
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
                            SizedBox(height: 14.h),
                            if (specialties.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 36.h),
                                child: Center(
                                  child: Text(
                                    state.specialties.isEmpty
                                        ? l10n.adminSpecialtiesEmpty
                                        : l10n.adminSpecialtiesNoResults,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              for (final specialty in specialties)
                                _SpecialtyTile(
                                  specialty: specialty,
                                  cubit: cubit,
                                ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({required this.specialty, required this.cubit});

  final AdminSpecialty specialty;
  final AdminSpecialtiesCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final localizedName = languageCode == 'ar' && specialty.nameAr.isNotEmpty
        ? specialty.nameAr
        : specialty.name;
    final statusLabel = specialty.isActive
        ? l10n.adminSpecialtiesActive
        : l10n.adminSpecialtiesInactive;
    return Card(
      child: ListTile(
        onTap: () => context.pushNamed(
          AppRouter.adminSpecialtyDetails,
          pathParameters: {'specialtyId': specialty.id},
          extra: cubit,
        ),
        leading: CircleAvatar(child: Icon(_iconFor(specialty.iconName))),
        title: Text(
          localizedName.isEmpty ? specialty.id : localizedName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$statusLabel · ${specialty.nameAr.isEmpty ? specialty.name : specialty.nameAr}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          FilledButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
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
