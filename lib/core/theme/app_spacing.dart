/// Escala de espaciado del design system (base 4px).
///
/// Reglas de aplicación:
/// - Padding interno de pantallas: [screenHorizontal] (24px).
/// - Espaciado entre secciones: [sectionGap] (32px).
/// - Espaciado entre cards de una lista: [listGap] (12px).
class AppSpacing {
  AppSpacing._();

  // ─────────────────────────────────────────────────────────────
  // ESCALA BASE (múltiplos de 4)
  // ─────────────────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double xxxxl = 56;
  static const double xxxxxl = 80;

  // ─────────────────────────────────────────────────────────────
  // ALIAS SEMÁNTICOS — uso recomendado en pantallas
  // ─────────────────────────────────────────────────────────────

  /// Padding horizontal estándar de pantallas.
  static const double screenHorizontal = xl; // 24

  /// Separación vertical entre secciones de una pantalla.
  static const double sectionGap = xxl; // 32

  /// Separación vertical entre cards de una lista.
  static const double listGap = md; // 12
}
