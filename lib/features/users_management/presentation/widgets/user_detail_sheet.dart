import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/core/theme/app_radius.dart';
import 'package:agenda_escolar_adventista/core/theme/app_spacing.dart';
import 'package:agenda_escolar_adventista/core/theme/app_text_styles.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/providers/users_management_providers.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/widgets/user_x.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

Future<void> showUserDetailSheet({
  required BuildContext context,
  required AppUser user,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => UserDetailSheet(initialUser: user),
  );
}

/// Bottom sheet con el detalle de un usuario y sus acciones.
class UserDetailSheet extends ConsumerStatefulWidget {
  const UserDetailSheet({super.key, required this.initialUser});

  final AppUser initialUser;

  @override
  ConsumerState<UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends ConsumerState<UserDetailSheet> {
  late AppUser _user;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
  }

  Future<void> _runAction(
    String successMessage,
    Future<AppUser> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _processing = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _user = updated;
        _processing = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo completar: $e')),
      );
    }
  }

  Future<void> _suspend() => _runAction(
        'Cuenta suspendida',
        () => ref
            .read(usersRepositoryProvider)
            .updateStatus(_user.uid, UserStatus.suspended),
      );

  Future<void> _reactivate() => _runAction(
        'Cuenta reactivada',
        () => ref
            .read(usersRepositoryProvider)
            .updateStatus(_user.uid, UserStatus.active),
      );

  Future<void> _regenerate() => _runAction(
        'Código de activación regenerado',
        () => ref
            .read(usersRepositoryProvider)
            .regenerateActivationCode(_user.uid),
      );

  void _copyCode() {
    final code = _user.activationCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _user.role;
    final status = _user.status;
    final initial =
        _user.displayName.isEmpty ? '?' : _user.displayName[0].toUpperCase();

    final children = role == UserRole.parent
        ? _user.parentOfStudentIds
            .map(MockUsers.findById)
            .whereType<AppUser>()
            .toList()
        : const <AppUser>[];

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
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: role.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: AppTextStyles.h1.copyWith(color: role.color),
                    ),
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
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _RolePill(role: role),
                    _StatusPill(status: status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _user.displayName,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _user.email,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (status == UserStatus.preregistered)
                  _ActivationCodeCard(
                    code: _user.activationCode ?? '—',
                    expiresAt: _user.activationCodeExpiresAt,
                    isExpired: _user.activationCode != null &&
                        !_user.isActivationCodeValid(),
                    onCopy: _copyCode,
                  ),
                if (status == UserStatus.preregistered)
                  const SizedBox(height: AppSpacing.lg),
                _InfoCard(user: _user, children: children),
                const SizedBox(height: AppSpacing.xl),
                ..._buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];
    final status = _user.status;

    if (status == UserStatus.preregistered) {
      actions.add(
        _PrimaryButton(
          icon: PhosphorIcons.arrowsClockwise(),
          label: 'Regenerar código',
          color: AppColors.primary,
          loading: _processing,
          onTap: _processing ? null : _regenerate,
        ),
      );
    }

    if (status == UserStatus.active) {
      actions.add(
        _PrimaryButton(
          icon: PhosphorIcons.prohibit(),
          label: 'Suspender cuenta',
          color: AppColors.error,
          loading: _processing,
          onTap: _processing ? null : _suspend,
        ),
      );
    }

    if (status == UserStatus.suspended) {
      actions.add(
        _PrimaryButton(
          icon: PhosphorIcons.checkCircle(),
          label: 'Reactivar cuenta',
          color: AppColors.success,
          loading: _processing,
          onTap: _processing ? null : _reactivate,
        ),
      );
    }

    if (actions.isNotEmpty) actions.add(const SizedBox(height: AppSpacing.sm));
    actions.add(_CloseButton());
    return actions;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SUBWIDGETS
// ─────────────────────────────────────────────────────────────────────────

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: role.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role.icon, size: 12, color: role.color),
          const SizedBox(width: 4),
          Text(
            role.displayName.toUpperCase(),
            style: AppTextStyles.metadata.copyWith(
              color: role.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final UserStatus status;

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

class _ActivationCodeCard extends StatelessWidget {
  const _ActivationCodeCard({
    required this.code,
    required this.expiresAt,
    required this.isExpired,
    required this.onCopy,
  });

  final String code;
  final DateTime? expiresAt;
  final bool isExpired;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final color = isExpired ? AppColors.error : AppColors.warning;
    final softColor = isExpired ? AppColors.errorSoft : AppColors.warningSoft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired
                    ? PhosphorIcons.warning(PhosphorIconsStyle.fill)
                    : PhosphorIcons.key(),
                size: 16,
                color: color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isExpired ? 'Código expirado' : 'Código de activación',
                style: AppTextStyles.metadata.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  code,
                  style: AppTextStyles.h1.copyWith(
                    color: color,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: Icon(PhosphorIcons.copy(), size: 18, color: color),
                splashRadius: 18,
              ),
            ],
          ),
          if (expiresAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              isExpired
                  ? 'Venció el ${DateFormat("d 'de' MMMM 'de' yyyy", 'es_PE').format(expiresAt!)}. Regenera uno nuevo.'
                  : 'Vence el ${DateFormat("d 'de' MMMM 'de' yyyy", 'es_PE').format(expiresAt!)}.',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user, required this.children});

  final AppUser user;
  final List<AppUser> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _InfoRow(
        icon: PhosphorIcons.envelope(),
        label: 'Email',
        value: user.email,
      ),
      if (user.phoneNumber != null)
        _InfoRow(
          icon: PhosphorIcons.phone(),
          label: 'Teléfono',
          value: user.phoneNumber!,
        ),
      _InfoRow(
        icon: PhosphorIcons.calendarBlank(),
        label: 'Creado',
        value: _formatDate(user.createdAt),
      ),
    ];

    if (user.role == UserRole.student) {
      if (user.gradeLevel != null) {
        rows.add(
          _InfoRow(
            icon: PhosphorIcons.graduationCap(),
            label: 'Grado',
            value: user.gradeLevel!,
          ),
        );
      }
      if (user.classroomCode != null) {
        rows.add(
          _InfoRow(
            icon: PhosphorIcons.identificationCard(),
            label: 'Aula',
            value: user.classroomCode!,
          ),
        );
      }
    }

    if (user.role == UserRole.parent && children.isNotEmpty) {
      final names = children.map((c) {
        final firstName = c.displayName.split(' ').first;
        final grade = c.gradeLevel ?? c.classroomCode ?? '';
        return grade.isEmpty ? firstName : '$firstName ($grade)';
      }).join(', ');
      rows.add(
        _InfoRow(
          icon: PhosphorIcons.usersThree(),
          label: children.length == 1 ? 'Hijo vinculado' : 'Hijos vinculados',
          value: names,
        ),
      );
    }

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

  static String _formatDate(DateTime when) {
    final formatted = DateFormat("d 'de' MMMM 'de' yyyy", 'es_PE').format(when);
    return formatted.isEmpty
        ? formatted
        : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: onTap == null ? color.withValues(alpha: 0.5) : color,
        borderRadius: AppRadius.borderBase,
        child: InkWell(
          borderRadius: AppRadius.borderBase,
          onTap: onTap,
          child: Center(
            child: loading
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
