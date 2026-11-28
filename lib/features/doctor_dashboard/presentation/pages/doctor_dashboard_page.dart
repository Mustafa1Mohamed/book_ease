import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/doctor_dashboard_cubit.dart';
import '../cubit/doctor_dashboard_state.dart';
import '../widgets/doctor_dashboard_content.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Doctor profile',
            onPressed: () => context.pushNamed(AppRouter.doctorProfile),
            icon: const Icon(Icons.person_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: context.read<AuthCubit>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
        builder: (context, state) => switch (state) {
          DoctorDashboardInitial() || DoctorDashboardLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          DoctorDashboardFailure(:final message) => _DashboardError(
            message: message,
          ),
          DoctorDashboardLoaded() => DoctorDashboardContent(state: state),
        },
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: context.read<DoctorDashboardCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
