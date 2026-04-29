import 'package:flutter/material.dart';

/// Atajos sobre [BuildContext] de uso recurrente.
///
/// Evita escribir `Theme.of(context)` o `MediaQuery.sizeOf(context)`
/// repetidamente y centraliza helpers como `showSnack`.
extension AppContextExt on BuildContext {
  // ─────────────────────────────────────────────────────────────
  // THEME
  // ─────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ─────────────────────────────────────────────────────────────
  // MEDIA QUERY
  // ─────────────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Pantallas <600 px se consideran "compactas" (móvil en portrait).
  bool get isCompact => screenWidth < 600;

  // ─────────────────────────────────────────────────────────────
  // SNACKBARS
  // ─────────────────────────────────────────────────────────────

  /// Muestra un snackbar simple cancelando el actual si existía.
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
