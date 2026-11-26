import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../cubit/admin_doctor_list_cubit.dart';
import '../cubit/admin_doctor_list_state.dart';
import '../widgets/admin_doctor_list_controls.dart';
import '../widgets/admin_doctor_list_results.dart';

class AdminDoctorListPage extends StatefulWidget {
  const AdminDoctorListPage({super.key});

  @override
  State<AdminDoctorListPage> createState() => _AdminDoctorListPageState();
}

class _AdminDoctorListPageState extends State<AdminDoctorListPage> {
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
      appBar: AppBar(title: Text(l10n.adminDoctorsTitle)),
      body: BlocBuilder<AdminDoctorListCubit, AdminDoctorListState>(
        builder: (context, state) {
          final cubit = context.read<AdminDoctorListCubit>();
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminDoctorListControls(
                          state: state,
                          searchController: _searchController,
                          onSearchChanged: _debounceSearch(cubit),
                          onFilterChanged: cubit.updateFilter,
                          onSpecialtyChanged: cubit.updateSpecialty,
                        ),
                        AdminDoctorListResults(state: state, cubit: cubit),
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
  }

  ValueChanged<String> _debounceSearch(AdminDoctorListCubit cubit) => (value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => cubit.updateSearch(value),
    );
  };
}
