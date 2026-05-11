import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/utils/validators.dart';
import 'package:agenda_escolar_adventista/core/widgets/custom_text_field.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signIn = ref.read(signInUseCaseProvider);
      final user = await signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      switch (user.role) {
        case UserRole.parent:
          context.go(AppRoutes.parentHome);
        case UserRole.teacher:
          context.go(AppRoutes.teacherHome);
        case UserRole.student:
          context.go(AppRoutes.studentHome);
        case UserRole.admin:
        case UserRole.secretary:
          context.go(AppRoutes.adminHome);
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('AuthException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      PhosphorIcons.arrowLeft(),
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.welcome),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Hola de nuevo',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.primary),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Inicia sesión para continuar',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),
                if (_errorMessage != null)
                  _ErrorBanner(message: _errorMessage!)
                      .animate()
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: -0.1, end: 0),
                CustomTextField(
                  label: 'Correo electrónico',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                )
                    .animate(delay: 160.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: AppSpacing.base),
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => Validators.required(
                    v,
                    message: 'Ingresa tu contraseña',
                  ),
                )
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).animate(delay: 320.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.base),
                PrimaryButton(
                  label: 'Iniciar sesión',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  height: 56,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.activate),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Es tu primera vez? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Activar mi cuenta',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: 480.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
