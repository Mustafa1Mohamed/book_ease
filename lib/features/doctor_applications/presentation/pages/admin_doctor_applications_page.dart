import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../home/presentation/widgets/home_avatar.dart';
import '../../domain/entities/doctor_application.dart';
import '../cubit/admin_doctor_applications_cubit.dart';
import '../cubit/admin_doctor_applications_state.dart';

class AdminDoctorApplicationsPage extends StatefulWidget {
  const AdminDoctorApplicationsPage({super.key});

  @override
  State<AdminDoctorApplicationsPage> createState() =>
      _AdminDoctorApplicationsPageState();
}

class _AdminDoctorApplicationsPageState
    extends State<AdminDoctorApplicationsPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDoctorApplications)),
      body: BlocBuilder<AdminDoctorApplicationsCubit, AdminDoctorApplicationsState>(
        builder: (context, state) {
          final cubit = context.read<AdminDoctorApplicationsCubit>();
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth > 900
                    ? 860.0
                    : constraints.maxWidth;
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 240) {
                      cubit.loadMore();
                    }
                    return false;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    children: [
                      Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Column(
                            children: [
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: l10n.adminDoctorApplicationsSearch,
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchController.text.isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            cubit.updateSearch('');
                                          },
                                          icon: const Icon(Icons.clear_rounded),
                                        ),
                                ),
                                onChanged: _onSearchChanged(cubit),
                              ),
                              SizedBox(height: 12.h),
                              Wrap(
                                spacing: 12.w,
                                runSpacing: 12.h,
                                children: [
                                  SizedBox(
                                    width: 220.w,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: state.status,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.filter_list_rounded,
                                        ),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text(
                                            l10n.adminDoctorApplicationsAll,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'pending',
                                          child: Text(
                                            l10n.adminDoctorApplicationsPending,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'approved',
                                          child: Text(
                                            l10n.adminDoctorApplicationsApproved,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'rejected',
                                          child: Text(
                                            l10n.adminDoctorApplicationsRejected,
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          cubit.updateStatus(value);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 260.w,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: state.specialtyId,
                                      decoration: InputDecoration(
                                        labelText:
                                            l10n.doctorApplicationSpecialty,
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: '',
                                          child: Text(
                                            l10n.adminDoctorApplicationsAllSpecialties,
                                          ),
                                        ),
                                        for (final specialty
                                            in state.specialties)
                                          DropdownMenuItem(
                                            value: specialty.id,
                                            child: Text(
                                              specialty.localizedName(
                                                Localizations.localeOf(context)
                                                    .languageCode,
                                              ),
                                            ),
                                          ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          cubit.updateSpecialty(value);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              if (state.isLoading && state.applications.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                )
                              else if (state.hasError &&
                                  state.applications.isEmpty)
                                _Retry(
                                  message:
                                      state.errorMessage ??
                                      l10n.adminDoctorApplicationRetry,
                                  onRetry: cubit.load,
                                )
                              else if (state.applications.isEmpty)
                                Padding(
                                  padding: EdgeInsets.all(30.w),
                                  child: Text(
                                    l10n.adminDoctorApplicationsEmpty,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                for (final application
                                    in state.applications) ...[
                                  _ApplicationCard(
                                    application: application,
                                    onTap: () async {
                                      final reviewed = await context
                                          .pushNamed<bool>(
                                            AppRouter
                                                .adminDoctorApplicationDetails,
                                            pathParameters: {
                                              'applicationId': application.id,
                                            },
                                          );
                                      if (reviewed == true && context.mounted) {
                                        await cubit.reloadAfterReview();
                                      }
                                    },
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              if (state.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              if (state.hasError &&
                                  state.applications.isNotEmpty)
                                TextButton.icon(
                                  onPressed: cubit.loadMore,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    state.errorMessage ??
                                        l10n.adminDoctorApplicationRetry,
                                  ),
                                ),
                              if (!state.hasMore &&
                                  state.applications.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Text(
                                    l10n.adminDoctorApplicationsEnd,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ValueChanged<String> _onSearchChanged(AdminDoctorApplicationsCubit cubit) =>
      (value) {
        setState(() {});
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 350),
          () => cubit.updateSearch(value),
        );
      };
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});

  final DoctorApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusLabel = switch (application.status) {
      DoctorApplicationStatus.pending => l10n.adminDoctorApplicationsPending,
      DoctorApplicationStatus.approved => l10n.adminDoctorApplicationsApproved,
      DoctorApplicationStatus.rejected => l10n.adminDoctorApplicationsRejected,
      DoctorApplicationStatus.unknown => '—',
    };
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: HomeAvatar(imageUrl: application.profileImageUrl, radius: 24),
        title: Text(application.applicantName),
        subtitle: Text(
          '${application.applicantEmail}\n${application.specialtyName} · $statusLabel',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(20.w),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 8.h),
        FilledButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
