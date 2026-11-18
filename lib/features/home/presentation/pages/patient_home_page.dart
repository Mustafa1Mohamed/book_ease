import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/patient_home_cubit.dart';
import '../widgets/home_error_view.dart';
import '../widgets/patient_home_tab_content.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isPatient =
        authState is AuthAuthenticated &&
        authState.user.role.trim().toLowerCase() == 'patient';
    if (!isPatient) {
      final signOut = context.read<AuthCubit>().signOut;
      return HomeErrorView(
        message: 'This home screen is only available to patient accounts.',
        onRetry: signOut,
        onSignOut: signOut,
      );
    }

    return PatientHomeTabContent(
      searchController: _searchController,
      searchQuery: _searchQuery,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onClearSearch: () => setState(() {
        _searchController.clear();
        _searchQuery = '';
      }),
      onNotificationsTap: _showNotifications,
      onSeeAll: () => context.goNamed(AppRouter.explore),
      onBookAppointment: () => context.goNamed(AppRouter.appointments),
      onRefresh: context.read<PatientHomeCubit>().load,
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications will be available soon.')),
    );
  }
}
