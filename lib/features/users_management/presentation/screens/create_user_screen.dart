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
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/providers/users_management_providers.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/widgets/user_x.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

/// Roles que el admin puede crear desde la app móvil. Excluye admin
/// (que se crea sólo desde el panel central) y secretary.
const _selectableRoles = [
  UserRole.teacher,
  UserRole.parent,
  UserRole.student,
];

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classroomController = TextEditingController();
  final _gradeController = TextEditingController();

  UserRole _role = UserRole.parent;
  final Set<String> _linkedStudents = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classroomController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminUsers);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);

    try {
      final created = await ref
          .read(usersRepositoryProvider)
          .createUser(
            email: _emailController.text,
            displayName: _nameController.text,
            role: _role,
            phoneNumber: _phoneController.text,
            parentOfStudentIds:
                _role == UserRole.parent ? _linkedStudents.toList() : const [],
            classroomCode:
                _role == UserRole.student ? _classroomController.text : null,
            gradeLevel:
                _role == UserRole.student ? _gradeController.text : null,
          );
      if (!mounted) return;
      _showSuccessDialog(created);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Bad state: ', ''))),
      );
    }
  }

  void _showSuccessDialog(AppUser created) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreatedUserDialog(
        user: created,
        onClose: () {
          Navigator.of(context).pop();
          // Volver a la lista. Como el sheet venía pusheado, basta con pop.
          if (context.mounted) {
            context.pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: _handleBack),
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
                    const _SectionLabel(label: 'Rol'),
                    const SizedBox(height: AppSpacing.md),
                    _RoleSelector(
                      selected: _role,
                      onChanged: (r) {
                        setState(() {
                          _role = r;
                          _linkedStudents.clear();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(label: 'Datos personales'),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _nameController,
                      label: 'Nombre completo',
                      icon: PhosphorIcons.user(),
                      validator: (v) =>
                          (v == null || v.trim().length < 3)
                              ? 'Ingresa el nombre completo'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      icon: PhosphorIcons.envelope(),
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Ingresa el correo';
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Field(
                      controller: _phoneController,
                      label: 'Teléfono (opcional)',
                      icon: PhosphorIcons.phone(),
                      keyboard: TextInputType.phone,
                    ),
                    if (_role == UserRole.student) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionLabel(label: 'Datos académicos'),
                      const SizedBox(height: AppSpacing.md),
                      _Field(
                        controller: _gradeController,
                        label: 'Grado (ej. 5° Secundaria)',
                        icon: PhosphorIcons.graduationCap(),
                        validator: (v) =>
                            _role == UserRole.student &&
                                    (v == null || v.trim().isEmpty)
                                ? 'Indica el grado'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Field(
                        controller: _classroomController,
                        label: 'Aula (ej. 5SEC-A)',
                        icon: PhosphorIcons.identificationCard(),
                      ),
                    ],
                    if (_role == UserRole.parent) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionLabel(label: 'Estudiantes vinculados'),
                      const SizedBox(height: AppSpacing.md),
                      _LinkStudentsPicker(
                        selectedIds: _linkedStudents,
                        onChanged: (id, selected) {
                          setState(() {
                            if (selected) {
                              _linkedStudents.add(id);
                            } else {
                              _linkedStudents.remove(id);
                            }
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: _submitting ? 'Creando…' : 'Crear cuenta',
                      icon: PhosphorIcons.userPlus(),
                      isLoading: _submitting,
                      onPressed: _submitting ? null : _submit,
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
                            'Se generará un código de activación de 8 caracteres con vencimiento a 90 días.',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
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
  const _Header({required this.onBack});

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
                    'Nuevo usuario',
                    style: AppTextStyles.h2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xxxxl,
                top: 2,
              ),
              child: Text(
                'Quedará pre-registrado hasta que active con el código',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
// SELECTOR DE ROL
// ─────────────────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _selectableRoles.map((role) {
        final isActive = role == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.borderBase,
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isActive
                      ? role.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: AppRadius.borderBase,
                  border: Border.all(
                    color: isActive ? role.color : AppColors.border,
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
                        color: role.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(role.icon, size: 18, color: role.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        role.displayName,
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
                        color: role.color,
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

// ─────────────────────────────────────────────────────────────────────────
// FIELD
// ─────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: AppTextStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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

// ─────────────────────────────────────────────────────────────────────────
// PICKER DE ESTUDIANTES (vincular a padre)
// ─────────────────────────────────────────────────────────────────────────

class _LinkStudentsPicker extends StatelessWidget {
  const _LinkStudentsPicker({
    required this.selectedIds,
    required this.onChanged,
  });

  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final students = MockUsers.all
        .where((u) => u.role == UserRole.student)
        .toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    if (students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.borderBase,
        ),
        child: Text(
          'Aún no hay estudiantes registrados. Crea primero a los hijos para poder vincularlos.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          for (var i = 0; i < students.length; i++) ...[
            CheckboxListTile(
              value: selectedIds.contains(students[i].uid),
              onChanged: (v) => onChanged(students[i].uid, v ?? false),
              title: Text(
                students[i].displayName,
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: Text(
                students[i].gradeLevel ??
                    students[i].classroomCode ??
                    students[i].email,
                style: AppTextStyles.metadata,
              ),
              activeColor: AppColors.primary,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (i != students.length - 1)
              const Divider(
                height: 0,
                thickness: 0.5,
                color: AppColors.divider,
                indent: AppSpacing.lg,
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DIÁLOGO DE ÉXITO CON CÓDIGO GENERADO
// ─────────────────────────────────────────────────────────────────────────

class _CreatedUserDialog extends StatelessWidget {
  const _CreatedUserDialog({required this.user, required this.onClose});

  final AppUser user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                size: 36,
                color: AppColors.success,
              ),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 500.ms,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cuenta creada',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Comparte este código con ${user.displayName.split(' ').first} para que active su cuenta.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: AppRadius.borderBase,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.30),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      user.activationCode ?? '—',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.warning,
                        letterSpacing: 4,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: user.activationCode ?? ''),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Código copiado al portapapeles'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      PhosphorIcons.copy(),
                      size: 18,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Vence a los 90 días.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Listo',
              icon: PhosphorIcons.check(),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
