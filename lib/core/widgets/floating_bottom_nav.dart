import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_shadows.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Item de la barra de navegación flotante.
class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barra de navegación flotante en formato pill.
///
/// Reemplaza al [BottomNavigationBar] clásico. Se posiciona a 16px del
/// borde inferior con margen horizontal de 24px y blur sutil de fondo.
///
/// Uso:
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       contenido,
///       Align(
///         alignment: Alignment.bottomCenter,
///         child: FloatingBottomNav(
///           currentIndex: index,
///           onTap: (i) => setState(() => index = i),
///           items: const [...],
///         ),
///       ),
///     ],
///   ),
/// )
/// ```
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length >= 2 && items.length <= 5,
            'FloatingBottomNav requiere entre 2 y 5 items');

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.base,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderXl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: AppRadius.borderXl,
                border: Border.all(color: AppColors.border, width: 0.5),
                boxShadow: AppShadows.shadowMd,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavItem(
                        item: items[i],
                        isActive: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;

    return Semantics(
      label: item.label,
      selected: isActive,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySoft : Colors.transparent,
              borderRadius: AppRadius.borderLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isActive ? item.activeIcon : item.icon, size: 22, color: color),
                if (isActive) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.buttonRegular.copyWith(color: color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
