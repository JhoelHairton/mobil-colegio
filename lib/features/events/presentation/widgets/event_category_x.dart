import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';

/// Extensiones de presentación para [EventCategory].
///
/// Vive en presentation/widgets para no contaminar el domain con
/// dependencias de UI (PhosphorIcons).
extension EventCategoryX on EventCategory {
  IconData get icon {
    switch (this) {
      case EventCategory.cultural:
        return PhosphorIcons.musicNotes();
      case EventCategory.spiritual:
        return PhosphorIcons.bookOpen();
      case EventCategory.academic:
        return PhosphorIcons.graduationCap();
      case EventCategory.sports:
        return PhosphorIcons.basketball();
      case EventCategory.campaign:
        return PhosphorIcons.handHeart();
    }
  }
}
