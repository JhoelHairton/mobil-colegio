import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';

/// Card del listado "Mis documentos".
///
/// Estructura visual:
/// ```
/// ┌─────────────────────────────────────┐
/// │  [icono]  Tipo                       │
/// │           archivo.pdf · 240 KB       │
/// │                              [badge] │
/// │  ─────────────────────────           │
/// │  Subido hace 3 días                  │
/// │  (si rejected) "Comentario..."       │
/// └─────────────────────────────────────┘
/// borderRadius md (16), border 0.5px, sin sombra.
/// ```
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
  });

  final AppDocument document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = document.type;
    final status = document.status;
    final hasRejectionNote =
        status == DocumentStatus.rejected && document.comments != null;

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
                            '${document.fileName} · ${_formatSize(document.fileSize)}',
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
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.calendarBlank(),
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      _formatUploadedAt(document.uploadedAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (hasRejectionNote) ...[
                  const SizedBox(height: AppSpacing.md),
                  _RejectionNote(message: document.comments!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  static String _formatUploadedAt(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'Subido hace un instante';
    if (diff.inHours < 1) return 'Subido hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Subido hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Subido ayer';
    if (diff.inDays < 7) return 'Subido hace ${diff.inDays} días';
    final formatted = DateFormat("d 'de' MMMM", 'es_PE').format(when);
    return 'Subido el $formatted';
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

class _RejectionNote extends StatelessWidget {
  const _RejectionNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.borderBase,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.warning(PhosphorIconsStyle.fill),
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
