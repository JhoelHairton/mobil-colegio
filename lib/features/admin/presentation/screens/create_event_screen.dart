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
import 'package:agenda_escolar_adventista/core/widgets/primary_button.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/providers/admin_providers.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/providers/auth_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/widgets/event_category_x.dart';

/// Pantalla de crear / editar evento. Si [eventId] viene null, crea
/// uno nuevo. Si viene con valor, carga los datos del evento y permite
/// editar / eliminar.
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key, this.eventId});

  final String? eventId;

  bool get isEditing => eventId != null;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  EventCategory _category = EventCategory.academic;
  TargetAudience _audience = TargetAudience.all;
  DateTime _startDate = _roundToHour(DateTime.now().add(const Duration(days: 1)));
  DateTime _endDate =
      _roundToHour(DateTime.now().add(const Duration(days: 1, hours: 2)));

  bool _hydrated = false;
  bool _submitting = false;
  Event? _loadedEvent;

  static DateTime _roundToHour(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour, 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _hydrateFromEvent(Event event) {
    if (_hydrated) return;
    _loadedEvent = event;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _category = event.category;
    _audience = event.targetAudience;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _hydrated = true;
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminEvents);
  }

  Future<void> _pickStart() async {
    final picked = await _pickDateTime(initial: _startDate);
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      // Si el fin queda antes del inicio, lo empujamos +2h.
      if (_endDate.isBefore(_startDate.add(const Duration(minutes: 30)))) {
        _endDate = _startDate.add(const Duration(hours: 2));
      }
    });
  }

  Future<void> _pickEnd() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await _pickDateTime(initial: _endDate);
    if (picked == null) return;
    if (picked.isBefore(_startDate)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin no puede ser antes del inicio.'),
        ),
      );
      return;
    }
    setState(() => _endDate = picked);
  }

  Future<DateTime?> _pickDateTime({required DateTime initial}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: 'Selecciona la fecha',
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'Selecciona la hora',
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(currentUserProvider);
    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tu sesión expiró. Vuelve a iniciar.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final useCase = ref.read(publishEventUseCaseProvider);
      if (widget.isEditing && _loadedEvent != null) {
        await useCase.update(
          _loadedEvent!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            startDate: _startDate,
            endDate: _endDate,
            location: _locationController.text.trim(),
            targetAudience: _audience,
          ),
        );
        messenger.showSnackBar(
          const SnackBar(content: Text('Evento actualizado.')),
        );
      } else {
        final draft = Event(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          startDate: _startDate,
          endDate: _endDate,
          location: _locationController.text.trim(),
          targetAudience: _audience,
          createdBy: user.uid,
          createdAt: DateTime.now(),
          isActive: true,
          isArchived: false,
        );
        await useCase.create(draft);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Evento publicado. Se notificó a la audiencia.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      if (!mounted) return;
      _handleBack();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (_loadedEvent == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        title: const Text('¿Eliminar evento?'),
        content: const Text(
          'Esta acción no se puede deshacer. Considera "Archivar" si solo quieres ocultarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    try {
      await ref
          .read(publishEventUseCaseProvider)
          .delete(_loadedEvent!.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Evento eliminado.')),
      );
      if (!mounted) return;
      _handleBack();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final asyncEvent = ref.watch(eventByIdProvider(widget.eventId!));
      return asyncEvent.when(
        loading: () => const _LoadingScaffold(),
        error: (err, _) => _ErrorScaffold(
          message: err.toString(),
          onBack: _handleBack,
        ),
        data: (event) {
          if (event == null) {
            return _ErrorScaffold(
              message: 'Evento no encontrado.',
              onBack: _handleBack,
            );
          }
          _hydrateFromEvent(event);
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            title: widget.isEditing ? 'Editar evento' : 'Nuevo evento',
            subtitle: widget.isEditing
                ? 'Los cambios se reflejarán a la audiencia que ya lo ve'
                : 'Se notificará automáticamente a la audiencia que elijas',
            onBack: _handleBack,
            onDelete: widget.isEditing ? _confirmDelete : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(label: 'Título'),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _titleController,
                      hint: 'Ej. Feria cultural adventista',
                      icon: PhosphorIcons.textT(),
                      validator: (v) => (v == null || v.trim().length < 4)
                          ? 'Indica un título descriptivo'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Descripción'),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _descriptionController,
                      hint: 'Detalles del evento, requisitos, contexto…',
                      icon: PhosphorIcons.article(),
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Describe el evento brevemente'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Categoría'),
                    const SizedBox(height: AppSpacing.md),
                    _CategorySelector(
                      selected: _category,
                      onChanged: (c) => setState(() => _category = c),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Audiencia'),
                    const SizedBox(height: AppSpacing.md),
                    _AudienceSegmented(
                      selected: _audience,
                      onChanged: (a) => setState(() => _audience = a),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Fechas'),
                    const SizedBox(height: AppSpacing.md),
                    _DateRow(
                      label: 'Inicio',
                      value: _startDate,
                      onTap: _pickStart,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DateRow(
                      label: 'Fin',
                      value: _endDate,
                      onTap: _pickEnd,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Ubicación'),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _locationController,
                      hint: 'Ej. Auditorio principal',
                      icon: PhosphorIcons.mapPin(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Indica el lugar'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: _submitting
                          ? 'Guardando…'
                          : widget.isEditing
                              ? 'Guardar cambios'
                              : 'Publicar evento',
                      icon: widget.isEditing
                          ? PhosphorIcons.floppyDisk()
                          : PhosphorIcons.megaphone(),
                      isLoading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

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
                    title,
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      PhosphorIcons.trash(),
                      size: 20,
                      color: AppColors.error,
                    ),
                    tooltip: 'Eliminar',
                    splashRadius: 18,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, size: 18, color: AppColors.textTertiary),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 0),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onChanged});

  final EventCategory selected;
  final ValueChanged<EventCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: EventCategory.values.map((cat) {
        final isActive = cat == selected;
        return GestureDetector(
          onTap: () => onChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? cat.color.withValues(alpha: 0.10)
                  : AppColors.surface,
              borderRadius: AppRadius.borderFull,
              border: Border.all(
                color: isActive ? cat.color : AppColors.border,
                width: isActive ? 1.2 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 14,
                  color: isActive ? cat.color : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  cat.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive ? cat.color : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AudienceSegmented extends StatelessWidget {
  const _AudienceSegmented({required this.selected, required this.onChanged});

  final TargetAudience selected;
  final ValueChanged<TargetAudience> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        children: TargetAudience.values.map((aud) {
          final isActive = aud == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(aud),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surface : Colors.transparent,
                  borderRadius: AppRadius.borderFull,
                  border: isActive
                      ? Border.all(color: AppColors.border, width: 0.5)
                      : null,
                ),
                child: Text(
                  aud.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat("EEEE d 'de' MMMM, HH:mm", 'es_PE').format(value);
    final cap = dateLabel.isEmpty
        ? dateLabel
        : '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}';

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.borderBase,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderBase,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderBase,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  PhosphorIcons.calendarBlank(),
                  size: 18,
                  color: AppColors.primary,
                ),
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
                    Text(cap, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(),
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SCAFFOLDS DE LOADING / ERROR (modo edición)
// ─────────────────────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: onBack,
                icon: Icon(PhosphorIcons.arrowLeft(), size: 22),
              ),
              const Spacer(),
              Icon(
                PhosphorIcons.warningCircle(),
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
