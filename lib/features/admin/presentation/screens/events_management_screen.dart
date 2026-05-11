import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/error_view.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/admin_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class EventsManagementScreen extends ConsumerWidget {
  const EventsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredAdminEventsProvider);
    final selected = ref.watch(adminEventsFilterProvider);
    final counts = ref.watch(adminEventsCountByFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            subtitle: _subtitle(counts),
            selected: selected,
            counts: counts,
            onSelect: (f) =>
                ref.read(adminEventsFilterProvider.notifier).state = f,
            onBack: () => _handleBack(context),
          ),
          const _SearchBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(allEventsStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(allEventsStreamProvider),
                  ),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return _ScrollableSingle(
                      child: _buildEmpty(context, ref, selected),
                    );
                  }
                  return _EventsList(events: events);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminCreateEvent),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        elevation: 0,
        icon: Icon(PhosphorIcons.calendarPlus(), size: 18),
        label: Text(
          'Nuevo evento',
          style: AppTextStyles.buttonRegular.copyWith(
            color: AppColors.textOnAccent,
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminHome);
  }

  String _subtitle(Map<AdminEventFilter, int> counts) {
    final upcoming = counts[AdminEventFilter.upcoming] ?? 0;
    if (upcoming == 0) return 'No hay eventos próximos';
    if (upcoming == 1) return '1 evento próximo';
    return '$upcoming eventos próximos';
  }

  Widget _buildEmpty(
    BuildContext context,
    WidgetRef ref,
    AdminEventFilter filter,
  ) {
    final query = ref.read(adminEventsSearchQueryProvider).trim();
    if (query.isNotEmpty) {
      return EmptyState(
        icon: PhosphorIcons.magnifyingGlass(),
        title: 'Sin resultados para "$query"',
        subtitle: 'Prueba con otra palabra o limpia los filtros activos.',
        actionLabel: 'Limpiar búsqueda',
        onAction: () =>
            ref.read(adminEventsSearchQueryProvider.notifier).state = '',
      );
    }
    switch (filter) {
      case AdminEventFilter.upcoming:
        return EmptyState(
          icon: PhosphorIcons.calendarBlank(),
          title: 'No hay eventos próximos',
          subtitle:
              'Crea uno con el botón "Nuevo evento" y se notificará a la audiencia que elijas.',
          actionLabel: 'Crear evento',
          onAction: () => context.push(AppRoutes.adminCreateEvent),
        );
      case AdminEventFilter.past:
        return EmptyState(
          icon: PhosphorIcons.calendarX(),
          title: 'Sin eventos pasados',
          subtitle: 'Cuando un evento finalice y aún no se archive, aparecerá aquí.',
        );
      case AdminEventFilter.archived:
        return EmptyState(
          icon: PhosphorIcons.archive(),
          title: 'Sin archivados',
          subtitle: 'Cuando archives un evento, aparecerá aquí.',
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.subtitle,
    required this.selected,
    required this.counts,
    required this.onSelect,
    required this.onBack,
  });

  final String subtitle;
  final AdminEventFilter selected;
  final Map<AdminEventFilter, int> counts;
  final ValueChanged<AdminEventFilter> onSelect;
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
                Semantics(
                  label: 'Volver',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: AppRadius.borderBase,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          PhosphorIcons.arrowLeft(),
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
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
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxxxl,
                top: 2,
              ),
              child: Text(
                subtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _SegmentedFilter(
              selected: selected,
              counts: counts,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedFilter extends StatelessWidget {
  const _SegmentedFilter({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final AdminEventFilter selected;
  final Map<AdminEventFilter, int> counts;
  final ValueChanged<AdminEventFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        children: AdminEventFilter.values.map((filter) {
          final isActive = filter == selected;
          final count = counts[filter] ?? 0;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(filter),
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
                  '${filter.displayName} · $count',
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
// SEARCH
// ─────────────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(adminEventsSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final external = ref.watch(adminEventsSearchQueryProvider);
    if (external != _controller.text) {
      _controller.value = TextEditingValue(
        text: external,
        selection: TextSelection.collapsed(offset: external.length),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: TextField(
        controller: _controller,
        onChanged: (v) =>
            ref.read(adminEventsSearchQueryProvider.notifier).state = v,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar por título, lugar o descripción',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 18,
            color: AppColors.textTertiary,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref
                        .read(adminEventsSearchQueryProvider.notifier)
                        .state = '';
                  },
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LISTA + CARD
// ─────────────────────────────────────────────────────────────────────────

class _EventsList extends ConsumerWidget {
  const _EventsList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        // Espacio extra para que el FAB extendido no tape la última card.
        AppSpacing.xxxxl + AppSpacing.xl,
      ),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final event = events[index];
        return _AdminEventCard(
          event: event,
          onEdit: () => context.push(
            '${AppRoutes.adminEditEvent}/${event.id}',
          ),
          onArchive: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref
                .read(publishEventUseCaseProvider)
                .archive(event.id, archived: !event.isArchived);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  event.isArchived
                      ? 'Evento restaurado'
                      : 'Evento archivado',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        )
            .animate(delay: (index * 50).ms)
            .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  const _AdminEventCard({
    required this.event,
    required this.onEdit,
    required this.onArchive,
  });

  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderBase,
                      ),
                      child: Icon(cat.icon, size: 22, color: cat.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat.displayName,
                            style: AppTextStyles.metadata
                                .copyWith(color: cat.color),
                          ),
                        ],
                      ),
                    ),
                    _ArchiveButton(
                      isArchived: event.isArchived,
                      onTap: onArchive,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.divider,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _MetaIcon(
                      icon: PhosphorIcons.calendarBlank(),
                      label: _formatDateRange(
                        event.startDate,
                        event.endDate,
                      ),
                    ),
                    _MetaIcon(
                      icon: PhosphorIcons.mapPin(),
                      label: event.location,
                    ),
                    _MetaIcon(
                      icon: _audienceIcon(event.targetAudience),
                      label: event.targetAudience.displayName,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _audienceIcon(TargetAudience audience) {
    switch (audience) {
      case TargetAudience.all:
        return PhosphorIcons.usersThree();
      case TargetAudience.teachers:
        return PhosphorIcons.chalkboardTeacher();
      case TargetAudience.parents:
        return PhosphorIcons.usersFour();
    }
  }

  static String _formatDateRange(DateTime start, DateTime end) {
    final fmt = DateFormat('d MMM', 'es_PE');
    final timeFmt = DateFormat('HH:mm');
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) {
      return '${fmt.format(start)} · ${timeFmt.format(start)}–${timeFmt.format(end)}';
    }
    return '${fmt.format(start)} → ${fmt.format(end)}';
  }
}

class _ArchiveButton extends StatelessWidget {
  const _ArchiveButton({required this.isArchived, required this.onTap});

  final bool isArchived;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isArchived
            ? PhosphorIcons.arrowCounterClockwise()
            : PhosphorIcons.archive(),
        size: 18,
        color: isArchived ? AppColors.success : AppColors.textTertiary,
      ),
      tooltip: isArchived ? 'Restaurar' : 'Archivar',
      splashRadius: 18,
    );
  }
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.metadata),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LOADING / SCROLL HELPERS
// ─────────────────────────────────────────────────────────────────────────

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
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}

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
