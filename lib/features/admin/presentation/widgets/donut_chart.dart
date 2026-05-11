import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

/// Una rebanada del donut. [color] y [value] son obligatorios; [label]
/// se usa en la leyenda.
class DonutSlice {
  const DonutSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Gráfico tipo donut, dibujado con [CustomPaint] para no agregar
/// dependencias. Si el total es 0 muestra un círculo gris con el
/// `centerLabel` en pequeño.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.size = 180,
    this.thickness = 28,
    this.centerLabel,
    this.centerSubtitle,
  });

  final List<DonutSlice> slices;
  final double size;
  final double thickness;

  /// Texto principal en el centro. Si null y hay datos, muestra el total.
  final String? centerLabel;
  final String? centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (acc, s) => acc + s.value);
    final isEmpty = total == 0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              slices: isEmpty
                  ? const [
                      DonutSlice(
                        label: '',
                        value: 1,
                        color: AppColors.surfaceMuted,
                      ),
                    ]
                  : slices,
              total: isEmpty ? 1 : total,
              thickness: thickness,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerLabel ?? (isEmpty ? '0' : total.toStringAsFixed(0)),
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              if (centerSubtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  centerSubtitle!,
                  style: AppTextStyles.metadata,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.total,
    required this.thickness,
  });

  final List<DonutSlice> slices;
  final double total;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2; // arrancamos arriba (12 en punto)
    final gap = slices.length > 1 ? 0.02 : 0.0; // ~1.1° de separación

    for (final slice in slices) {
      if (slice.value <= 0) continue;
      final sweep = (slice.value / total) * (2 * math.pi);
      final actualSweep = (sweep - gap).clamp(0.0, 2 * math.pi);

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + gap / 2, actualSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.total != total) return true;
    if (oldDelegate.thickness != thickness) return true;
    if (oldDelegate.slices.length != slices.length) return true;
    for (var i = 0; i < slices.length; i++) {
      if (oldDelegate.slices[i].value != slices[i].value ||
          oldDelegate.slices[i].color != slices[i].color) {
        return true;
      }
    }
    return false;
  }
}

/// Leyenda para acompañar el donut. Cada item: cuadradito de color +
/// label + valor.
class DonutLegend extends StatelessWidget {
  const DonutLegend({
    super.key,
    required this.slices,
    this.formatValue,
  });

  final List<DonutSlice> slices;
  final String Function(DonutSlice slice)? formatValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: slices.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                formatValue?.call(s) ?? s.value.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
