import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/providers/users_management_providers.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Plantilla CSV que se enseña al admin. Las cabeceras coinciden con
/// el orden esperado por el parser.
const String _csvTemplate =
    'email,displayName,role,phoneNumber,gradeLevel,classroomCode\n'
    'profesor.demo@teacher.test,Carlos Demo Mamani,teacher,+51 951 000 001,,\n'
    'apoderado.demo@parent.test,Lucía Demo Apaza,parent,+51 951 000 002,,\n'
    'estudiante.demo@student.test,Mateo Demo Quispe,student,,5° Secundaria,5SEC-A';

const List<String> _expectedHeaders = [
  'email',
  'displayName',
  'role',
  'phoneNumber',
  'gradeLevel',
  'classroomCode',
];

class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  _ImportStage _stage = _ImportStage.idle;
  String? _fileName;
  List<_ParsedRow> _parsed = const [];
  List<String> _globalErrors = const [];

  // Resultado del import.
  int _createdCount = 0;
  List<String> _failedRows = const [];

  bool get _hasValidRows =>
      _parsed.isNotEmpty && _parsed.any((r) => r.isValid);

  int get _validCount => _parsed.where((r) => r.isValid).length;
  int get _errorCount => _parsed.where((r) => !r.isValid).length;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminUsers);
  }

  Future<void> _pickFile() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No pudimos leer el archivo.')),
        );
        return;
      }

      // CSV de Excel suele venir en UTF-8 con BOM. utf8.decode lo limpia.
      final raw = utf8.decode(bytes, allowMalformed: true);
      final result2 = _parseCsv(raw);
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _parsed = result2.rows;
        _globalErrors = result2.globalErrors;
        _stage = _ImportStage.parsed;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al procesar el archivo: $e')),
      );
    }
  }

  void _copyTemplate() {
    Clipboard.setData(const ClipboardData(text: _csvTemplate));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plantilla copiada. Pégala en Excel y guarda como CSV.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _import() async {
    final repo = ref.read(usersRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _stage = _ImportStage.importing);

    var created = 0;
    final failed = <String>[];
    for (final row in _parsed.where((r) => r.isValid)) {
      try {
        await repo.createUser(
          email: row.email!,
          displayName: row.displayName!,
          role: row.role!,
          phoneNumber: row.phoneNumber,
          classroomCode: row.classroomCode,
          gradeLevel: row.gradeLevel,
        );
        created++;
      } catch (e) {
        failed.add('Fila ${row.rowNumber}: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _createdCount = created;
      _failedRows = failed;
      _stage = _ImportStage.done;
    });

    if (failed.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Import terminado: $created creadas, ${failed.length} fallidas.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _resetToIdle() {
    setState(() {
      _stage = _ImportStage.idle;
      _fileName = null;
      _parsed = const [];
      _globalErrors = const [];
      _createdCount = 0;
      _failedRows = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(stage: _stage, onBack: _handleBack),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _ImportStage.idle:
        return _IdleStep(onCopyTemplate: _copyTemplate, onPickFile: _pickFile);
      case _ImportStage.parsed:
        return _PreviewStep(
          fileName: _fileName ?? '',
          rows: _parsed,
          globalErrors: _globalErrors,
          validCount: _validCount,
          errorCount: _errorCount,
          canImport: _hasValidRows,
          onCancel: _resetToIdle,
          onImport: _import,
        );
      case _ImportStage.importing:
        return const _ImportingStep();
      case _ImportStage.done:
        return _DoneStep(
          createdCount: _createdCount,
          failedRows: _failedRows,
          totalRows: _parsed.length,
          onFinish: _handleBack,
          onImportMore: _resetToIdle,
        );
    }
  }
}

enum _ImportStage { idle, parsed, importing, done }

// ─────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.stage, required this.onBack});

  final _ImportStage stage;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (stage) {
      _ImportStage.idle => 'Sube un archivo CSV con los usuarios a registrar',
      _ImportStage.parsed => 'Revisa los datos antes de importar',
      _ImportStage.importing => 'Importando usuarios…',
      _ImportStage.done => 'Resumen del import',
    };

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
                    'Carga masiva',
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STEP 1: IDLE (instrucciones + selector)
// ─────────────────────────────────────────────────────────────────────────

class _IdleStep extends StatelessWidget {
  const _IdleStep({required this.onCopyTemplate, required this.onPickFile});

  final VoidCallback onCopyTemplate;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Instrucciones'),
          const SizedBox(height: AppSpacing.md),
          _InstructionList(),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(label: 'Plantilla CSV'),
          const SizedBox(height: AppSpacing.md),
          _TemplateBox(onCopy: onCopyTemplate),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Seleccionar archivo CSV',
            icon: PhosphorIcons.uploadSimple(),
            onPressed: onPickFile,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                PhosphorIcons.info(),
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  'En Excel: archivo guarda como "CSV UTF-8 (delimitado por comas)".',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: PhosphorIcons.numberOne(),
        text: 'Copia la plantilla y pégala en Excel para llenar los datos.',
      ),
      (
        icon: PhosphorIcons.numberTwo(),
        text:
            'El rol debe ser uno de: teacher, parent o student (sin admin/secretary).',
      ),
      (
        icon: PhosphorIcons.numberThree(),
        text:
            'Los estudiantes requieren grado. Padres y docentes solo email, nombre y rol.',
      ),
      (
        icon: PhosphorIcons.numberFour(),
        text:
            'Cada cuenta nueva queda pre-registrada con un código de 8 caracteres.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    items[i].icon,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    items[i].text,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _TemplateBox extends StatelessWidget {
  const _TemplateBox({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              _csvTemplate,
              style: AppTextStyles.bodySmall.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onCopy,
              icon: Icon(PhosphorIcons.copy(), size: 16),
              label: const Text('Copiar plantilla'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STEP 2: PREVIEW
// ─────────────────────────────────────────────────────────────────────────

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({
    required this.fileName,
    required this.rows,
    required this.globalErrors,
    required this.validCount,
    required this.errorCount,
    required this.canImport,
    required this.onCancel,
    required this.onImport,
  });

  final String fileName;
  final List<_ParsedRow> rows;
  final List<String> globalErrors;
  final int validCount;
  final int errorCount;
  final bool canImport;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final invalidRows = rows.where((r) => !r.isValid).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilePill(fileName: fileName),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        icon: PhosphorIcons.checkCircle(),
                        color: AppColors.success,
                        label: 'Válidas',
                        value: '$validCount',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CountCard(
                        icon: PhosphorIcons.warning(),
                        color: AppColors.error,
                        label: 'Con errores',
                        value: '$errorCount',
                      ),
                    ),
                  ],
                ),
                if (globalErrors.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _GlobalErrorsBox(errors: globalErrors),
                ],
                if (invalidRows.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel(
                    label: 'Filas con errores (no se importarán)',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InvalidRowList(rows: invalidRows),
                ],
                const SizedBox(height: AppSpacing.lg),
                const _SectionLabel(label: 'Vista previa'),
                const SizedBox(height: AppSpacing.md),
                _PreviewTable(rows: rows.take(8).toList()),
                if (rows.length > 8) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '… y ${rows.length - 8} filas más.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: canImport
                      ? 'Importar $validCount usuarios'
                      : 'Sin filas válidas',
                  icon: PhosphorIcons.uploadSimple(),
                  onPressed: canImport ? onImport : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cambiar archivo',
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
      ],
    );
  }
}

class _FilePill extends StatelessWidget {
  const _FilePill({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.fileCsv(),
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              fileName,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color, height: 1),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _GlobalErrorsBox extends StatelessWidget {
  const _GlobalErrorsBox({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.borderBase,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.30),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIcons.warning(PhosphorIconsStyle.fill),
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errors.length == 1
                      ? 'Problema con el archivo'
                      : 'Problemas con el archivo',
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final e in errors)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
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

class _InvalidRowList extends StatelessWidget {
  const _InvalidRowList({required this.rows});

  final List<_ParsedRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      'Fila ${rows[i].rowNumber}',
                      style: AppTextStyles.metadata.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final err in rows[i].errors)
                          Text(
                            '• $err',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(
                height: 0,
                thickness: 0.5,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.rows});

  final List<_ParsedRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: const WidgetStatePropertyAll(AppColors.surfaceMuted),
          headingTextStyle: AppTextStyles.metadata.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          dataTextStyle: AppTextStyles.bodySmall,
          columnSpacing: 18,
          horizontalMargin: 14,
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Grado')),
          ],
          rows: rows.map((r) {
            return DataRow(
              cells: [
                DataCell(Text('${r.rowNumber}')),
                DataCell(
                  r.isValid
                      ? Icon(
                          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                          size: 16,
                          color: AppColors.success,
                        )
                      : Icon(
                          PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                          size: 16,
                          color: AppColors.error,
                        ),
                ),
                DataCell(Text(r.email ?? '—')),
                DataCell(Text(r.displayName ?? '—')),
                DataCell(Text(r.role?.displayName ?? '—')),
                DataCell(Text(r.gradeLevel ?? '—')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STEP 3: IMPORTING
// ─────────────────────────────────────────────────────────────────────────

class _ImportingStep extends StatelessWidget {
  const _ImportingStep();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Creando cuentas…',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Esto puede tomar unos segundos.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// STEP 4: DONE
// ─────────────────────────────────────────────────────────────────────────

class _DoneStep extends StatelessWidget {
  const _DoneStep({
    required this.createdCount,
    required this.failedRows,
    required this.totalRows,
    required this.onFinish,
    required this.onImportMore,
  });

  final int createdCount;
  final List<String> failedRows;
  final int totalRows;
  final VoidCallback onFinish;
  final VoidCallback onImportMore;

  @override
  Widget build(BuildContext context) {
    final hasErrors = failedRows.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasErrors
                        ? AppColors.warningSoft
                        : AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasErrors
                        ? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill)
                        : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    size: 44,
                    color:
                        hasErrors ? AppColors.warning : AppColors.success,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 500.ms,
                    ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  hasErrors
                      ? 'Import terminado con errores'
                      : '¡Cuentas creadas!',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Se crearon $createdCount de $totalRows usuarios.',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Las nuevas cuentas quedan pre-registradas. Comparte sus códigos de activación desde "Gestionar usuarios".',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
                if (hasErrors) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: AppRadius.borderBase,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Errores durante la creación',
                          style: AppTextStyles.metadata.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (final err in failedRows)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '• $err',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Volver a usuarios',
                  icon: PhosphorIcons.arrowRight(),
                  onPressed: onFinish,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onImportMore,
                  child: Text(
                    'Importar otro archivo',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// COMPONENTES COMUNES
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

// ─────────────────────────────────────────────────────────────────────────
// PARSER + VALIDACIÓN
// ─────────────────────────────────────────────────────────────────────────

class _ParsedRow {
  _ParsedRow({
    required this.rowNumber,
    this.email,
    this.displayName,
    this.role,
    this.phoneNumber,
    this.gradeLevel,
    this.classroomCode,
    this.errors = const [],
  });

  final int rowNumber;
  final String? email;
  final String? displayName;
  final UserRole? role;
  final String? phoneNumber;
  final String? gradeLevel;
  final String? classroomCode;
  List<String> errors;

  bool get isValid => errors.isEmpty;
}

class _ParseResult {
  const _ParseResult({required this.rows, required this.globalErrors});
  final List<_ParsedRow> rows;
  final List<String> globalErrors;
}

_ParseResult _parseCsv(String content) {
  final globalErrors = <String>[];

  // Quitamos BOM si lo hay (Excel UTF-8 lo agrega).
  final clean = content.replaceFirst(RegExp(r'^﻿'), '').trim();
  if (clean.isEmpty) {
    return const _ParseResult(rows: [], globalErrors: ['El archivo está vacío.']);
  }

  final lines = const LineSplitter().convert(clean);
  if (lines.length < 2) {
    return const _ParseResult(
      rows: [],
      globalErrors: [
        'El archivo debe tener al menos una fila de cabeceras y una fila de datos.',
      ],
    );
  }

  final headers = _splitCsvLine(lines.first).map((h) => h.trim()).toList();

  // Validamos cabeceras requeridas (orden flexible: trabajamos por nombre).
  final headerIndex = <String, int>{};
  for (var i = 0; i < headers.length; i++) {
    headerIndex[headers[i]] = i;
  }

  final missing = <String>[];
  for (final required in ['email', 'displayName', 'role']) {
    if (!headerIndex.containsKey(required)) missing.add(required);
  }
  if (missing.isNotEmpty) {
    globalErrors.add(
      'Faltan cabeceras obligatorias: ${missing.join(', ')}.',
    );
    return _ParseResult(rows: const [], globalErrors: globalErrors);
  }

  final unknown = headers
      .where((h) => h.isNotEmpty && !_expectedHeaders.contains(h))
      .toList();
  if (unknown.isNotEmpty) {
    globalErrors.add(
      'Cabeceras desconocidas: ${unknown.join(', ')} (se ignoran).',
    );
  }

  // Track de duplicados dentro del archivo.
  final seenEmails = <String>{};

  final rows = <_ParsedRow>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;

    final cells = _splitCsvLine(line);
    String get(String key) {
      final idx = headerIndex[key];
      if (idx == null || idx >= cells.length) return '';
      return cells[idx].trim();
    }

    final rawEmail = get('email');
    final rawName = get('displayName');
    final rawRole = get('role');
    final rawPhone = get('phoneNumber');
    final rawGrade = get('gradeLevel');
    final rawClass = get('classroomCode');

    final errors = <String>[];

    // Email
    String? email;
    final normalizedEmail = rawEmail.toLowerCase();
    if (normalizedEmail.isEmpty) {
      errors.add('Falta el correo.');
    } else if (!normalizedEmail.contains('@') ||
        !normalizedEmail.contains('.')) {
      errors.add('Correo inválido: "$rawEmail".');
    } else if (seenEmails.contains(normalizedEmail)) {
      errors.add('Correo duplicado en el archivo.');
    } else if (MockUsers.findByEmail(normalizedEmail) != null) {
      errors.add('Correo ya registrado en el sistema.');
    } else {
      email = normalizedEmail;
      seenEmails.add(normalizedEmail);
    }

    // Nombre
    String? displayName;
    if (rawName.length < 3) {
      errors.add('Nombre muy corto (mínimo 3 caracteres).');
    } else {
      displayName = rawName;
    }

    // Rol
    UserRole? role;
    final normalizedRole = rawRole.toLowerCase();
    if (normalizedRole.isEmpty) {
      errors.add('Falta el rol.');
    } else if (!const ['parent', 'teacher', 'student']
        .contains(normalizedRole)) {
      errors.add(
        'Rol inválido: "$rawRole". Debe ser parent, teacher o student.',
      );
    } else {
      role = UserRole.fromString(normalizedRole);
    }

    // Si es estudiante, gradeLevel es obligatorio.
    final gradeLevel = rawGrade.isEmpty ? null : rawGrade;
    if (role == UserRole.student && (gradeLevel == null || gradeLevel.isEmpty)) {
      errors.add('Los estudiantes requieren grado (ej. "5° Secundaria").');
    }

    rows.add(
      _ParsedRow(
        rowNumber: i + 1,
        email: email,
        displayName: displayName,
        role: role,
        phoneNumber: rawPhone.isEmpty ? null : rawPhone,
        gradeLevel: gradeLevel,
        classroomCode: rawClass.isEmpty ? null : rawClass,
        errors: errors,
      ),
    );
  }

  return _ParseResult(rows: rows, globalErrors: globalErrors);
}

/// Parser de una línea CSV. Soporta valores con comillas dobles y
/// escape de comillas mediante "" (estándar RFC 4180).
List<String> _splitCsvLine(String line) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c == ',' && !inQuotes) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(c);
    }
  }
  fields.add(buffer.toString());
  return fields;
}
