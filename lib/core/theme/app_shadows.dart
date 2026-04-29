import 'package:flutter/material.dart';

/// Sombras del design system.
///
/// El estilo "sereno y moderno" prefiere bordes finos sobre sombras pesadas.
/// Usa estas sombras solo cuando aporten profundidad real:
/// - [shadowSm] — apenas perceptible, para cards elevados sutilmente.
/// - [shadowMd] — para hover/press de cards interactivos.
/// - [shadowLg] — modales, bottom sheets, menús flotantes.
class AppShadows {
  AppShadows._();

  /// Apenas perceptible — cards en reposo.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Hover y press de elementos interactivos.
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Modales y bottom sheets.
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}
