import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra los campos requeridos', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Avanzamos el reloj para que las animaciones de entrada terminen
    // y no queden Timers pendientes.
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
