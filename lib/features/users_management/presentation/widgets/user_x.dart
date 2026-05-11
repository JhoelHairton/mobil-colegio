import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_status.dart';

/// Extensiones de presentación para [UserRole] y [UserStatus].
extension UserRoleX on UserRole {
  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return PhosphorIcons.shieldStar();
      case UserRole.secretary:
        return PhosphorIcons.identificationCard();
      case UserRole.teacher:
        return PhosphorIcons.chalkboardTeacher();
      case UserRole.parent:
        return PhosphorIcons.usersThree();
      case UserRole.student:
        return PhosphorIcons.graduationCap();
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return AppColors.primary;
      case UserRole.secretary:
        return AppColors.categorySpiritual;
      case UserRole.teacher:
        return AppColors.categoryAcademic;
      case UserRole.parent:
        return AppColors.accent;
      case UserRole.student:
        return AppColors.categoryCultural;
    }
  }
}

extension UserStatusX on UserStatus {
  Color get color {
    switch (this) {
      case UserStatus.preregistered:
        return AppColors.warning;
      case UserStatus.active:
        return AppColors.success;
      case UserStatus.suspended:
        return AppColors.error;
      case UserStatus.graduated:
        return AppColors.textSecondary;
    }
  }

  Color get softColor {
    switch (this) {
      case UserStatus.preregistered:
        return AppColors.warningSoft;
      case UserStatus.active:
        return AppColors.successSoft;
      case UserStatus.suspended:
        return AppColors.errorSoft;
      case UserStatus.graduated:
        return AppColors.surfaceMuted;
    }
  }

  IconData get icon {
    switch (this) {
      case UserStatus.preregistered:
        return PhosphorIcons.hourglass();
      case UserStatus.active:
        return PhosphorIcons.checkCircle();
      case UserStatus.suspended:
        return PhosphorIcons.prohibit();
      case UserStatus.graduated:
        return PhosphorIcons.graduationCap();
    }
  }
}
