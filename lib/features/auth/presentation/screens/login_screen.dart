import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
//import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/utils/validators.dart';
import 'package:agenda_escolar_adventista/core/widgets/custom_text_field.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // ── Controlador para la animación de entrada del panel
  late AnimationController _panelController;
  late Animation<double> _panelSlide;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _panelSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic),
    );
    // Inicia la animación del panel al cargar
    Future.delayed(200.ms, () {
      if (mounted) _panelController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // LÓGICA (sin cambios)
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signIn = ref.read(signInUseCaseProvider);
      final user = await signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      switch (user.role) {
        case UserRole.parent:
          context.go(AppRoutes.parentHome);
        case UserRole.teacher:
          context.go(AppRoutes.teacherHome);
        case UserRole.student:
          context.go(AppRoutes.studentHome);
        case UserRole.admin:
        case UserRole.secretary:
          context.go(AppRoutes.adminHome);
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('AuthException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.primaryDeep,
        body: Stack(
          children: [
            // ── Fondo con imagen del campus
            Positioned.fill(child: _buildBackground(size)),

            // ── Panel inferior deslizable con formulario
            _buildSlideUpPanel(context, size),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FONDO (mismo lenguaje que WelcomeScreen)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen del campus
        Image.asset(
          'assets/images/welcome_students.png',
          fit: BoxFit.cover,
        ),

        // Degradado oscuro principal
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.20),
                Colors.black.withValues(alpha: 0.35),
                AppColors.primaryDeep.withValues(alpha: 0.88),
                AppColors.primaryDeep,
              ],
              stops: const [0.0, 0.30, 0.60, 1.0],
            ),
          ),
        ),

        // Brillo dorado sutil inferior izquierdo
        Positioned(
          bottom: size.height * 0.35,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
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

        // ── ZONA SUPERIOR visible detrás del panel
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón volver — integrado en el fondo
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.welcome),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      PhosphorIcons.arrowLeft(),
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 18,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .slideX(begin: -0.05, end: 0),

                const SizedBox(height: AppSpacing.xl),

                // Ícono + nombre del colegio
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
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
                        size: 16,
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
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Text(
                          'JULIACA',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.xl),

                // Título editorial sobre el fondo
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 1,
                      color: AppColors.accent.withValues(alpha: 0.65),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'ACCESO AL PORTAL',
                      style: TextStyle(
                        color: AppColors.accent.withValues(alpha: 0.70),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 500.ms)
                    .slideX(begin: -0.04, end: 0),

                const SizedBox(height: AppSpacing.base),

                Text(
                  'Hola,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 340.ms, duration: 600.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

                const Text(
                  'de nuevo.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: -1.0,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 420.ms, duration: 600.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Inicia sesión para continuar.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PANEL INFERIOR (slide-up con formulario)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSlideUpPanel(BuildContext context, Size size) {
    return AnimatedBuilder(
      animation: _panelSlide,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, _panelSlide.value * 60),
            child: Opacity(
              opacity: (1 - _panelSlide.value).clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: size.height * 0.64,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Pill handle decorativo
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Banner de error
                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!)
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: -0.08, end: 0),

                  // ── Campo email
                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSpacing.base),

                  // ── Campo contraseña
                  CustomTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => Validators.required(
                      v,
                      message: 'Ingresa tu contraseña',
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 380.ms, duration: 400.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          curve: Curves.easeOutCubic),

                  // ── ¿Olvidaste contraseña?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onPressed: () =>
                          context.push(AppRoutes.forgotPassword),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ).animate(delay: 440.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Botón principal
                  PrimaryButton(
                    label: 'Iniciar sesión',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    height: 56,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Divisor elegante
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.border,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text(
                          '¿primera vez?',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.border,
                        ),
                      ),
                    ],
                  ).animate(delay: 560.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Botón activar cuenta (texto fino)
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.activate),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Activar mi cuenta ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            children: [
                              TextSpan(
                                text: '→',
                                style: TextStyle(
                                  color:
                                      AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: 620.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BANNER DE ERROR (mismo estilo limpio)
// ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}