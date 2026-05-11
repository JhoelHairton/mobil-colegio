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
import 'package:agenda_escolar_adventista/features/auth/domain/entities/app_user.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/providers/users_management_providers.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/widgets/user_card.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/widgets/user_detail_sheet.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/widgets/user_x.dart';

class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredUsersProvider);
    final selectedRole = ref.watch(usersFilterRoleProvider);
    final counts = ref.watch(usersCountByRoleProvider);
    final pendingActivations = ref.watch(pendingActivationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            subtitle: _subtitle(pendingActivations),
            chips: _buildChips(ref, selectedRole, counts),
            onBack: () => _handleBack(context),
          ),
          const _SearchBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                ref.invalidate(allUsersStreamProvider);
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: filtered.when(
                loading: () => const _LoadingList(),
                error: (err, _) => _ScrollableSingle(
                  child: ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(allUsersStreamProvider),
                  ),
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return _ScrollableSingle(
                      child: _buildEmpty(ref, selectedRole),
                    );
                  }
                  return _UsersList(users: users);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.adminCreateUser),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        elevation: 0,
        icon: Icon(PhosphorIcons.userPlus(), size: 18),
        label: Text(
          'Nuevo usuario',
          style: AppTextStyles.buttonRegular.copyWith(
            color: AppColors.textOnAccent,
          ),
        ),
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

  String _subtitle(int pendingActivations) {
    if (pendingActivations == 0) return 'Sin activaciones pendientes';
    if (pendingActivations == 1) return '1 activación pendiente';
    return '$pendingActivations activaciones pendientes';
  }

  List<Widget> _buildChips(
    WidgetRef ref,
    UserRole? selected,
    Map<UserRole, int> counts,
  ) {
    final controller = ref.read(usersFilterRoleProvider.notifier);
    final total = counts.values.fold(0, (a, b) => a + b);
    return [
      CategoryChip(
        label: 'Todos · $total',
        selected: selected == null,
        onTap: () => controller.state = null,
      ),
      ...UserRole.values.map((role) {
        final count = counts[role] ?? 0;
        return CategoryChip(
          label: '${role.displayName} · $count',
          icon: role.icon,
          color: role.color,
          selected: selected == role,
          onTap: () => controller.state = role,
        );
      }),
    ];
  }

  Widget _buildEmpty(WidgetRef ref, UserRole? selected) {
    final query = ref.read(usersSearchQueryProvider).trim();
    if (query.isNotEmpty) {
      return EmptyState(
        icon: PhosphorIcons.magnifyingGlass(),
        title: 'Sin resultados para "$query"',
        subtitle: 'Prueba con otro nombre o correo.',
        actionLabel: 'Limpiar búsqueda',
        onAction: () => ref.read(usersSearchQueryProvider.notifier).state = '',
      );
    }
    if (selected != null) {
      return EmptyState(
        icon: selected.icon,
        title: 'Sin usuarios en "${selected.displayName}"',
        subtitle: 'Cambia de filtro para ver otros roles.',
        actionLabel: 'Ver todos',
        onAction: () =>
            ref.read(usersFilterRoleProvider.notifier).state = null,
      );
    }
    return EmptyState(
      icon: PhosphorIcons.usersThree(),
      title: 'Sin usuarios',
      subtitle: 'Cuando registres usuarios, aparecerán aquí.',
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
                    'Usuarios',
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
// SEARCH
// ─────────────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(usersSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final external = ref.watch(usersSearchQueryProvider);
    if (external != _controller.text) {
      _controller.value = TextEditingValue(
        text: external,
        selection: TextSelection.collapsed(offset: external.length),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: TextField(
        controller: _controller,
        onChanged: (v) =>
            ref.read(usersSearchQueryProvider.notifier).state = v,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o correo',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 18,
            color: AppColors.textTertiary,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(usersSearchQueryProvider.notifier).state = '';
                  },
                  splashRadius: 18,
                ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm + 2,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// LISTA + ESTADOS
// ─────────────────────────────────────────────────────────────────────────

class _UsersList extends StatelessWidget {
  const _UsersList({required this.users});

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxxl + AppSpacing.xl,
      ),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: () => showUserDetailSheet(context: context, user: user),
        )
            .animate(delay: (index * 40).ms)
            .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
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
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: 6,
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
