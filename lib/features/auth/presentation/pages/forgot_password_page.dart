import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ForgotPasswordView();
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset email sent to ${state.email}.'),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(title: const Text('Reset Password')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot your password?',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email and we will send you a secure reset link.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 24.h),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.email_outlined,
                      validator: AuthValidators.validateEmail,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() == true) {
                                context
                                    .read<AuthCubit>()
                                    .sendPasswordResetEmail(
                                      _emailController.text,
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
                          : const Text('Send Reset Email'),
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
