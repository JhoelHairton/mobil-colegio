import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_shadows.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/category_chip.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/floating_bottom_nav.dart';
import 'package:agenda_escolar_adventista/core/widgets/modern_header.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';

/// Vitrina del design system. Una sola pantalla con muestrario de
/// colores, tipografía, espaciado, radios, sombras y todos los
/// widgets nuevos.
///
/// Uso: navegar a `/style-guide` (definida en AppRoutes).
class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  int _selectedChip = 0;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              ModernHeader(
                title: 'Style Guide',
                subtitle: 'Sistema visual de la app — Sereno y moderno',
                showBack: true,
                trailing: Icon(
                  PhosphorIcons.palette(),
                  color: AppColors.textSecondary,
                ),
                chips: [
                  CategoryChip(
                    label: 'Todos',
                    selected: _selectedChip == 0,
                    onTap: () => setState(() => _selectedChip = 0),
                  ),
                  CategoryChip(
                    label: 'Cultural',
                    icon: PhosphorIcons.musicNotes(),
                    color: AppColors.categoryCultural,
                    selected: _selectedChip == 1,
                    onTap: () => setState(() => _selectedChip = 1),
                  ),
                  CategoryChip(
                    label: 'Espiritual',
                    icon: PhosphorIcons.bookOpen(),
                    color: AppColors.categorySpiritual,
                    selected: _selectedChip == 2,
                    onTap: () => setState(() => _selectedChip = 2),
                  ),
                  CategoryChip(
                    label: 'Académico',
                    icon: PhosphorIcons.graduationCap(),
                    color: AppColors.categoryAcademic,
                    selected: _selectedChip == 3,
                    onTap: () => setState(() => _selectedChip = 3),
                  ),
                  CategoryChip(
                    label: 'Deportivo',
                    icon: PhosphorIcons.basketball(),
                    color: AppColors.categorySports,
                    selected: _selectedChip == 4,
                    onTap: () => setState(() => _selectedChip = 4),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _ColorsSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _TypographySection(),
              const SizedBox(height: AppSpacing.xxl),
              const _SpacingSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _RadiusSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _ShadowsSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _ChipsSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _SkeletonSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _EmptyStateSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _ButtonsSection(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              items: [
                FloatingNavItem(
                  icon: PhosphorIcons.house(),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Inicio',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.calendar(),
                  activeIcon: PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                  label: 'Eventos',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.folder(),
                  activeIcon: PhosphorIcons.folder(PhosphorIconsStyle.fill),
                  label: 'Documentos',
                ),
                FloatingNavItem(
                  icon: PhosphorIcons.user(),
                  activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// SECCIONES
// ─────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (description != null)
            Text(
              description!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Paleta', description: 'Colores institucionales'),
        _ColorGroup(
          title: 'Primarios',
          swatches: const [
            _Swatch('primary', AppColors.primary),
            _Swatch('primaryLight', AppColors.primaryLight),
            _Swatch('primarySoft', AppColors.primarySoft),
            _Swatch('primaryDeep', AppColors.primaryDeep),
          ],
        ),
        _ColorGroup(
          title: 'Acento',
          swatches: const [
            _Swatch('accent', AppColors.accent),
            _Swatch('accentSoft', AppColors.accentSoft),
          ],
        ),
        _ColorGroup(
          title: 'Fondos',
          swatches: const [
            _Swatch('background', AppColors.background),
            _Swatch('surface', AppColors.surface),
            _Swatch('surfaceMuted', AppColors.surfaceMuted),
          ],
        ),
        _ColorGroup(
          title: 'Texto',
          swatches: const [
            _Swatch('textPrimary', AppColors.textPrimary),
            _Swatch('textSecondary', AppColors.textSecondary),
            _Swatch('textTertiary', AppColors.textTertiary),
          ],
        ),
        _ColorGroup(
          title: 'Categorías',
          swatches: const [
            _Swatch('cultural', AppColors.categoryCultural),
            _Swatch('spiritual', AppColors.categorySpiritual),
            _Swatch('academic', AppColors.categoryAcademic),
            _Swatch('sports', AppColors.categorySports),
            _Swatch('campaign', AppColors.categoryCampaign),
          ],
        ),
        _ColorGroup(
          title: 'Semánticos',
          swatches: const [
            _Swatch('success', AppColors.success),
            _Swatch('successSoft', AppColors.successSoft),
            _Swatch('warning', AppColors.warning),
            _Swatch('warningSoft', AppColors.warningSoft),
            _Swatch('error', AppColors.error),
            _Swatch('errorSoft', AppColors.errorSoft),
            _Swatch('info', AppColors.info),
            _Swatch('infoSoft', AppColors.infoSoft),
          ],
        ),
      ],
    );
  }
}

class _Swatch {
  const _Swatch(this.name, this.color);
  final String name;
  final Color color;
}

class _ColorGroup extends StatelessWidget {
  const _ColorGroup({required this.title, required this.swatches});

  final String title;
  final List<_Swatch> swatches;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: swatches.map(_buildTile).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(_Swatch s) {
    final hex = '#${s.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(s.name, style: AppTextStyles.bodySmall),
          Text(
            hex,
            style: AppTextStyles.metadata,
          ),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final samples = <(String, TextStyle)>[
      ('display 40 / w800', AppTextStyles.display),
      ('displaySmall 32 / w700', AppTextStyles.displaySmall),
      ('h1 28 / w700', AppTextStyles.h1),
      ('h2 22 / w600', AppTextStyles.h2),
      ('h3 18 / w600', AppTextStyles.h3),
      ('h4 16 / w500', AppTextStyles.h4),
      ('bodyLarge 16', AppTextStyles.bodyLarge),
      ('bodyMedium 14', AppTextStyles.bodyMedium),
      ('bodySmall 13', AppTextStyles.bodySmall),
      ('label 12 UPPER', AppTextStyles.label),
      ('caption 12', AppTextStyles.caption),
      ('metadata 11', AppTextStyles.metadata),
      ('buttonLarge 16', AppTextStyles.buttonLarge),
      ('buttonRegular 14', AppTextStyles.buttonRegular),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Tipografía',
            description: 'Inter — jerarquía completa'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, style) in samples) ...[
                Text(name, style: AppTextStyles.metadata),
                Text(
                  name == 'label 12 UPPER'
                      ? 'EJEMPLO DE LABEL'
                      : 'Ejemplo del estilo',
                  style: style,
                ),
                const SizedBox(height: AppSpacing.base),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final scale = <(String, double)>[
      ('xs', AppSpacing.xs),
      ('sm', AppSpacing.sm),
      ('md', AppSpacing.md),
      ('base', AppSpacing.base),
      ('lg', AppSpacing.lg),
      ('xl', AppSpacing.xl),
      ('xxl', AppSpacing.xxl),
      ('xxxl', AppSpacing.xxxl),
      ('xxxxl', AppSpacing.xxxxl),
      ('xxxxxl', AppSpacing.xxxxxl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Espaciado', description: 'Escala base 4 px'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              for (final (name, value) in scale)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(name, style: AppTextStyles.bodySmall),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${value.toInt()}px',
                          style: AppTextStyles.metadata,
                        ),
                      ),
                      Container(
                        width: value,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final scale = <(String, double)>[
      ('xs (6)', AppRadius.xs),
      ('sm (8)', AppRadius.sm),
      ('base (12)', AppRadius.base),
      ('md (16)', AppRadius.md),
      ('lg (20)', AppRadius.lg),
      ('xl (24)', AppRadius.xl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Bordes redondeados'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final (name, value) in scale)
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(value),
                        border: Border.all(color: AppColors.primary, width: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(name, style: AppTextStyles.metadata),
                  ],
                ),
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(color: AppColors.primary, width: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('full', style: AppTextStyles.metadata),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShadowsSection extends StatelessWidget {
  const _ShadowsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Sombras', description: 'Suaves, sin profundidad pesada'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              _ShadowTile(label: 'shadowSm', shadow: AppShadows.shadowSm),
              _ShadowTile(label: 'shadowMd', shadow: AppShadows.shadowMd),
              _ShadowTile(label: 'shadowLg', shadow: AppShadows.shadowLg),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShadowTile extends StatelessWidget {
  const _ShadowTile({required this.label, required this.shadow});

  final String label;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderMd,
            boxShadow: shadow,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _ChipsSection extends StatelessWidget {
  const _ChipsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Category chips',
            description: 'Filtros y categorías de eventos'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              CategoryChip(label: 'No seleccionado', onTap: () {}),
              CategoryChip(
                label: 'Seleccionado',
                selected: true,
                onTap: () {},
              ),
              CategoryChip(
                label: 'Cultural',
                icon: PhosphorIcons.musicNotes(),
                color: AppColors.categoryCultural,
                selected: true,
                onTap: () {},
              ),
              CategoryChip(
                label: 'Espiritual',
                icon: PhosphorIcons.bookOpen(),
                color: AppColors.categorySpiritual,
                onTap: () {},
              ),
              CategoryChip(
                label: 'Académico',
                icon: PhosphorIcons.graduationCap(),
                color: AppColors.categoryAcademic,
                selected: true,
                onTap: () {},
              ),
              CategoryChip(
                label: 'Deportivo',
                icon: PhosphorIcons.basketball(),
                color: AppColors.categorySports,
                onTap: () {},
              ),
              CategoryChip(
                label: 'Campaña',
                icon: PhosphorIcons.megaphone(),
                color: AppColors.categoryCampaign,
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonSection extends StatelessWidget {
  const _SkeletonSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle('Skeletons', description: 'Loading con shimmer (1.4s)'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              SkeletonCard(),
              SizedBox(height: AppSpacing.md),
              SkeletonCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyStateSection extends StatelessWidget {
  const _EmptyStateSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Estado vacío'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: SizedBox(
            height: 360,
            child: EmptyState(
              icon: PhosphorIcons.calendarBlank(),
              title: 'Aún no hay eventos',
              subtitle:
                  'Cuando la administración publique nuevos eventos aparecerán aquí.',
              actionLabel: 'Configurar notificaciones',
              onAction: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Botones'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('ElevatedButton (primario)'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () {},
                child: const Text('OutlinedButton (secundario)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {},
                child: const Text('TextButton (terciario)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
