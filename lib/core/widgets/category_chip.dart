import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Chip pill animado para filtros, categorías y badges.
///
/// Estados:
/// - `selected: false` → fondo neutro, borde fino, color tenue.
/// - `selected: true`  → fondo del [color] tenue, borde del color, texto del color.
///
/// Si [onTap] es null el chip se renderiza sin feedback de presión.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.onTap,
  });

  /// Texto visible del chip.
  final String label;

  /// Icono a la izquierda del label (opcional).
  final IconData? icon;

  /// Color de acento. Si es null, usa [AppColors.primary].
  final Color? color;

  /// Si el chip está activo.
  final bool selected;

  /// Acción al presionar. Sin esto el chip no es interactivo.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final bg = selected ? accent.withValues(alpha: 0.10) : AppColors.surface;
    final border = selected ? accent : AppColors.border;
    final fg = selected ? accent : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: border, width: selected ? 1.2 : 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderFull,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
