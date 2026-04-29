import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';

/// Jerarquía tipográfica del design system.
///
/// Toda la app usa Inter (Google Fonts). Los títulos respiran con
/// `letterSpacing` negativo y los pesos contrastan con el cuerpo.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(color: AppColors.textPrimary);

  // ─────────────────────────────────────────────────────────────
  // DISPLAY — Solo portadas y headers principales
  // ─────────────────────────────────────────────────────────────
  static TextStyle get display => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle get displaySmall => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      );

  // ─────────────────────────────────────────────────────────────
  // HEADINGS
  // ─────────────────────────────────────────────────────────────
  static TextStyle get h1 => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get h4 => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // ─────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ─────────────────────────────────────────────────────────────
  // LABEL Y CAPTION
  // ─────────────────────────────────────────────────────────────

  /// Label en mayúsculas — secciones, eyebrows, badges.
  static TextStyle get label => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        // El UPPERCASE se aplica desde el widget (Text con .toUpperCase()
        // o AutoUpper). Se evita TextTransform porque Flutter no lo expone.
      );

  /// Texto auxiliar y descripciones secundarias.
  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  /// Metadata: timestamps, autoría, contadores discretos.
  static TextStyle get metadata => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  // ─────────────────────────────────────────────────────────────
  // BUTTONS
  // ─────────────────────────────────────────────────────────────
  static TextStyle get buttonLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonRegular => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
