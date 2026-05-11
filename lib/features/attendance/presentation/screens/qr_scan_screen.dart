import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/entities/attendance.dart';
import 'package:agenda_escolar_adventista/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

/// Tamaño de la ventana de escaneo (lado en logical pixels).
const double _scanWindowSize = 260;

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _processing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si la app pasa a background pausamos para liberar la cámara.
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.stop();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final code = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (code == null || code.isEmpty) return;
    await _attemptRegister(code);
  }

  /// Lo expone el botón "Demo" para probar el flujo en emuladores sin cámara.
  Future<void> _simulateValidScan() async {
    final todaysCode =
        ref.read(attendanceRepositoryProvider).getTodaysQrCode();
    await _attemptRegister(todaysCode);
  }

  Future<void> _attemptRegister(String qrPayload) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      _showSnackBar('Tu sesión expiró. Vuelve a iniciar sesión.');
      return;
    }
    setState(() => _processing = true);
    await _controller.stop();

    try {
      final result =
          await ref.read(recordAttendanceUseCaseProvider).call(
                teacherId: user.uid,
                qrPayload: qrPayload,
                deviceId: 'mock_device_${user.uid}',
              );
      if (!mounted) return;

      switch (result) {
        case AttendanceRegistered():
          context.go(AppRoutes.attendanceSuccess);
        case AttendanceAlreadyRegistered(:final existing):
          _showSnackBar(_alreadyMessage(existing));
          await _restartScanner();
        case AttendanceInvalidQr():
          _showSnackBar('Código inválido o no es del día. Inténtalo de nuevo.');
          await _restartScanner();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('No pudimos registrar la asistencia: $e');
      await _restartScanner();
    }
  }

  Future<void> _restartScanner() async {
    if (!mounted) return;
    setState(() => _processing = false);
    try {
      await _controller.start();
    } catch (_) {
      // Ignoramos: si la cámara no está disponible, el botón Demo
      // sigue funcionando.
    }
  }

  String _alreadyMessage(Attendance existing) {
    final hour = DateFormat('HH:mm').format(existing.checkInTime);
    return 'Ya registraste asistencia hoy a las $hour.';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (_, error, __) => _CameraError(error: error),
          ),
          // Overlay con ventana recortada y marco luminoso.
          const IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),
          const IgnorePointer(
            child: Center(
              child: SizedBox(
                width: _scanWindowSize,
                height: _scanWindowSize,
                child: _CornerFrame(),
              ),
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: PhosphorIcons.arrowLeft(),
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _CircleIconButton(
                    icon: _torchOn
                        ? PhosphorIcons.flashlight(PhosphorIconsStyle.fill)
                        : PhosphorIcons.flashlight(),
                    onTap: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          // Hint + botones inferiores
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enfoca el código QR del día',
                      style: AppTextStyles.h4.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'El código cambia cada día a las 5:00 AM',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: _processing ? null : _simulateValidScan,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderBase,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: Icon(PhosphorIcons.lightning(), size: 16),
                      label: const Text('Demo: simular escaneo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_processing) const _ProcessingOverlay(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// MARCO Y OVERLAY
// ─────────────────────────────────────────────────────────────────────────

/// Pinta el oscurecido alrededor de la ventana de escaneo (padrón
/// estándar en escáneres QR: vidrio negro con la ventana transparente).
class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: _scanWindowSize,
      height: _scanWindowSize,
    );
    final cutoutRRect =
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20));
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRRect);
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.55));
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) => false;
}

class _CornerFrame extends StatelessWidget {
  const _CornerFrame();

  static const Color _color = AppColors.accent;
  static const double _len = 28;
  static const double _thick = 3;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Esquinas
        Positioned(top: 0, left: 0, child: _corner(top: true, left: true)),
        Positioned(top: 0, right: 0, child: _corner(top: true, left: false)),
        Positioned(bottom: 0, left: 0, child: _corner(top: false, left: true)),
        Positioned(bottom: 0, right: 0, child: _corner(top: false, left: false)),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 300.ms)
        .then(delay: 200.ms)
        .scaleXY(begin: 1.0, end: 1.04, duration: 1200.ms);
  }

  Widget _corner({required bool top, required bool left}) {
    return SizedBox(
      width: _len,
      height: _len,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left, color: _color, thickness: _thick),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.top,
    required this.left,
    required this.color,
    required this.thickness,
  });

  final bool top;
  final bool left;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final h = size.width;
    final v = size.height;

    if (top && left) {
      canvas.drawLine(const Offset(0, 0), Offset(h, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(0, v), paint);
    } else if (top && !left) {
      canvas.drawLine(Offset(h, 0), const Offset(0, 0), paint);
      canvas.drawLine(Offset(h, 0), Offset(h, v), paint);
    } else if (!top && left) {
      canvas.drawLine(Offset(0, v), Offset(h, v), paint);
      canvas.drawLine(Offset(0, v), const Offset(0, 0), paint);
    } else {
      canvas.drawLine(Offset(h, v), Offset(0, v), paint);
      canvas.drawLine(Offset(h, v), Offset(h, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return oldDelegate.top != top ||
        oldDelegate.left != left ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// AUXILIARES
// ─────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Necesitamos acceso a la cámara para escanear el QR. '
            'Activa el permiso desde la configuración del sistema.',
      MobileScannerErrorCode.unsupported =>
        'Este dispositivo no soporta escaneo de QR.',
      _ => 'No pudimos abrir la cámara. Usa el botón "Demo" para registrar.',
    };
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.cameraSlash(),
                size: 56,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
