import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/core/widgets/secondary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  late final List<_BimesterData> _bimesters = [
    _BimesterData(
      title: 'PRIMER BIMESTRE',
      period: '2 MAR — 8 MAY',
      accent: AppColors.categorySpiritual,
      gradientColors: const [AppColors.primaryDeep, AppColors.primary],
      icon: PhosphorIcons.graduationCap(PhosphorIconsStyle.duotone),
      events: const [
        _EventData('Inicio del Año Escolar', '2 de marzo'),
        _EventData('Semana de Énfasis Espiritual', '2 — 6 de marzo'),
        _EventData('Día del Joven Adventista', '15 de marzo'),
        _EventData('Campaña Antibullying', '17 — 20 de marzo'),
        _EventData('Evangelismo Semana Santa', '30 mar — 1 abr'),
        _EventData('Aniversario Institucional', '30 de abril'),
        _EventData('Receso Estudiantil', '11 — 15 de mayo'),
      ],
    ),
    _BimesterData(
      title: 'SEGUNDO BIMESTRE',
      period: '18 MAY — 24 JUL',
      accent: AppColors.categoryAcademic,
      gradientColors: const [Color(0xFF0F766E), AppColors.categoryAcademic],
      icon: PhosphorIcons.heart(PhosphorIconsStyle.duotone),
      events: const [
        _EventData('Día del Aventurero', '16 de mayo'),
        _EventData('Sábado de la Educación', '30 de mayo'),
        _EventData('Semana de la Familia', '12 — 14 de junio'),
        _EventData('Día del Maestro Adventista', '3 de julio'),
        _EventData('Programa Caleb Omega', '23 jul — 1 ago'),
        _EventData('Vacaciones de Medio Año', '27 jul — 7 ago'),
      ],
    ),
    _BimesterData(
      title: 'TERCER BIMESTRE',
      period: '10 AGO — 2 OCT',
      accent: AppColors.categoryCultural,
      gradientColors: const [Color(0xFF6D28D9), AppColors.categoryCultural],
      icon: PhosphorIcons.usersThree(PhosphorIconsStyle.duotone),
      events: const [
        _EventData('Inicio del II Semestre', '10 de agosto'),
        _EventData('Proyecto "Basta de Silencio"', '22 de agosto'),
        _EventData('Congreso EXPLORE 5.0', '3 — 6 de setiembre'),
        _EventData('Día del Conquistador', '19 de setiembre'),
        _EventData('Semana de Esperanza', '19 — 26 de setiembre'),
        _EventData('Bautismo de Primavera', '26 de setiembre'),
        _EventData('Semana Jubilar', '29 sep — 2 oct'),
      ],
    ),
    _BimesterData(
      title: 'CUARTO BIMESTRE',
      period: '12 OCT — 17 DIC',
      accent: AppColors.accent,
      gradientColors: const [AppColors.primaryDeep, AppColors.primary],
      icon: PhosphorIcons.gift(PhosphorIconsStyle.duotone),
      events: const [
        _EventData('Día del Logro Educativo', '24 — 28 de noviembre'),
        _EventData('Programa Navideño', '14 — 18 de diciembre'),
        _EventData('Graduación y Clausura', '18 — 20 de diciembre'),
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _bimesters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() => context.go(AppRoutes.welcome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _bimesters.length,
                itemBuilder: (_, i) => _BimesterSlide(
                  data: _bimesters[i],
                  key: ValueKey(i),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALENDARIO ACADÉMICO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '2026 · Año Escolar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _finish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'OMITIR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: _bimesters.length,
            effect: const ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3,
              spacing: 8,
            ),
          ),
          const SizedBox(height: 20),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _bimesters.length - 1;

    if (isFirst) {
      return PrimaryButton(
        label: 'COMENZAR RECORRIDO',
        icon: Icons.arrow_forward_rounded,
        onPressed: _nextPage,
        height: 52,
      );
    }
    if (isLast) {
      return PrimaryButton(
        label: 'IR AL INICIO',
        icon: Icons.check_rounded,
        onPressed: _finish,
        height: 52,
      );
    }
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: 'ANTERIOR',
            icon: Icons.arrow_back_rounded,
            onPressed: _previousPage,
            height: 52,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: 'SIGUIENTE',
            icon: Icons.arrow_forward_rounded,
            onPressed: _nextPage,
            height: 52,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _BimesterSlide extends StatelessWidget {
  const _BimesterSlide({super.key, required this.data});

  final _BimesterData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          // Tarjeta principal con gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradientColors,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Patrón decorativo de fondo
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          data.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.period,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${data.events.length} EVENTOS PROGRAMADOS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            curve: Curves.easeOutCubic,
          ),

          const SizedBox(height: 28),

          // Título de sección
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    PhosphorIcons.listChecks(PhosphorIconsStyle.bold),
                    size: 14,
                    color: data.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CALENDARIO DE EVENTOS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Lista de eventos
          ...data.events.asMap().entries.map((entry) {
            return _EventCard(
              event: entry.value,
              index: entry.key,
              accent: data.accent,
              isLast: entry.key == data.events.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.index,
    required this.accent,
    this.isLast = false,
  });

  final _EventData event;
  final int index;
  final Color accent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Círculo decorativo con fecha
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.15),
                        accent.withValues(alpha: 0.05)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      event.date.split(' ').first,
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                            size: 10,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.date,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Icono flecha
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                    size: 14,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(
      delay: Duration(milliseconds: 80 * index),
    ).fadeIn(
      duration: 350.ms,
    ).slideX(
      begin: 0.03,
      end: 0,
      curve: Curves.easeOutCubic,
    );
  }

  void _showEventDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        PhosphorIcons.info(PhosphorIconsStyle.duotone),
                        size: 24,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.date,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text('CERRAR'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BimesterData {
  final String title;
  final String period;
  final Color accent;
  final List<Color> gradientColors;
  final IconData icon;
  final List<_EventData> events;

  const _BimesterData({
    required this.title,
    required this.period,
    required this.accent,
    required this.gradientColors,
    required this.icon,
    required this.events,
  });
}

class _EventData {
  final String title;
  final String date;

  const _EventData(this.title, this.date);
}