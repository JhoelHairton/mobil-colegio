import 'package:flutter/widgets.dart';

/// Radios de esquinas del design system.
///
/// Convención de uso:
/// - [xs] (6px): chips pequeños, badges.
/// - [sm] (8px): inputs, chips medianos.
/// - [base] (12px): botones, cards pequeños.
/// - [md] (16px): cards principales.
/// - [lg] (20px): cards destacados.
/// - [xl] (24px): hero sections, banners, bottom sheets.
/// - [full]: pills, avatares (totalmente redondeado).
class AppRadius {
  AppRadius._();

  // ─────────────────────────────────────────────────────────────
  // VALORES NUMÉRICOS
  // ─────────────────────────────────────────────────────────────
  static const double xs = 6;
  static const double sm = 8;
  static const double base = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double full = 9999;

  // ─────────────────────────────────────────────────────────────
  // BORDER RADIUS LISTOS PARA USAR
  // ─────────────────────────────────────────────────────────────
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderBase = BorderRadius.all(Radius.circular(base));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}
