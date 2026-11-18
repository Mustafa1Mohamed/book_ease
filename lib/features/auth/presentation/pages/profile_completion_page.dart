import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_text_field.dart';

class ProfileCompletionPage extends StatelessWidget {
  const ProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileCompletionView();
  }
}

class _ProfileCompletionView extends StatefulWidget {
  const _ProfileCompletionView();

  @override
  State<_ProfileCompletionView> createState() => _ProfileCompletionViewState();
}

class _ProfileCompletionViewState extends State<_ProfileCompletionView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRouter.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Complete Profile'),
            actions: [
              IconButton(
                tooltip: 'Sign out',
                onPressed: loading ? null : context.read<AuthCubit>().signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A few details to get started',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Complete your patient profile before continuing.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 24.h),
                    AuthTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: AuthValidators.validateName,
                    ),
                    SizedBox(height: 16.h),
                    AuthTextField(
                      label: 'Phone Number (optional)',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() == true) {
                                context.read<AuthCubit>().completeProfile(
                                  fullName: _nameController.text,
                                  phoneNumber: _phoneController.text,
                                );
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
