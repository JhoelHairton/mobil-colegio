import 'package:file_picker/file_picker.dart';
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
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/providers/documents_providers.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/widgets/document_x.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  DocumentType _type = DocumentType.membership;
  String? _studentId;
  PlatformFile? _file;
  bool _submitting = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _file = result.files.first);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos abrir el selector: $e')),
      );
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_file == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Adjunta un archivo antes de subir.')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tu sesión expiró. Vuelve a iniciar sesión.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(uploadDocumentUseCaseProvider).call(
            parentId: user.uid,
            studentId: _studentId,
            type: _type,
            fileName: _file!.name,
            fileSize: _file!.size,
            // En mock no leemos el archivo. En Firebase aquí iría la subida real.
            localPath: _file!.path ?? 'mock://${_file!.name}',
          );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Documento subido. Quedará pendiente de revisión.'),
          duration: Duration(seconds: 3),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error al subir: $e')),
      );
      setState(() => _submitting = false);
    }
  }

  /// Vuelve a la lista de documentos. Usa pop si hay stack; si no
  /// (por ejemplo cuando llegamos por deep link), navega a la lista.
  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.myDocuments);
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(currentParentChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _UploadHeader(onBack: () => _handleBack(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel(label: 'Tipo de documento'),
                  const SizedBox(height: AppSpacing.md),
                  _TypeSelector(
                    selected: _type,
                    onChanged: (t) => setState(() => _type = t),
                  ),
                  if (children.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Estudiante (opcional)'),
                    const SizedBox(height: AppSpacing.md),
                    _StudentSelector(
                      students: children,
                      selectedId: _studentId,
                      onChanged: (id) => setState(() => _studentId = id),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionLabel(label: 'Archivo'),
                  const SizedBox(height: AppSpacing.md),
                  _FilePickerArea(
                    file: _file,
                    onPick: _pickFile,
                    onClear: () => setState(() => _file = null),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: _submitting ? 'Subiendo…' : 'Subir documento',
                    icon: PhosphorIcons.uploadSimple(),
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _Hint(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECCIONES
// ─────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final DocumentType selected;
  final ValueChanged<DocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: DocumentType.values.map((type) {
        final isActive = type == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.borderBase,
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isActive
                      ? type.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: AppRadius.borderBase,
                  border: Border.all(
                    color: isActive ? type.color : AppColors.border,
                    width: isActive ? 1.2 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: type.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(type.icon, size: 18, color: type.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isActive ? 1 : 0,
                      child: Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        size: 20,
                        color: type.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StudentSelector extends StatelessWidget {
  const _StudentSelector({
    required this.students,
    required this.selectedId,
    required this.onChanged,
  });

  final List<AppUser> students;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isExpanded: true,
          icon: Icon(
            PhosphorIcons.caretDown(),
            size: 18,
            color: AppColors.textSecondary,
          ),
          hint: Text(
            'Sin asociar a un estudiante',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Sin asociar',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...students.map(
              (s) => DropdownMenuItem<String?>(
                value: s.uid,
                child: Text(
                  '${s.displayName.split(' ').first} · ${s.gradeLevel ?? s.classroomCode ?? ''}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FilePickerArea extends StatelessWidget {
  const _FilePickerArea({
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return _DropZone(onTap: onPick);
    }
    return _SelectedFile(file: file!, onClear: onClear, onReplace: onPick)
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderBase,
        child: DottedBorderBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.paperclip(),
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Toca para seleccionar archivo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'PDF, JPG o PNG · máximo 10 MB',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFile extends StatelessWidget {
  const _SelectedFile({
    required this.file,
    required this.onClear,
    required this.onReplace,
  });

  final PlatformFile file;
  final VoidCallback onClear;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final ext = file.extension?.toUpperCase() ?? 'FILE';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.successSoft.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderBase,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.18),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              ext,
              style: AppTextStyles.metadata.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatSize(file.size),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: onReplace,
                      child: Text(
                        'Cambiar',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: onClear,
            splashRadius: 18,
          ),
        ],
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
}

class _Hint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.info(),
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Expanded(
          child: Text(
            'La administración revisa los documentos en un plazo de 2 a 3 días hábiles.',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

/// Caja con borde punteado dibujado a mano (sin agregar dependencias).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: AppColors.border,
        strokeWidth: 1.2,
        gap: 5,
        radius: AppRadius.base,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderBase,
        child: Container(
          decoration: const BoxDecoration(color: AppColors.surface),
          child: child,
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + gap;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        gap != oldDelegate.gap ||
        radius != oldDelegate.radius;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER INLINE
// ─────────────────────────────────────────────────────────────────────────

/// Header con flecha back en la misma fila que el título "Subir
/// documento". Coherente con el resto del feature.
class _UploadHeader extends StatelessWidget {
  const _UploadHeader({required this.onBack});

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
                    'Subir documento',
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xxxxl, // 56 = ancho del back + gap
                top: 2,
              ),
              child: Text(
                'Quedará en revisión por la administración',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
