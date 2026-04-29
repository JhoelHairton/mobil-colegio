import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  const AttendanceSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 80, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('¡Asistencia registrada!', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('Entrada registrada correctamente', style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
