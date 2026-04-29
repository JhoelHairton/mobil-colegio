import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:agenda_escolar_adventista/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formato de fechas en español Perú.
  await initializeDateFormatting('es_PE', null);

  // Firebase se inicializará en Sprint 7. Por ahora la app corre con mock data.

  runApp(
    const ProviderScope(
      child: AgendaEscolarApp(),
    ),
  );
}
