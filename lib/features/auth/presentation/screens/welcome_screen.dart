import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
//import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _hintController;
  late Animation<double> _hintAnim;

  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isNavigating = false;

  static const double _trackWidth = 280.0;
  static const double _thumbSize = 62.0;
  static const double _maxOffset = (_trackWidth - _thumbSize) / 2;
  static const double _triggerThreshold = 0.68;

  _SlideDirection _hintDirection = _SlideDirection.none;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _hintAnim = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    Future.delayed(2000.ms, _playHintAnimation);
  }

  Future<void> _playHintAnimation() async {
    if (!mounted || _isDragging) return;
    setState(() => _hintDirection = _SlideDirection.right);
    await _hintController.forward();
    await _hintController.reverse();
    await Future.delayed(350.ms);
    if (!mounted || _isDragging) return;
    setState(() => _hintDirection = _SlideDirection.left);
    await _hintController.forward();
    await _hintController.reverse();
    if (mounted) setState(() => _hintDirection = _SlideDirection.none);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  double get _totalOffset {
    if (_isDragging) return _dragOffset;
    return switch (_hintDirection) {
      _SlideDirection.right => _hintAnim.value,
      _SlideDirection.left => -_hintAnim.value,
      _SlideDirection.none => 0.0,
    };
  }

  double get _ratio => (_dragOffset / _maxOffset).clamp(-1.0, 1.0);

  Color get _trackColor {
    if (_dragOffset > 10) {
      return Color.lerp(
        Colors.white.withValues(alpha: 0.12),
        AppColors.primaryLight.withValues(alpha: 0.50),
        (_dragOffset / _maxOffset).clamp(0.0, 1.0),
      )!;
    } else if (_dragOffset < -10) {
      return Color.lerp(
        Colors.white.withValues(alpha: 0.12),
        AppColors.accent.withValues(alpha: 0.42),
        (-_dragOffset / _maxOffset).clamp(0.0, 1.0),
      )!;
    }
    return Colors.white.withValues(alpha: 0.12);
  }

  Color get _thumbColor {
    if (_dragOffset > 10) {
      return Color.lerp(Colors.white, AppColors.primaryLight,
          (_dragOffset / _maxOffset).clamp(0.0, 1.0))!;
    } else if (_dragOffset < -10) {
      return Color.lerp(Colors.white, AppColors.accent,
          (-_dragOffset / _maxOffset).clamp(0.0, 1.0))!;
    }
    return Colors.white;
  }

  IconData get _thumbIcon {
    if (_dragOffset > 28) return Icons.lock_open_rounded;
    if (_dragOffset < -28) return Icons.person_add_rounded;
    return Icons.drag_indicator_rounded;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_isNavigating) return;
    _hintController.stop();
    setState(() {
      _isDragging = true;
      _hintDirection = _SlideDirection.none;
      _dragOffset =
          (_dragOffset + d.delta.dx).clamp(-_maxOffset, _maxOffset);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_isNavigating) return;
    final ratio = _dragOffset / _maxOffset;
    if (ratio >= _triggerThreshold) {
      _triggerNavigation(AppRoutes.login);
    } else if (ratio <= -_triggerThreshold) {
      _triggerNavigation(AppRoutes.activate);
    } else {
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
      });
    }
  }

  Future<void> _triggerNavigation(String route) async {
    setState(() => _isNavigating = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(180.ms);
    if (mounted) {
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
        _isNavigating = false;
      });
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.primaryDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Fondo
            _buildBackground(size),

            // ── Contenido
            _buildContent(context, size),

            // ── DEV: Style Guide
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 4,
              child: IconButton(
                tooltip: 'Style Guide',
                icon: Icon(
                  PhosphorIcons.palette(),
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                onPressed: () => context.push(AppRoutes.styleGuide),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FONDO
  // ─────────────────────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen real del campus
        Image.asset(
          'assets/images/welcome_building.png',
          fit: BoxFit.cover,
        ),

        // Degradado principal — más oscuro abajo para que el slider sea claro
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.30),
                AppColors.primaryDeep.withValues(alpha: 0.80),
                AppColors.primaryDeep.withValues(alpha: 0.97),
                AppColors.primaryDeep,
              ],
              stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
            ),
          ),
        ),

        // Vignette lateral izquierda sutil
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: size.width * 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primaryDeep.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Brillo dorado inferior izquierdo
        Positioned(
          bottom: size.height * 0.18,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CONTENIDO
  // ─────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, Size size) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── ZONA SUPERIOR: Label + número del año
          _buildTopBar()
              .animate()
              .fadeIn(delay: 150.ms, duration: 700.ms),

          const Spacer(),

          // ── ZONA CENTRAL: Tipografía editorial
          _buildEditorialText()
              .animate()
              .fadeIn(delay: 350.ms, duration: 800.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: AppSpacing.xxl),

          // ── ZONA INFERIOR: Slider + link
          _buildBottomZone(context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BARRA SUPERIOR
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo / ícono del colegio
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              PhosphorIcons.graduationCap(PhosphorIconsStyle.fill),
              size: 18,
              color: AppColors.accent,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Colegio Adventista',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.8,
                ),
              ),
              const Text(
                'JULIACA',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),

          const Spacer(),

          
          
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TEXTO EDITORIAL (alineado a la izquierda, tipografía fina)
  // ─────────────────────────────────────────────────────────────
  Widget _buildEditorialText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea decorativa + etiqueta
          Row(
            children: [
              Container(
                width: 24,
                height: 1,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AGENDA DIGITAL',
                style: TextStyle(
                  color: AppColors.accent.withValues(alpha: 0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.5,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideX(begin: -0.04, end: 0),

          const SizedBox(height: AppSpacing.lg),

          // Título principal — peso ultra fino en la primera línea
          Text(
            'Excelencia',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 46,
              fontWeight: FontWeight.w200, // Ultra fino
              height: 1.05,
              letterSpacing: -0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 480.ms, duration: 700.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

          // Segunda línea — bold para contraste tipográfico
          const Text(
            'que trasciende.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.w700,
              height: 1.05,
              letterSpacing: -1.0,
            ),
          )
              .animate()
              .fadeIn(delay: 560.ms, duration: 700.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: AppSpacing.base),

          // Acento dorado — peso light
          const Text(
            'Valores que guían.',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 650.ms, duration: 600.ms),

          const SizedBox(height: AppSpacing.md),

          // Descripción — peso extralight
          Text(
            'Conecta familias · Gestiona eventos\nFormación integral · Valores adventistas',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 13,
              fontWeight: FontWeight.w300,
              height: 1.65,
              letterSpacing: 0.2,
            ),
          )
              .animate()
              .fadeIn(delay: 730.ms, duration: 600.ms),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ZONA INFERIOR: Slider + "Conoce más"
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomZone(BuildContext context) {
    return Column(
      children: [
        // Etiquetas de dirección
        _buildDirectionLabels()
            .animate()
            .fadeIn(delay: 880.ms, duration: 500.ms),

        const SizedBox(height: 10),

        // Slider
        _buildSlider()
            .animate()
            .fadeIn(delay: 960.ms, duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: AppSpacing.lg),

        // "Conoce más sobre la app"
        GestureDetector(
          onTap: () => context.push(AppRoutes.onboarding),
          child: Text(
            'Ver calendario de eventos 2026',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.3,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ).animate(delay: 1060.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ETIQUETAS DE DIRECCIÓN
  // ─────────────────────────────────────────────────────────────
  Widget _buildDirectionLabels() {
    final rightOpacity =
        (0.38 + _ratio.clamp(0.0, 1.0) * 0.62).clamp(0.0, 1.0);
    final leftOpacity =
        (0.38 + (-_ratio).clamp(0.0, 1.0) * 0.62).clamp(0.0, 1.0);

    return SizedBox(
      width: _trackWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← Activar cuenta
          AnimatedOpacity(
            opacity: leftOpacity,
            duration: const Duration(milliseconds: 80),
            child:const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 10, color: AppColors.accent,),
                SizedBox(width: 5),
                 Text(
                  'Activar cuenta',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Iniciar sesión →
          AnimatedOpacity(
            opacity: rightOpacity,
            duration: const Duration(milliseconds: 80),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                 SizedBox(width: 5),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.primaryLight,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SLIDER TIPO DESBLOQUEO
  // ─────────────────────────────────────────────────────────────
  Widget _buildSlider() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _hintController]),
      builder: (context, _) {
        final offset = _totalOffset;

        final labelOpacity =
            (1.0 - (_dragOffset.abs() / (_maxOffset * 0.38)))
                .clamp(0.0, 1.0);

        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: () {
            if (!_isNavigating) {
              setState(() {
                _isDragging = false;
                _dragOffset = 0;
              });
            }
          },
          child: Container(
            width: _trackWidth,
            height: 70,
            decoration: BoxDecoration(
              color: _trackColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Texto central de instrucción
                AnimatedOpacity(
                  opacity: labelOpacity,
                  duration: const Duration(milliseconds: 50),
                  child: Text(
                    '← · · ·  desliza  · · · →',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),

                // Thumb
                AnimatedContainer(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(offset, 0, 0),
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: _thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Pulso vivo
                      BoxShadow(
                        color: _thumbColor.withValues(
                          alpha: 0.28 + _pulseController.value * 0.20,
                        ),
                        blurRadius: 12 + _pulseController.value * 14,
                        spreadRadius: _pulseController.value * 3,
                      ),
                      // Sombra dura base
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      _thumbIcon,
                      key: ValueKey(_thumbIcon),
                      color: AppColors.primaryDeep,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
enum _SlideDirection { none, left, right }