import 'dart:async';
import 'dart:ui' as ui show TextDirection;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/admin_patient_list_cubit.dart';
import '../cubit/admin_patient_list_state.dart';
import '../widgets/admin_patient_card.dart';

class AdminPatientListPage extends StatefulWidget {
  const AdminPatientListPage({super.key});

  @override
  State<AdminPatientListPage> createState() => _AdminPatientListPageState();
}

class _AdminPatientListPageState extends State<AdminPatientListPage> {
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
    final direction = l10n.localeName.startsWith('ar')
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.adminPatientsTitle)),
        body: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _debouncedSearch,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText: l10n.adminPatientsSearch,
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _debounce?.cancel();
                                    _searchController.clear();
                                    context
                                        .read<AdminPatientListCubit>()
                                        .updateSearch('');
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                  tooltip: l10n.adminPatientsClearSearch,
                                ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.adminPatientsSearchHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminPatientListCubit, AdminPatientListState>(
                builder: (context, state) {
                  final cubit = context.read<AdminPatientListCubit>();
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 300 &&
                          state.hasMore &&
                          !state.isLoadingMore &&
                          !state.loadMoreHasError) {
                        cubit.loadMore();
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: cubit.load,
                      child: _buildResults(context, state, cubit),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AdminPatientListState state,
    AdminPatientListCubit cubit,
  ) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError && state.patients.isEmpty) {
      return _MessageView(
        message: l10n.adminPatientsLoadError,
        actionLabel: l10n.retry,
        onPressed: cubit.load,
      );
    }
    if (state.patients.isEmpty) {
      return _MessageView(
        message: state.search.isEmpty
            ? l10n.adminPatientsEmpty
            : l10n.adminPatientsNoResults,
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: state.patients.length + 1 + (state.hasError ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.hasError && index == 0) {
          return Center(
            child: TextButton.icon(
              onPressed: cubit.load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.adminPatientsLoadError),
            ),
          );
        }
        final patientIndex = index - (state.hasError ? 1 : 0);
        if (patientIndex < state.patients.length) {
          final patient = state.patients[patientIndex];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: AdminPatientCard(
                patient: patient,
                onTap: () => context.pushNamed(
                  AppRouter.adminPatientDetails,
                  pathParameters: {'patientId': patient.uid},
                ),
              ),
            ),
          );
        }
        if (state.isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state.loadMoreHasError) {
          return Center(
            child: TextButton.icon(
              onPressed: cubit.loadMore,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.adminPatientsRetryLoadingMore),
            ),
          );
        }
        return const SizedBox(height: 12);
      },
    );
  }

  void _debouncedSearch(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<AdminPatientListCubit>().updateSearch(value);
      }
    });
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, this.actionLabel, this.onPressed});

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: 110.h),
      Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onPressed != null && actionLabel != null) ...[
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    ],
  );
}
