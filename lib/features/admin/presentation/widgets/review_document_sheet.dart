import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/admin_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Bottom sheet con la revisión de un documento (admin/secretaría).
///
/// Permite aprobar (con comentario opcional) o rechazar (con comentario
/// obligatorio). Al confirmar, el use case actualiza el documento Y
/// crea una notificación al padre involucrado.
Future<void> showReviewDocumentSheet({
  required BuildContext context,
  required AppDocument document,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ReviewDocumentSheet(document: document),
  );
}

class ReviewDocumentSheet extends ConsumerStatefulWidget {
  const ReviewDocumentSheet({super.key, required this.document});

  final AppDocument document;

  @override
  ConsumerState<ReviewDocumentSheet> createState() =>
      _ReviewDocumentSheetState();
}

class _ReviewDocumentSheetState extends ConsumerState<ReviewDocumentSheet> {
  final _commentController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    await _run(
      label: 'aprobado',
      action: () => ref.read(reviewDocumentUseCaseProvider).approve(
            documentId: widget.document.id,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          ),
    );
  }

  Future<void> _reject() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para rechazar es obligatorio escribir un motivo en el campo de comentarios.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    await _run(
      label: 'rechazado',
      action: () => ref.read(reviewDocumentUseCaseProvider).reject(
            documentId: widget.document.id,
            comment: comment,
          ),
    );
  }

  Future<void> _run({
    required String label,
    required Future<AppDocument> Function() action,
  }) async {
    setState(() => _processing = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Documento $label. Se notificó al padre.'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo completar la revisión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    final type = document.type;
    final status = document.status;
    final parent = MockUsers.findById(document.parentId);
    final student = document.studentId == null
        ? null
        : MockUsers.findById(document.studentId!);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: AppRadius.borderFull,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: Icon(type.icon, size: 36, color: type.color),
                  )
                      .animate()
                      .fadeIn(duration: 250.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                        duration: 280.ms,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: _StatusPill(status: status),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  type.displayName,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  document.fileName,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.lg),
                _Card(
                  rows: [
                    _Row(
                      icon: PhosphorIcons.user(),
                      label: 'Padre',
                      value: parent?.displayName ?? 'Padre desconocido',
                    ),
                    if (student != null)
                      _Row(
                        icon: PhosphorIcons.graduationCap(),
                        label: 'Estudiante',
                        value:
                            '${student.displayName.split(' ').first} · ${student.gradeLevel ?? student.classroomCode ?? ''}',
                      ),
                    _Row(
                      icon: PhosphorIcons.calendarBlank(),
                      label: 'Subido',
                      value: _formatDate(document.uploadedAt),
                    ),
                    _Row(
                      icon: PhosphorIcons.fileArrowUp(),
                      label: 'Tamaño',
                      value: _formatSize(document.fileSize),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Comentario',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _commentController,
                  enabled: !_processing,
                  minLines: 3,
                  maxLines: 5,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText:
                        'Opcional al aprobar · Obligatorio al rechazar (motivo)',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.borderBase,
                      borderSide:
                          BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.borderBase,
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 1),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.borderBase,
                      borderSide:
                          BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ActionButton(
                  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  label: 'Aprobar',
                  background: AppColors.success,
                  isLoading: _processing,
                  onTap: _processing ? null : _approve,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ActionButton(
                  icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  label: 'Rechazar',
                  background: AppColors.error,
                  isLoading: false,
                  onTap: _processing ? null : _reject,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _processing
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime when) {
    final formatted = DateFormat("d 'de' MMMM, HH:mm", 'es_PE').format(when);
    return formatted.isEmpty
        ? formatted
        : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SUBWIDGETS
// ─────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
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
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.metadata
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: onTap == null
            ? background.withValues(alpha: 0.5)
            : background,
        borderRadius: AppRadius.borderBase,
        child: InkWell(
          borderRadius: AppRadius.borderBase,
          onTap: onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        label,
                        style: AppTextStyles.buttonRegular
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
