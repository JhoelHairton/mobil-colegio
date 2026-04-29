import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Estado vacío con icono enmarcado, título, subtítulo y acción opcional.
///
/// El icono va dentro de un círculo `accentColor` tenue. La entrada se
/// anima con fade + slide sutil siguiendo la guía (400ms easeOutCubic).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  /// Icono del estado vacío. Se recomienda usar `PhosphorIcons.x()`.
  final IconData icon;

  /// Texto principal.
  final String title;

  /// Texto secundario explicativo.
  final String? subtitle;

  /// Etiqueta del botón de acción. Si es null, no se muestra botón.
  final String? actionLabel;

  /// Callback del botón de acción.
  final VoidCallback? onAction;

  /// Color de acento del círculo del icono. Por defecto `primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderFull,
              ),
              child: Icon(icon, size: 44, color: accent),
            )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOutCubic,
                ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate(delay: 140.ms).fadeIn(duration: 350.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    curve: Curves.easeOutCubic,
                  ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
            ],
          ],
        ),
      ),
    );
  }
}
