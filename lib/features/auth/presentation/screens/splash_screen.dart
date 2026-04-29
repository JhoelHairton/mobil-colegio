import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agenda_escolar_adventista/core/constants/app_constants.dart';
import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // 2.4s para que la animación de entrada respire antes de navegar.
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.go(AppRoutes.welcome);
      return;
    }

    switch (user.role) {
      case UserRole.parent:
        context.go(AppRoutes.parentHome);
      case UserRole.teacher:
        context.go(AppRoutes.teacherHome);
      case UserRole.student:
        context.go(AppRoutes.studentHome);
      case UserRole.admin:
      case UserRole.secretary:
        // En móvil, admin/secretary se quedan en welcome (acceso desde web).
        context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDeep],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Logo()
                        .animate()
                        .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .then(delay: 300.ms)
                        // Respiración sutil mientras esperamos navegar.
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.04, 1.04),
                          duration: 1500.ms,
                          curve: Curves.easeInOutSine,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.04, 1.04),
                          end: const Offset(1, 1),
                          duration: 1500.ms,
                          curve: Curves.easeInOutSine,
                        ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.h1.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.institutionName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate(delay: 320.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.xl,
                child: Text(
                  'v${AppConstants.version}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'AEA',
          style: AppTextStyles.displaySmall
              .copyWith(color: AppColors.primary, height: 1),
        ),
      ),
    );
  }
}
