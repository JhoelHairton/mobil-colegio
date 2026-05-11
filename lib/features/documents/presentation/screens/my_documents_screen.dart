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
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/providers/documents_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_card.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_detail_sheet.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';

class MyDocumentsScreen extends ConsumerWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredDocumentsProvider);
    final selected = ref.watch(selectedDocumentStatusProvider);
    final counts = ref.watch(documentCountsByStatusProvider);
    final pending = counts[DocumentStatus.pending] ?? 0;
    final reviewing = counts[DocumentStatus.reviewing] ?? 0;
    final activeCount = pending + reviewing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _DocumentsHeader(
            subtitle: _buildSubtitle(activeCount),
            chips: _buildChips(ref, selected, counts),
            onBack: () => _handleBack(context, ref),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(myDocumentsStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(myDocumentsStreamProvider),
                  ),
                ),
                data: (docs) {
                  if (docs.isEmpty) {
                    return _ScrollableSingle(
                      child: _buildEmptyState(context, ref, selected),
                    );
                  }
                  return _DocumentsList(documents: docs);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.uploadDocument),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        elevation: 0,
        icon: Icon(PhosphorIcons.uploadSimple(), size: 18),
        label: Text(
          'Subir documento',
          style: AppTextStyles.buttonRegular.copyWith(
            color: AppColors.textOnAccent,
          ),
        ),
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

  String _buildSubtitle(int activeCount) {
    if (activeCount == 0) return 'No tienes documentos pendientes';
    if (activeCount == 1) return '1 pendiente de revisión';
    return '$activeCount pendientes de revisión';
  }

  List<Widget> _buildChips(
    WidgetRef ref,
    DocumentStatus? selected,
    Map<DocumentStatus, int> counts,
  ) {
    final controller = ref.read(selectedDocumentStatusProvider.notifier);
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

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    DocumentStatus? selected,
  ) {
    if (selected != null) {
      return EmptyState(
        icon: selected.icon,
        title: 'Sin documentos en "${selected.displayName}"',
        subtitle: 'Cambia de filtro para ver documentos en otros estados.',
        actionLabel: 'Ver todos',
        onAction: () =>
            ref.read(selectedDocumentStatusProvider.notifier).state = null,
      );
    }
    return EmptyState(
      icon: PhosphorIcons.folderOpen(),
      title: 'Aún no has subido documentos',
      subtitle:
          'Sube tu comprobante de membresía, solicitudes de descuento o '
          'comprobantes de diezmo desde el botón inferior.',
      actionLabel: 'Subir mi primer documento',
      onAction: () => context.push(AppRoutes.uploadDocument),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER INLINE
// ─────────────────────────────────────────────────────────────────────────

/// Header específico de documentos: la flecha de back va en la MISMA
/// fila que el título "Mis documentos", no encima.
class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader({
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
                    'Mis documentos',
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
            // Chips con scroll horizontal.
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
// LISTA + ESTADOS
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
        // Espacio extra para que el FAB extendido no tape la última card.
        AppSpacing.xxxxl + AppSpacing.xl,
      ),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final document = documents[index];
        return DocumentCard(
          document: document,
          onTap: () => showDocumentDetailSheet(
            context: context,
            document: document,
          ),
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
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxxl + AppSpacing.xl,
      ),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (_, __) => const _SkeletonDocumentCard(),
    );
  }
}

class _SkeletonDocumentCard extends StatelessWidget {
  const _SkeletonDocumentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: const SkeletonGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: AppRadius.borderBase,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(widthFactor: 0.6, height: 14),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonText(widthFactor: 0.85, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonText(widthFactor: 0.4, height: 12),
          ],
        ),
      ),
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
