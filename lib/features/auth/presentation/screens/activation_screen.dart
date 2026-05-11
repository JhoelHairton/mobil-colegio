import 'dart:ui';
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
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/utils/validators.dart';
import 'package:agenda_escolar_adventista/core/widgets/custom_text_field.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';

/// Pantalla de activación de cuenta institucional.
/// Con diseño consistente con LoginScreen: fondo con imagen del campus
/// y panel deslizable con el formulario.
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

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
    Future.delayed(150.ms, () {
      if (mounted) _panelController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  Future<void> _handleActivate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activate = ref.read(activateAccountUseCaseProvider);
      final user = await activate(
        email: _emailController.text.trim(),
        activationCode: _codeController.text.trim().toUpperCase(),
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      _showSuccessSnack(user.displayName);

      await Future<void>.delayed(const Duration(milliseconds: 800));
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
      HapticFeedback.heavyImpact();
      setState(
        () => _errorMessage = e.toString().replaceAll('AuthException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnack(String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          content: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
                  Expanded(
                child: Text(
                  '¡Bienvenido, $name! Cuenta activada correctamente.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

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
  // FONDO (mismo que LoginScreen)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen del campus
        Image.asset(
          'assets/images/welcome_building.png',
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

        // Brillo dorado sutil
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

        // ── ZONA SUPERIOR visible
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón volver
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
                    .fadeIn(delay: 80.ms, duration: 500.ms)
                    .slideX(begin: -0.05, end: 0),

                const SizedBox(height: AppSpacing.xl),

 
              
                Text(
                  'Activa tu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.06, end: 0),

                const Text(
                  'cuenta.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    letterSpacing: -1.0,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 380.ms, duration: 600.ms)
                    .slideY(begin: 0.06, end: 0),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Ingresa el código que te entregó la secretaría.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 460.ms, duration: 500.ms),
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
          maxHeight: size.height * 0.70,
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
                  // Handle decorativo
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

                  // Banner de error
                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!)
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: -0.08, end: 0),

                  // Campo email
                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.base),

                  // Campo código de activación (estilizado)
                  _ActivationCodeField(controller: _codeController)
                      .animate()
                      .fadeIn(delay: 280.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.lg),

                  // Subtítulo para las contraseñas
                  Text(
                    'Crea una contraseña permanente',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 360.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Nueva contraseña
                  CustomTextField(
                    label: 'Nueva contraseña',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: Validators.password,
                  )
                      .animate()
                      .fadeIn(delay: 420.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.base),

                  // Confirmar contraseña
                  CustomTextField(
                    label: 'Confirma la contraseña',
                    controller: _confirmController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (v != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 480.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  // Botón principal
                  PrimaryButton(
                    label: 'Activar cuenta',
                    icon: PhosphorIcons.check(PhosphorIconsStyle.bold),
                    onPressed: _handleActivate,
                    isLoading: _isLoading,
                    height: 56,
                  )
                      .animate()
                      .fadeIn(delay: 560.ms, duration: 400.ms)
                      .slideY(begin: 0.10, end: 0),

                  const SizedBox(height: AppSpacing.xl),

                  // Divisor elegante
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
                          '¿ya tienes cuenta?',
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
                  ).animate(delay: 640.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Botón secundario: Iniciar sesión
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go(AppRoutes.login);
                    },
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
                            text: 'Iniciar sesión ',
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
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

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
// CAMPO DE CÓDIGO DE ACTIVACIÓN (estilizado)
// ─────────────────────────────────────────────────────────────
class _ActivationCodeField extends StatelessWidget {
  const _ActivationCodeField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 8,
      style: AppTextStyles.h3.copyWith(
        letterSpacing: 6,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        _UpperCaseFormatter(),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Ingresa el código de activación';
        }
        if (v.trim().length != 8) {
          return 'El código tiene 8 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Código de activación',
        labelStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary),
        hintText: 'XXXXXXXX',
        hintStyle: AppTextStyles.h3.copyWith(
          letterSpacing: 6,
          color: AppColors.textTertiary.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
        ),
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
          child: Icon(
            PhosphorIcons.key(),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}