import 'package:flutter/material.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';

enum EventCategory {
  cultural('cultural', 'Cultural', AppColors.categoryCultural),
  spiritual('spiritual', 'Espiritual', AppColors.categorySpiritual),
  academic('academic', 'Académico', AppColors.categoryAcademic),
  sports('sports', 'Deportivo', AppColors.categorySports),
  campaign('campaign', 'Campaña', AppColors.categoryCampaign);

  final String value;
  final String displayName;
  final Color color;

  const EventCategory(this.value, this.displayName, this.color);

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => EventCategory.academic,
    );
  }
}

enum TargetAudience {
  all('all', 'Todos'),
  teachers('teachers', 'Solo docentes'),
  parents('parents', 'Solo padres');

  final String value;
  final String displayName;

  const TargetAudience(this.value, this.displayName);

  static TargetAudience fromString(String value) {
    return TargetAudience.values.firstWhere(
      (a) => a.value == value,
      orElse: () => TargetAudience.all,
    );
  }
}
