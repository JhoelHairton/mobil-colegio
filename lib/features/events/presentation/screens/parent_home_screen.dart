import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/core/utils/date_formatter.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.displayName.split(' ').first ?? 'Usuario';
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(firstName),
                const SizedBox(height: AppSpacing.xl),
                _FeaturedEventBlock(asyncEvents: eventsAsync),
                const SizedBox(height: AppSpacing.xxl),
                _buildSectionTitle('Mis hijos', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                _buildChildrenList(),
                const SizedBox(height: AppSpacing.xxl),
                _buildSectionTitle(
                  'Mis documentos',
                  onSeeAll: () => context.go(AppRoutes.myDocuments),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDocumentsCard(),
                const SizedBox(height: AppSpacing.xxl),
                _buildSectionTitle(
                  'Eventos próximos',
                  onSeeAll: () => context.go(AppRoutes.eventsList),
                ),
                const SizedBox(height: AppSpacing.md),
                _UpcomingEventsBlock(asyncEvents: eventsAsync),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $name 👋',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormatter.formatDateLong(DateTime.now()),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.notifications),
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                  ),
                ),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h4),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Ver todos',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChildrenList() {
    const names = ['Carlos', 'María', 'Pedro'];
    const grades = ['3° grado', '4° grado', '5° grado'];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) {
          return Container(
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  names[i],
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(grades[i], style: AppTextStyles.caption),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _buildStatChip('3', 'Pendientes', AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          _buildStatChip('2', 'Aprobados', AppColors.success),
          const SizedBox(width: AppSpacing.md),
          _buildStatChip('1', 'Rechazados', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatChip(String number, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: AppRadius.borderBase,
        ),
        child: Column(
          children: [
            Text(number, style: AppTextStyles.h2.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() => _currentIndex = i);
            switch (i) {
              case 1:
                context.push(AppRoutes.eventsList);
              case 2:
                context.push(AppRoutes.myDocuments);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              label: 'Documentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Bloque "Próximo evento" — gradiente + datos del próximo evento real.
// ─────────────────────────────────────────────────────────────────────────

class _FeaturedEventBlock extends StatelessWidget {
  const _FeaturedEventBlock({required this.asyncEvents});

  final AsyncValue<List<Event>> asyncEvents;

  @override
  Widget build(BuildContext context) {
    return asyncEvents.when(
      loading: () => const _FeaturedSkeleton(),
      error: (_, __) => const _FeaturedPlaceholder(
        message: 'No pudimos cargar el próximo evento.',
      ),
      data: (events) {
        final featured = _pickFeaturedForParent(events);
        if (featured == null) {
          return const _FeaturedPlaceholder(
            message: 'No hay eventos próximos por ahora.',
          );
        }
        return _FeaturedEventCard(event: featured);
      },
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;
    final dateLabel = _formatLongDate(event.startDate);
    final timeLabel = DateFormat('HH:mm').format(event.startDate);

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.eventDetail}/${event.id}'),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderLg,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cat.color,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      cat.displayName,
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    cat.icon,
                    size: 28,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Próximo evento',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 2),
              Text(
                event.title,
                style: AppTextStyles.h3.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.calendarBlank(),
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Expanded(
                    child: Text(
                      '$dateLabel · $timeLabel',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatLongDate(DateTime d) {
    final base = DateFormat("EEEE d 'de' MMMM", 'es_PE').format(d);
    return base.isEmpty ? base : '${base[0].toUpperCase()}${base.substring(1)}';
  }
}

class _FeaturedPlaceholder extends StatelessWidget {
  const _FeaturedPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderLg,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              PhosphorIcons.calendarBlank(),
              size: 32,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(
      height: 180,
      borderRadius: AppRadius.borderLg,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Bloque "Eventos próximos" — lista de hasta 2 cards compactas reales.
// ─────────────────────────────────────────────────────────────────────────

class _UpcomingEventsBlock extends StatelessWidget {
  const _UpcomingEventsBlock({required this.asyncEvents});

  final AsyncValue<List<Event>> asyncEvents;

  static const int _itemsToShow = 2;

  @override
  Widget build(BuildContext context) {
    return asyncEvents.when(
      loading: () => Column(
        children: List.generate(
          _itemsToShow,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SkeletonCard(),
          ),
        ),
      ),
      error: (_, __) => _EmptyMini(
        icon: PhosphorIcons.warningCircle(),
        message: 'No pudimos cargar los eventos.',
      ),
      data: (events) {
        // Para padres, en parent_home mostramos lo siguiente al featured.
        // Saltamos el primero porque ya está en _FeaturedEventBlock.
        final upcoming = _filterUpcomingForParent(events).skip(1).toList();
        if (upcoming.isEmpty) {
          return _EmptyMini(
            icon: PhosphorIcons.calendarCheck(),
            message: 'No hay otros eventos próximos.',
          );
        }
        final visible = upcoming.take(_itemsToShow).toList();
        return Column(
          children: [
            for (final e in visible) ...[
              _UpcomingEventTile(event: e),
              if (e != visible.last) const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final cat = event.category;
    final timeLabel = _formatWhen(event.startDate);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.borderBase,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.eventDetail}/${event.id}'),
        borderRadius: AppRadius.borderBase,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderBase,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(cat.icon, color: cat.color, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatWhen(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOf = DateTime(d.year, d.month, d.day);
    final diff = dayOf.difference(today).inDays;

    final time = DateFormat('HH:mm').format(d);
    if (diff == 0) return 'Hoy · $time';
    if (diff == 1) return 'Mañana · $time';
    if (diff > 1 && diff < 7) {
      final dayName = DateFormat('EEEE', 'es_PE').format(d);
      final capitalized = dayName.isEmpty
          ? dayName
          : '${dayName[0].toUpperCase()}${dayName.substring(1)}';
      return '$capitalized · $time';
    }
    final dateStr = DateFormat("d 'de' MMMM", 'es_PE').format(d);
    return '$dateStr · $time';
  }
}

class _EmptyMini extends StatelessWidget {
  const _EmptyMini({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers de filtrado para audiencia "padres".
// ─────────────────────────────────────────────────────────────────────────

List<Event> _filterUpcomingForParent(List<Event> events) {
  final now = DateTime.now();
  final filtered = events.where((e) {
    final isFutureOrOngoing = !e.isPast;
    final isVisibleForParent = e.targetAudience == TargetAudience.all ||
        e.targetAudience == TargetAudience.parents;
    return isFutureOrOngoing && isVisibleForParent && e.startDate.isAfter(now.subtract(const Duration(days: 1)));
  }).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  return filtered;
}

Event? _pickFeaturedForParent(List<Event> events) {
  final list = _filterUpcomingForParent(events);
  return list.isEmpty ? null : list.first;
}
