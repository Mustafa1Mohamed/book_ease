import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../widgets/home_error_view.dart';

class PatientHomeShellPage extends StatelessWidget {
  const PatientHomeShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isPatient =
        authState is AuthAuthenticated &&
        authState.user.role == UserRole.patient;
    final signOut = context.read<AuthCubit>().signOut;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookEase'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: isPatient
          ? navigationShell
          : HomeErrorView(
              message: 'This area is only available to patient accounts.',
              onRetry: signOut,
              onSignOut: signOut,
            ),
      bottomNavigationBar: isPatient
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Appointments',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
