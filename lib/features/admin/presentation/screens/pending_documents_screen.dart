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
import 'package:agenda_escolar_adventista/core/widgets/category_chip.dart';
import 'package:agenda_escolar_adventista/core/widgets/empty_state.dart';
import 'package:agenda_escolar_adventista/core/widgets/error_view.dart';
import 'package:agenda_escolar_adventista/core/widgets/skeleton_loader.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/admin_providers.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/widgets/review_document_sheet.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

class PendingDocumentsScreen extends ConsumerWidget {
  const PendingDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredAllDocumentsProvider);
    final selected = ref.watch(adminDocumentsStatusFilterProvider);
    final counts = ref.watch(adminDocumentCountsByStatusProvider);
    final pending = counts[DocumentStatus.pending] ?? 0;
    final reviewing = counts[DocumentStatus.reviewing] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            subtitle: _subtitle(pending, reviewing),
            chips: _buildChips(ref, selected, counts),
            onBack: () => _handleBack(context),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(allDocumentsStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(allDocumentsStreamProvider),
                  ),
                ),
                data: (docs) {
                  if (docs.isEmpty) {
                    return _ScrollableSingle(
                      child: _buildEmpty(ref, selected),
                    );
                  }
                  return _DocumentsList(documents: docs);
                },
              ),
            ),
          ),
        ],
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

  String _subtitle(int pending, int reviewing) {
    final total = pending + reviewing;
    if (total == 0) return 'Bandeja al día';
    if (pending == 0) return '$reviewing en proceso';
    if (reviewing == 0) {
      return pending == 1 ? '1 sin revisar' : '$pending sin revisar';
    }
    return '$pending sin revisar · $reviewing en proceso';
  }

  List<Widget> _buildChips(
    WidgetRef ref,
    DocumentStatus? selected,
    Map<DocumentStatus, int> counts,
  ) {
    final controller = ref.read(adminDocumentsStatusFilterProvider.notifier);
    final total = counts.values.fold(0, (a, b) => a + b);
    return [
      CategoryChip(
        label: 'Todos · $total',
        selected: selected == null,
        onTap: () => controller.state = null,
      ),
      ...DocumentStatus.values.map((status) {
        final count = counts[status] ?? 0;
        return CategoryChip(
          label: '${status.displayName} · $count',
          icon: status.icon,
          color: status.color,
          selected: selected == status,
          onTap: () => controller.state = status,
        );
      }),
    ];
  }

  Widget _buildEmpty(WidgetRef ref, DocumentStatus? selected) {
    if (selected != null) {
      return EmptyState(
        icon: selected.icon,
        title: 'Sin documentos en "${selected.displayName}"',
        subtitle: 'Cambia de filtro para ver otros estados.',
        actionLabel: 'Ver todos',
        onAction: () =>
            ref.read(adminDocumentsStatusFilterProvider.notifier).state = null,
      );
    }
    return EmptyState(
      icon: PhosphorIcons.checks(),
      title: 'Bandeja al día',
      subtitle:
          'No hay documentos por revisar. Cuando los padres suban algo nuevo, aparecerá aquí.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER INLINE
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
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
                    'Aprobar documentos',
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

// ─────────────────────────────────────────────────────────────────────────
// LISTA Y CARD
// ─────────────────────────────────────────────────────────────────────────

class _DocumentsList extends StatelessWidget {
  const _DocumentsList({required this.documents});

  final List<AppDocument> documents;

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
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final document = documents[index];
        return _AdminDocumentCard(
          document: document,
          onTap: () => showReviewDocumentSheet(
            context: context,
            document: document,
          ),
        )
            .animate(delay: (index * 50).ms)
            .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

/// Card del listado para admin: incluye el nombre del padre y del
/// estudiante asociado, además de los datos del documento.
class _AdminDocumentCard extends StatelessWidget {
  const _AdminDocumentCard({required this.document, required this.onTap});

  final AppDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = document.type;
    final status = document.status;
    final parent = MockUsers.findById(document.parentId);
    final student = document.studentId == null
        ? null
        : MockUsers.findById(document.studentId!);
    final parentName = parent?.displayName ?? 'Padre desconocido';

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
          onTap: onTap,
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
                        color: type.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderBase,
                      ),
                      child: Icon(type.icon, size: 22, color: type.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.displayName,
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            parentName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(status: status),
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
                      label: _relativeDate(document.uploadedAt),
                    ),
                    _MetaIcon(
                      icon: PhosphorIcons.fileText(),
                      label: _formatSize(document.fileSize),
                    ),
                    if (student != null)
                      _MetaIcon(
                        icon: PhosphorIcons.graduationCap(),
                        label: student.displayName.split(' ').first,
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

  static String _relativeDate(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'recién subido';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';
    final formatted = DateFormat("d 'de' MMM", 'es_PE').format(when);
    return formatted;
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: AppRadius.borderFull,
        border: Border.all(
          color: status.color.withValues(alpha: 0.30),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: AppTextStyles.metadata.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
