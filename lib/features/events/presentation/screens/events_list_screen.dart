import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/widgets/category_chip.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/error_view.dart';
import 'package:agenda_escolar_adventista/core/widgets/modern_header.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_card.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final filtered = ref.watch(filteredEventsProvider);
    final selected = ref.watch(selectedEventCategoryProvider);

    final subtitle = eventsAsync.maybeWhen(
      data: (list) {
        final upcoming = list.where((e) => !e.isPast).length;
        if (upcoming == 0) return 'Aún no hay eventos próximos';
        return upcoming == 1 ? '1 evento próximo' : '$upcoming eventos próximos';
      },
      orElse: () => 'Cargando agenda…',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ModernHeader(
            title: 'Eventos',
            subtitle: subtitle,
            chips: _buildChips(ref, selected),
          ),
          Expanded(
            child: filtered.when(
              loading: () => const _LoadingList(),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(eventsStreamProvider),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIcons.calendarBlank(),
                    title: selected == null
                        ? 'Aún no hay eventos'
                        : 'Sin eventos en ${selected.displayName}',
                    subtitle: selected == null
                        ? 'Cuando la administración publique nuevos eventos, aparecerán aquí.'
                        : 'Prueba con otra categoría o vuelve a "Todos".',
                    actionLabel: selected != null ? 'Ver todos' : null,
                    onAction: selected != null
                        ? () => ref
                            .read(selectedEventCategoryProvider.notifier)
                            .state = null
                        : null,
                  );
                }
                return _EventsList(events: events);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips(WidgetRef ref, EventCategory? selected) {
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
}

/// Listado animado con stagger (delay de 60ms por card).
class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
