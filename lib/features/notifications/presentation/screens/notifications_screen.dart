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
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/widgets/notification_card.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/widgets/notification_detail_sheet.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredNotificationsProvider);
    final unreadOnly = ref.watch(showUnreadOnlyProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _NotificationsHeader(
            unreadCount: unreadCount,
            unreadOnly: unreadOnly,
            onBack: () => _handleBack(context, ref),
            onMarkAllRead: unreadCount > 0
                ? () => _onMarkAllRead(context, ref)
                : null,
            onSelectFilter: (showUnread) =>
                ref.read(showUnreadOnlyProvider.notifier).state = showUnread,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(myNotificationsStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () =>
                        ref.invalidate(myNotificationsStreamProvider),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return _ScrollableSingle(
                      child: _emptyState(ref, unreadOnly),
                    );
                  }
                  return _NotificationsList(items: items);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vuelve al home del rol actual si no hay nada en el stack de
  /// go_router. Esto evita la pantalla en negro cuando se llega aquí
  /// con `context.go(...)` o tras un deep link.
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

  Future<void> _onMarkAllRead(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref
        .read(markAllNotificationsAsReadUseCaseProvider)
        .call(user.uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marcadas todas como leídas'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _emptyState(WidgetRef ref, bool unreadOnly) {
    if (unreadOnly) {
      return EmptyState(
        icon: PhosphorIcons.checks(),
        title: 'No tienes notificaciones sin leer',
        subtitle: 'Estás al día. Cuando llegue algo nuevo, aparecerá aquí.',
        actionLabel: 'Ver todas',
        onAction: () =>
            ref.read(showUnreadOnlyProvider.notifier).state = false,
      );
    }
    return EmptyState(
      icon: PhosphorIcons.bell(),
      title: 'Aún no tienes notificaciones',
      subtitle:
          'Te avisaremos cuando haya nuevos eventos, decisiones sobre tus '
          'documentos o avisos del colegio.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER INLINE
// ─────────────────────────────────────────────────────────────────────────

/// Header específico de notificaciones: la flecha de back va en la
/// MISMA fila que el título "Notificaciones", no encima.
class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.unreadCount,
    required this.unreadOnly,
    required this.onBack,
    required this.onMarkAllRead,
    required this.onSelectFilter,
  });

  final int unreadCount;
  final bool unreadOnly;
  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;
  final ValueChanged<bool> onSelectFilter;

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
            // Título + back inline + acción "Marcar todas"
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
                    'Notificaciones',
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onMarkAllRead != null)
                  _MarkAllReadButton(onTap: onMarkAllRead!),
              ],
            ),
            // Subtítulo alineado al título (no a la flecha)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxxxl, // 56 = ancho del back + gap
                top: 2,
              ),
              child: Text(
                _subtitle(unreadCount),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            // Chips de filtro
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                children: [
                  CategoryChip(
                    label: 'Todas',
                    selected: !unreadOnly,
                    onTap: () => onSelectFilter(false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CategoryChip(
                    label: unreadCount > 0
                        ? 'No leídas · $unreadCount'
                        : 'No leídas',
                    selected: unreadOnly,
                    onTap: () => onSelectFilter(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitle(int unread) {
    if (unread == 0) return 'Estás al día';
    if (unread == 1) return '1 sin leer';
    return '$unread sin leer';
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

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderFull,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.checks(),
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                'Marcar todas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LISTA + SWIPE-TO-DELETE
// ─────────────────────────────────────────────────────────────────────────

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({required this.items});

  final List<AppNotification> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final notification = items[index];
        return Dismissible(
          key: ValueKey(notification.id),
          direction: DismissDirection.endToStart,
          background: const _DismissBackground(),
          onDismissed: (_) async {
            await ref
                .read(deleteNotificationUseCaseProvider)
                .call(notification.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificación eliminada'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: NotificationCard(
            notification: notification,
            onTap: () => showNotificationDetailSheet(
              context: context,
              notification: notification,
            ),
          )
              .animate(delay: (index * 50).ms)
              .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
        );
      },
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            PhosphorIcons.trash(PhosphorIconsStyle.fill),
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Eliminar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        AppSpacing.md,
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
