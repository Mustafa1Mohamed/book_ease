import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookEase'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, size: 48),
              SizedBox(height: 16),
              Text(
                'Home placeholder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Upcoming Home feature', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
