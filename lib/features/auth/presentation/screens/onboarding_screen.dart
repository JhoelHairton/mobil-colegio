import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/core/widgets/secondary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingData> _slides = [
    _OnboardingData(
      icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
      accent: AppColors.categorySpiritual,
      title: 'Nunca te pierdas un evento',
      description:
          'Recibe notificaciones de eventos culturales, espirituales, académicos y deportivos del colegio.',
    ),
    _OnboardingData(
      icon: PhosphorIcons.fileText(PhosphorIconsStyle.duotone),
      accent: AppColors.categoryAcademic,
      title: 'Trámites sin salir de casa',
      description:
          'Sube constancias, solicitudes y extractos desde tu celular y haz seguimiento en tiempo real.',
    ),
    _OnboardingData(
      icon: PhosphorIcons.usersThree(PhosphorIconsStyle.duotone),
      accent: AppColors.categoryCultural,
      title: 'Toda la comunidad conectada',
      description:
          'Padres, docentes y administración trabajando juntos por una mejor experiencia educativa.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// Al terminar el onboarding volvemos al welcome para que el usuario
  /// elija "Activar mi cuenta" o "Iniciar sesión".
  void _finish() => context.go(AppRoutes.welcome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Saltar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _Slide(
                  data: _slides[i],
                  // El key fuerza re-animar cada vez que cambiamos de página.
                  key: ValueKey(i),
                ),
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: _slides.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.border,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _buildButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _slides.length - 1;

    if (isFirst) {
      return PrimaryButton(
        label: 'Siguiente',
        icon: Icons.arrow_forward,
        onPressed: _nextPage,
        height: 56,
      );
    }
    if (isLast) {
      return PrimaryButton(
        label: 'Empezar ahora',
        icon: Icons.check,
        onPressed: _finish,
        height: 56,
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: SecondaryButton(
            label: 'Atrás',
            onPressed: _previousPage,
            height: 56,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 65,
          child: PrimaryButton(
            label: 'Siguiente',
            icon: Icons.arrow_forward,
            onPressed: _nextPage,
            height: 56,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _Slide extends StatelessWidget {
  const _Slide({super.key, required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: data.accent.withValues(alpha: 0.20),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Icon(data.icon, size: 120, color: data.accent),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(0.94, 0.94),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            data.title,
            style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          )
              .animate(delay: 120.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.base),
          Text(
            data.description,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
}
