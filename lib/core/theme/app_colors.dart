import 'package:flutter/material.dart';

/// Paleta de colores del design system "Sereno y moderno".
///
/// Combina minimalismo institucional con toques modernos.
/// Los nombres siguen el patrón `<rol><Variante>`: `Soft` para
/// fondos sutiles/badges y `Deep` para variantes oscuras.
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────
  // PRIMARIOS — Azul navy adventista
  // ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F3D5C);
  static const Color primaryLight = Color(0xFF2563A0);
  static const Color primarySoft = Color(0xFFE6F1FB);
  static const Color primaryDeep = Color(0xFF082640);

  // ─────────────────────────────────────────────────────────────
  // ACENTO — Dorado adventista (usar con moderación)
  // ─────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFE8A33D);
  static const Color accentSoft = Color(0xFFFAEEDA);

  // ─────────────────────────────────────────────────────────────
  // FONDOS — Crema cálido en lugar de blanco frío
  // ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFAF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F3EE);

  // ─────────────────────────────────────────────────────────────
  // TEXTO — Jerarquía clara
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1B1E);
  static const Color textSecondary = Color(0xFF5F5E5A);
  static const Color textTertiary = Color(0xFF9A9A95);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1B1E);

  // ─────────────────────────────────────────────────────────────
  // CATEGORÍAS DE EVENTOS — Vivos pero no saturados
  // ─────────────────────────────────────────────────────────────
  static const Color categoryCultural = Color(0xFF8B5CF6);
  static const Color categorySpiritual = Color(0xFF3B82F6);
  static const Color categoryAcademic = Color(0xFF10B981);
  static const Color categorySports = Color(0xFFF59E0B);
  static const Color categoryCampaign = Color(0xFFEF4444);

  // ─────────────────────────────────────────────────────────────
  // SEMÁNTICOS
  // ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFDBEAFE);

  // ─────────────────────────────────────────────────────────────
  // BORDES Y DIVISORES
  // ─────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE8E5DD);
  static const Color borderActive = primary;
  static const Color divider = Color(0xFFF0EDE5);
}
