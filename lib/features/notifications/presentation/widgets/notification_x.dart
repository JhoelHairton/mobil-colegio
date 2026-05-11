import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/features/notifications/domain/entities/app_notification.dart';

/// Extensiones de presentación para [NotificationType].
///
/// Vive en presentation/widgets para no contaminar el domain con
/// dependencias de UI.
extension NotificationTypeX on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.eventPublished:
        return PhosphorIcons.calendarBlank();
      case NotificationType.documentApproved:
        return PhosphorIcons.checkCircle();
      case NotificationType.documentRejected:
        return PhosphorIcons.xCircle();
      case NotificationType.documentReviewing:
        return PhosphorIcons.eye();
      case NotificationType.attendanceReminder:
        return PhosphorIcons.fingerprint();
      case NotificationType.generalAnnouncement:
        return PhosphorIcons.megaphone();
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.eventPublished:
        return AppColors.primary;
      case NotificationType.documentApproved:
        return AppColors.success;
      case NotificationType.documentRejected:
        return AppColors.error;
      case NotificationType.documentReviewing:
        return AppColors.info;
      case NotificationType.attendanceReminder:
        return AppColors.warning;
      case NotificationType.generalAnnouncement:
        return AppColors.accent;
    }
  }
}
