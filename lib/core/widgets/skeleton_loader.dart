import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';

/// Caja base con shimmer. Componer formas más complejas a partir de ella
/// envolviendo en [SkeletonGroup] para un solo gradiente sincronizado.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.borderXs,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return _maybeWrapShimmer(
      context,
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Línea de texto con ancho relativo (porcentaje).
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    this.widthFactor = 1.0,
    this.height = 14,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor.clamp(0.05, 1.0),
      child: SkeletonBox(height: height, borderRadius: AppRadius.borderXs),
    );
  }
}

/// Esqueleto pre-armado con la silueta de los cards de listado.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: SkeletonGroup(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: AppRadius.borderBase,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonText(widthFactor: 0.7, height: 16),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonText(widthFactor: 0.95, height: 12),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonText(widthFactor: 0.5, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Envuelve un subárbol con un solo `Shimmer` para que todas las cajas
/// hijas pulsen sincronizadamente. Útil cuando hay varios [SkeletonBox]
/// juntos: aplicar shimmer por cada uno produce un parpadeo desordenado.
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ShimmerEnvelope(child: child);
  }
}

/// Decide si esta caja necesita su propio Shimmer (uso suelto) o si está
/// dentro de un [SkeletonGroup] que ya provee uno.
Widget _maybeWrapShimmer(BuildContext context, Widget child) {
  final inGroup = context.findAncestorWidgetOfExactType<_ShimmerEnvelope>() != null;
  return inGroup ? child : _ShimmerEnvelope(child: child);
}

class _ShimmerEnvelope extends StatelessWidget {
  const _ShimmerEnvelope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.background,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}
