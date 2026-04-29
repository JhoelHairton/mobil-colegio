import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/constants/app_constants.dart';
import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/core/widgets/secondary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Hero()
                            .animate()
                            .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                            .slideY(
                              begin: -0.05,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Bienvenido a',
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.textSecondary),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.displaySmall
                              .copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        )
                            .animate(delay: 280.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: AppSpacing.base),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base),
                          child: Text(
                            'Mantente conectado con la comunidad educativa del colegio.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate(delay: 360.ms)
                              .fadeIn(duration: 400.ms),
                        ),
                      ],
                    ),
                  ),
                  // Acciones — primaria (activar) y secundaria (login).
                  PrimaryButton(
                    label: 'Activar mi cuenta',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.push(AppRoutes.activate),
                    height: 56,
                  )
                      .animate(delay: 480.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Ya tengo cuenta, iniciar sesión',
                    onPressed: () => context.push(AppRoutes.login),
                    height: 52,
                  )
                      .animate(delay: 560.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.onboarding),
                    child: Text(
                      'Conoce más sobre la app',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ).animate(delay: 640.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
            // Acceso a Style Guide (DEV — eliminar antes de producción).
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Style Guide',
                icon: Icon(
                  PhosphorIcons.palette(),
                  color: AppColors.textTertiary,
                ),
                onPressed: () => context.push(AppRoutes.styleGuide),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySoft,
            AppColors.primarySoft.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: AppRadius.borderXl,
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glyph decorativo de fondo
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              PhosphorIcons.bookOpen(PhosphorIconsStyle.duotone),
              size: 140,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderFull,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              PhosphorIcons.graduationCap(PhosphorIconsStyle.duotone),
              size: 64,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
