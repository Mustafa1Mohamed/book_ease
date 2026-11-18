import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthCubit>().signIn(
      _emailController.text,
      _passwordController.text,
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 40.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'BookEase',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 36.h),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to manage your healthcare appointments.',
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 28.h),
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
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: AuthValidators.validateLoginPassword,
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
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () =>
                                    context.pushNamed(AppRouter.forgotPassword),
                          child: const Text('Forgot Password?'),
                        ),
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
                            : const Text('Sign In'),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text('or'),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SocialAuthButton(
                        loading: loading,
                        onPressed: loading
                            ? null
                            : context.read<AuthCubit>().signInWithGoogle,
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('New to BookEase?'),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => context.pushNamed(AppRouter.register),
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
