import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_button.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterView();
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions.'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().signUp(
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRouter.home);
        } else if (state is AuthProfileIncomplete) {
          context.goNamed(AppRouter.profileComplete);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start booking appointments and managing your care.',
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
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: AuthValidators.validateEmail,
                    ),
                    SizedBox(height: 16.h),
                    AuthTextField(
                      label: 'Phone Number (optional)',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    SizedBox(height: 16.h),
                    AuthTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: AuthValidators.validatePassword,
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AuthTextField(
                      label: 'Confirm Password',
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _acceptedTerms,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: loading
                          ? null
                          : (value) =>
                                setState(() => _acceptedTerms = value ?? false),
                      title: const Text('I accept the Terms and Conditions'),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                    SizedBox(height: 16.h),
                    SocialAuthButton(
                      loading: loading,
                      onPressed: loading
                          ? null
                          : context.read<AuthCubit>().signInWithGoogle,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => context.goNamed(AppRouter.login),
                          child: const Text('Sign In'),
                        ),
                      ],
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
