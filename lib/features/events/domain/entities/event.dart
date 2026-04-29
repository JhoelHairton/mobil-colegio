import 'package:agenda_escolar_adventista/features/events/domain/entities/event_category.dart';

/// Entidad evento.
class Event {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? coverImageUrl;
  final TargetAudience targetAudience;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;
  final bool isArchived;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.targetAudience,
    required this.createdBy,
    required this.createdAt,
    required this.isActive,
    required this.isArchived,
    this.coverImageUrl,
  });

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());
}
