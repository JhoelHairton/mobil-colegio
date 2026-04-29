import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Header personalizado del design system. Reemplaza al `AppBar`.
///
/// Estructura (ver guía):
/// ```
/// ┌─────────────────────────────────┐
/// │  ←                          ⋯   │  ← fila de actions
/// │                                 │
/// │  Título grande                  │
/// │  Subtítulo opcional             │
/// │                                 │
/// │  [chip] [chip] [chip]           │  ← row opcional
/// └─────────────────────────────────┘
/// ```
///
/// Pensado para ir como primer hijo de un `Column` dentro de un
/// `Scaffold` (no de un `AppBar`). Respeta el safe area superior.
class ModernHeader extends StatelessWidget {
  const ModernHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.trailing,
    this.chips,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.base,
      AppSpacing.xl,
      AppSpacing.lg,
    ),
  });

  /// Título principal (estilo `h1`).
  final String title;

  /// Subtítulo opcional debajo del título.
  final String? subtitle;

  /// Si debe mostrar el botón de back. Por defecto `true`.
  final bool showBack;

  /// Acción del back. Si es null, intenta `Navigator.maybePop`.
  final VoidCallback? onBack;

  /// Widget a la derecha de la fila superior (ej: botón de menú).
  final Widget? trailing;

  /// Lista horizontal de chips (filtros, categorías).
  /// Se renderiza con scroll horizontal sin barras visibles.
  final List<Widget>? chips;

  /// Padding del header. Por defecto sigue la guía
  /// (24 horizontal, 16 arriba, 20 abajo).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasTopRow = showBack || trailing != null;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTopRow) ...[
              Row(
                children: [
                  if (showBack)
                    _IconButton(
                      icon: PhosphorIcons.arrowLeft(),
                      onTap: onBack ?? () => Navigator.maybePop(context),
                      semanticsLabel: 'Volver',
                    )
                  else
                    const SizedBox.shrink(),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(title, style: AppTextStyles.h1),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (chips != null && chips!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: chips!.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => chips![i],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
