import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';

/// Extensiones de presentación para [DocumentType] y [DocumentStatus].
///
/// Vive en presentation/widgets para no contaminar el domain con
/// dependencias de UI (PhosphorIcons, AppColors).
extension DocumentTypeX on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.membership:
        return 'Membresía IASD';
      case DocumentType.discount:
        return 'Solicitud de descuento';
      case DocumentType.tithe:
        return 'Comprobante de diezmo';
    }
  }

  String get shortDisplayName {
    switch (this) {
      case DocumentType.membership:
        return 'Membresía';
      case DocumentType.discount:
        return 'Descuento';
      case DocumentType.tithe:
        return 'Diezmo';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.membership:
        return PhosphorIcons.identificationBadge();
      case DocumentType.discount:
        return PhosphorIcons.percent();
      case DocumentType.tithe:
        return PhosphorIcons.handCoins();
    }
  }

  Color get color {
    switch (this) {
      case DocumentType.membership:
        return AppColors.primary;
      case DocumentType.discount:
        return AppColors.categorySports;
      case DocumentType.tithe:
        return AppColors.categorySpiritual;
    }
  }
}

extension DocumentStatusX on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pendiente';
      case DocumentStatus.reviewing:
        return 'En revisión';
      case DocumentStatus.approved:
        return 'Aprobado';
      case DocumentStatus.rejected:
        return 'Rechazado';
    }
  }

  Color get color {
    switch (this) {
      case DocumentStatus.pending:
        return AppColors.warning;
      case DocumentStatus.reviewing:
        return AppColors.info;
      case DocumentStatus.approved:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  Color get softColor {
    switch (this) {
      case DocumentStatus.pending:
        return AppColors.warningSoft;
      case DocumentStatus.reviewing:
        return AppColors.infoSoft;
      case DocumentStatus.approved:
        return AppColors.successSoft;
      case DocumentStatus.rejected:
        return AppColors.errorSoft;
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentStatus.pending:
        return PhosphorIcons.clock();
      case DocumentStatus.reviewing:
        return PhosphorIcons.eye();
      case DocumentStatus.approved:
        return PhosphorIcons.checkCircle();
      case DocumentStatus.rejected:
        return PhosphorIcons.xCircle();
    }
  }
}
