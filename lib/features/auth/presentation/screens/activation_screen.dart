import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Pantalla de activación de cuenta institucional.
///
/// El admin pre-cargó al usuario desde Excel y le entregó un código de
/// 8 caracteres. Aquí ingresa email + código + nueva contraseña. Tras
/// éxito, el usuario queda autenticado y se redirige a su home según rol.
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleActivate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activate = ref.read(activateAccountUseCaseProvider);
      final user = await activate(
        email: _emailController.text.trim(),
        activationCode: _codeController.text.trim().toUpperCase(),
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      // Mostrar feedback positivo breve antes de redirigir.
      _showSuccessSnack(user.displayName);

      // Pequeño delay para que el usuario vea el snack antes de navegar.
      await Future<void>.delayed(const Duration(milliseconds: 800));
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
          context.go(AppRoutes.welcome);
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('AuthException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnack(String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '¡Bienvenido, $name!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
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
                  'Activar mi cuenta',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.primary),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ingresa el código de 8 caracteres que te entregó la secretaría '
                  'del colegio junto con tu correo institucional.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
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
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: AppSpacing.base),
                _ActivationCodeField(controller: _codeController)
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Crea una contraseña permanente',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                ).animate(delay: 320.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Nueva contraseña',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                )
                    .animate(delay: 360.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: AppSpacing.base),
                CustomTextField(
                  label: 'Confirma la contraseña',
                  controller: _confirmController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (v != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                )
                    .animate(delay: 420.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: 'Activar cuenta',
                  icon: Icons.check,
                  onPressed: _handleActivate,
                  isLoading: _isLoading,
                  height: 56,
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya activaste tu cuenta? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Iniciar sesión',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}

/// Campo especializado para el código de 8 caracteres alfanuméricos.
/// Forza mayúsculas, sin espacios, máximo 8 chars.
class _ActivationCodeField extends StatelessWidget {
  const _ActivationCodeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 8,
      style: AppTextStyles.h3.copyWith(letterSpacing: 4),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        _UpperCaseFormatter(),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Ingresa el código de activación';
        }
        if (v.trim().length != 8) {
          return 'El código tiene 8 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Código de activación',
        labelStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary),
        hintText: 'XXXXXXXX',
        hintStyle: AppTextStyles.h3.copyWith(
          letterSpacing: 4,
          color: AppColors.textTertiary.withValues(alpha: 0.5),
        ),
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          child: Icon(
            PhosphorIcons.key(),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
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
