import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Bottom sheet con el detalle de un documento.
///
/// Muestra metadata completa (fecha, tamaño, estudiante asociado), el
/// comentario de la administración cuando lo hay y acciones según el
/// estado: si está rechazado, ofrece "Volver a subir"; si está
/// aprobado/pendiente, ofrece "Abrir archivo" (mock).
Future<void> showDocumentDetailSheet({
  required BuildContext context,
  required AppDocument document,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DocumentDetailSheet(document: document),
  );
}

class DocumentDetailSheet extends StatelessWidget {
  const DocumentDetailSheet({super.key, required this.document});

  final AppDocument document;

  @override
  Widget build(BuildContext context) {
    final type = document.type;
    final status = document.status;
    final hasComments =
        document.comments != null && document.comments!.isNotEmpty;
    final isRejected = status == DocumentStatus.rejected;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                // Icono grande de tipo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: Icon(type.icon, size: 40, color: type.color),
                  )
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                        duration: 320.ms,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Pills tipo + estado, alineados al centro.
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _TypePill(type: type),
                    _StatusPill(status: status),
                  ],
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.lg),
                _MetadataCard(document: document),
                if (hasComments) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _CommentsBlock(
                    message: document.comments!,
                    isError: isRejected,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _PrimaryAction(document: document),
                const SizedBox(height: AppSpacing.sm),
                _CloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PILLS
// ─────────────────────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        type.shortDisplayName.toUpperCase(),
        style: AppTextStyles.metadata.copyWith(
          color: type.color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────
// METADATA CARD
// ─────────────────────────────────────────────────────────────────────────

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.document});

  final AppDocument document;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(document.uploadedAt);
    final sizeLabel = _formatSize(document.fileSize);
    final studentName = _resolveStudentName(document.studentId);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
      ),
      child: Column(
        children: [
          _Row(
            icon: PhosphorIcons.calendarBlank(),
            label: 'Fecha de subida',
            value: dateLabel,
          ),
          const _Divider(),
          _Row(
            icon: PhosphorIcons.fileArrowUp(),
            label: 'Tamaño del archivo',
            value: sizeLabel,
          ),
          if (studentName != null) ...[
            const _Divider(),
            _Row(
              icon: PhosphorIcons.graduationCap(),
              label: 'Estudiante asociado',
              value: studentName,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime when) {
    final formatted = DateFormat("d 'de' MMMM 'de' yyyy", 'es_PE').format(when);
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

  static String? _resolveStudentName(String? studentId) {
    if (studentId == null) return null;
    final student = MockUsers.findById(studentId);
    if (student == null) return null;
    final firstName = student.displayName.split(' ').first;
    final grade = student.gradeLevel ?? student.classroomCode ?? '';
    return grade.isEmpty ? firstName : '$firstName · $grade';
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// COMENTARIOS DE LA ADMINISTRACIÓN
// ─────────────────────────────────────────────────────────────────────────

class _CommentsBlock extends StatelessWidget {
  const _CommentsBlock({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.info;
    final softColor = isError ? AppColors.errorSoft : AppColors.infoSoft;
    final icon = isError
        ? PhosphorIcons.warning(PhosphorIconsStyle.fill)
        : PhosphorIcons.chatCircleText();
    final title = isError
        ? 'Motivo del rechazo'
        : 'Nota de la administración';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.metadata.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// BOTONES
// ─────────────────────────────────────────────────────────────────────────

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.document});

  final AppDocument document;

  @override
  Widget build(BuildContext context) {
    final isRejected = document.status == DocumentStatus.rejected;

    if (isRejected) {
      return _FilledButton(
        label: 'Volver a subir',
        icon: PhosphorIcons.uploadSimple(),
        color: AppColors.primary,
        onTap: () {
          Navigator.of(context).pop();
          context.push(AppRoutes.uploadDocument);
        },
      );
    }

    return _FilledButton(
      label: 'Abrir archivo',
      icon: PhosphorIcons.eye(),
      color: AppColors.primary,
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Apertura del archivo disponible cuando se conecte el backend.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: color,
        borderRadius: AppRadius.borderBase,
        child: InkWell(
          borderRadius: AppRadius.borderBase,
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
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

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.borderBase,
        child: InkWell(
          borderRadius: AppRadius.borderBase,
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Center(
              child: Text(
                'Cerrar',
                style: AppTextStyles.buttonRegular
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
