import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/auth_cubit.dart';

class AdminDashboardPlaceholderPage extends StatelessWidget {
  const AdminDashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: context.read<AuthCubit>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'The admin dashboard is not available yet.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
