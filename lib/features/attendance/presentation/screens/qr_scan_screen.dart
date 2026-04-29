import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Escanear QR', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE8A33D), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 100, color: Color(0xFFE8A33D)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enfoca el código QR del día',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'El código cambia cada día a las 5:00 AM',
              style: AppTextStyles.caption.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
