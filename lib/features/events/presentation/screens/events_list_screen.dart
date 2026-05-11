import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/category_chip.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/error_view.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_card.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredEventsProvider);
    final selectedCategory = ref.watch(selectedEventCategoryProvider);
    final selectedRange = ref.watch(selectedEventTimeRangeProvider);

    final subtitle = filtered.maybeWhen(
      data: (list) => _buildSubtitle(list.length, selectedRange),
      orElse: () => 'Cargando agenda…',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _EventsHeader(
            subtitle: subtitle,
            chips: _buildCategoryChips(ref, selectedCategory),
            onBack: () => _handleBack(context, ref),
          ),
          const _SearchAndRangeBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(eventsStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(eventsStreamProvider),
                  ),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return _ScrollableSingle(
                      child: _buildEmptyState(ref, selectedCategory, selectedRange),
                    );
                  }
                  return _EventsList(events: events);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vuelve al home del rol actual si no hay nada en el stack de
  /// go_router. Evita la pantalla en negro cuando llegamos por
  /// `context.go(...)` o por deep link.
  void _handleBack(BuildContext context, WidgetRef ref) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final role = ref.read(currentUserProvider)?.role;
    final fallback = switch (role) {
      UserRole.teacher => AppRoutes.teacherHome,
      UserRole.student => AppRoutes.studentHome,
      UserRole.parent => AppRoutes.parentHome,
      _ => AppRoutes.parentHome,
    };
    context.go(fallback);
  }

  String _buildSubtitle(int count, EventTimeRange range) {
    if (range == EventTimeRange.past) {
      if (count == 0) return 'No hay eventos pasados con estos filtros';
      return count == 1 ? '1 evento en el archivo' : '$count eventos en el archivo';
    }
    if (count == 0) return 'No hay próximos con estos filtros';
    return count == 1 ? '1 evento próximo' : '$count eventos próximos';
  }

  List<Widget> _buildCategoryChips(WidgetRef ref, EventCategory? selected) {
    final controller = ref.read(selectedEventCategoryProvider.notifier);
    return [
      CategoryChip(
        label: 'Todos',
        selected: selected == null,
        onTap: () => controller.state = null,
      ),
      ...EventCategory.values.map(
        (cat) => CategoryChip(
          label: cat.displayName,
          icon: cat.icon,
          color: cat.color,
          selected: selected == cat,
          onTap: () => controller.state = cat,
        ),
      ),
    ];
  }

  Widget _buildEmptyState(
    WidgetRef ref,
    EventCategory? category,
    EventTimeRange range,
  ) {
    final query = ref.read(eventSearchQueryProvider);
    final hasQuery = query.trim().isNotEmpty;

    if (hasQuery) {
      return EmptyState(
        icon: PhosphorIcons.magnifyingGlass(),
        title: 'Sin resultados para "$query"',
        subtitle: 'Prueba con otra palabra o limpia los filtros activos.',
        actionLabel: 'Limpiar búsqueda',
        onAction: () => ref.read(eventSearchQueryProvider.notifier).state = '',
      );
    }

    if (category != null) {
      return EmptyState(
        icon: PhosphorIcons.calendarBlank(),
        title: 'Sin eventos en ${category.displayName}',
        subtitle: 'Prueba con otra categoría o vuelve a "Todos".',
        actionLabel: 'Ver todas las categorías',
        onAction: () =>
            ref.read(selectedEventCategoryProvider.notifier).state = null,
      );
    }

    if (range == EventTimeRange.past) {
      return EmptyState(
        icon: PhosphorIcons.archive(),
        title: 'Aún no hay eventos pasados',
        subtitle: 'Cuando un evento finalice, aparecerá aquí en el archivo.',
        actionLabel: 'Ver próximos',
        onAction: () =>
            ref.read(selectedEventTimeRangeProvider.notifier).state =
                EventTimeRange.upcoming,
      );
    }

    return EmptyState(
      icon: PhosphorIcons.calendarBlank(),
      title: 'Aún no hay eventos próximos',
      subtitle:
          'Cuando la administración publique nuevos eventos, aparecerán aquí.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER INLINE
// ─────────────────────────────────────────────────────────────────────────

/// Header específico de eventos: la flecha de back va en la MISMA fila
/// que el título "Eventos", no encima.
class _EventsHeader extends StatelessWidget {
  const _EventsHeader({
    required this.subtitle,
    required this.chips,
    required this.onBack,
  });

  final String subtitle;
  final List<Widget> chips;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleIconButton(
                  icon: PhosphorIcons.arrowLeft(),
                  onTap: onBack,
                  semanticsLabel: 'Volver',
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Eventos',
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Subtítulo alineado al título (no a la flecha).
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxxxl, // 56 = ancho del back + gap
                top: 2,
              ),
              child: Text(
                subtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            // Chips de categoría con scroll horizontal.
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                itemCount: chips.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => chips[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderBase,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// FILTERS BAR — search + segmento Próximos/Pasados
// ─────────────────────────────────────────────────────────────────────────

class _SearchAndRangeBar extends ConsumerStatefulWidget {
  const _SearchAndRangeBar();

  @override
  ConsumerState<_SearchAndRangeBar> createState() => _SearchAndRangeBarState();
}

class _SearchAndRangeBarState extends ConsumerState<_SearchAndRangeBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(eventSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mantiene el TextField sincronizado si el provider se limpia desde
    // afuera (por ejemplo con el botón "Limpiar búsqueda" del empty state).
    final externalQuery = ref.watch(eventSearchQueryProvider);
    if (externalQuery != _controller.text) {
      _controller.value = TextEditingValue(
        text: externalQuery,
        selection: TextSelection.collapsed(offset: externalQuery.length),
      );
    }

    final selectedRange = ref.watch(selectedEventTimeRangeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          _SearchField(
            controller: _controller,
            onChanged: (value) =>
                ref.read(eventSearchQueryProvider.notifier).state = value,
            onClear: () {
              _controller.clear();
              ref.read(eventSearchQueryProvider.notifier).state = '';
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _RangeSegment(
            selected: selectedRange,
            onChanged: (range) => ref
                .read(selectedEventTimeRangeProvider.notifier)
                .state = range,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Buscar evento o lugar',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: Icon(
          PhosphorIcons.magnifyingGlass(),
          size: 18,
          color: AppColors.textTertiary,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                onPressed: onClear,
                splashRadius: 18,
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm + 2,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
    );
  }
}

class _RangeSegment extends StatelessWidget {
  const _RangeSegment({required this.selected, required this.onChanged});

  final EventTimeRange selected;
  final ValueChanged<EventTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        children: EventTimeRange.values.map((range) {
          final isActive = range == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surface : Colors.transparent,
                  borderRadius: AppRadius.borderFull,
                  border: isActive
                      ? Border.all(color: AppColors.border, width: 0.5)
                      : null,
                ),
                child: Text(
                  range.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LISTA + ESTADOS
// ─────────────────────────────────────────────────────────────────────────

/// Listado animado con stagger (delay de 60ms por card).
class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // `always` asegura que el RefreshIndicator funcione aunque la lista
      // sea corta y no necesite scroll por sí sola.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => context.push('${AppRoutes.eventDetail}/${event.id}'),
        )
            .animate(delay: (index * 60).ms)
            .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (_, __) => const _SkeletonEventCard(),
    );
  }
}

/// Wrapper para que EmptyState/ErrorView sigan respondiendo a pull-to-refresh.
class _ScrollableSingle extends StatelessWidget {
  const _ScrollableSingle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

/// Skeleton con la misma silueta que [EventCard] (hero + texto).
class _SkeletonEventCard extends StatelessWidget {
  const _SkeletonEventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: const SkeletonGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 140, borderRadius: BorderRadius.zero),
            Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(widthFactor: 0.75, height: 18),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonText(widthFactor: 0.95, height: 12),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonText(widthFactor: 0.55, height: 12),
                  SizedBox(height: AppSpacing.md),
                  SkeletonText(widthFactor: 0.4, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
