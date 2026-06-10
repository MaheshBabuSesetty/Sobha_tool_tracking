import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/core/extensions/context_extensions.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/core/utils/input_validators.dart';
import 'package:power_tool_tracking/presentation/blocs/auth/auth_bloc.dart';
import 'package:power_tool_tracking/presentation/routes/route_names.dart';
import 'package:power_tool_tracking/presentation/widgets/common/app_button.dart';
import 'package:power_tool_tracking/presentation/widgets/common/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _onLogin() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteNames.tools);
          } else if (state is AuthError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.sidebarBackground,
          body: Column(
            children: [
              // ── Branding header ──────────────────────────────────────
              const Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SOBHA',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'RFID Tool Tracking',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.sidebarInactiveText,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── White form card ──────────────────────────────────────
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your credentials to continue',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'Enter your work email',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.email_outlined,
                                validator: InputValidators.email,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                validator: (value) =>
                                    (value?.isEmpty ?? true)
                                        ? 'Password is required'
                                        : null,
                                onSubmitted: (_) => _onLogin(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to forgot password
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => AppButton(
                            onPressed: state is AuthLoading ? null : _onLogin,
                            isLoading: state is AuthLoading,
                            label: 'Sign In',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
