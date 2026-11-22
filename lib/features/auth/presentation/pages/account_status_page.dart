import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/user_role.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AccountStatusPage extends StatelessWidget {
  const AccountStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final status = user?.role == UserRole.doctor
        ? user!.doctorApprovalStatus
        : DoctorApprovalStatus.unknown;
    final (title, message) = switch (status) {
      DoctorApprovalStatus.pending => (
        'Approval pending',
        'Your doctor account is awaiting approval. You can sign in again later.',
      ),
      DoctorApprovalStatus.rejected => (
        'Account not approved',
        'Your doctor account was not approved. Contact support if you believe this is an error.',
      ),
      DoctorApprovalStatus.profileMissing => (
        'Account setup incomplete',
        'We could not verify a doctor profile for your account. Please contact support.',
      ),
      DoctorApprovalStatus.approved => (
        'Account access unavailable',
        'We could not verify access to this area. Please sign in again.',
      ),
      DoctorApprovalStatus.unknown => (
        'Account access unavailable',
        'We could not verify your account access. Please contact support.',
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account status'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: context.read<AuthCubit>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 56),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
