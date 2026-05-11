import 'package:flutter/material.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Fila con etiqueta, barra de progreso de altura única y valor a la
/// derecha. La usamos en reportes para mostrar % por docente o conteo
/// por categoría.
class HorizontalBarRow extends StatelessWidget {
  const HorizontalBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    this.subtitle,
    this.leading,
  });

  /// Etiqueta principal (ej. nombre del docente o categoría).
  final String label;

  /// Texto a la derecha (ej. "92%" o "12 eventos").
  final String value;

  /// Fracción 0..1 de la barra.
  final double fraction;

  final Color color;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.metadata),
                  ],
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clamped,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
