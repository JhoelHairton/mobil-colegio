import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/core/router/app_router.dart';
import 'package:agenda_escolar_adventista/core/theme/app_theme.dart';
import 'package:agenda_escolar_adventista/core/constants/app_constants.dart';

class AgendaEscolarApp extends ConsumerWidget {
  const AgendaEscolarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
