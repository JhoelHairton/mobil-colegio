import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mi asistencia')),
      body: const Center(child: Text('Historial - Por implementar')),
    );
  }
}
