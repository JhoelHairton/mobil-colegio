import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda_escolar_adventista/features/admin/domain/usecases/publish_event.dart';
import 'package:agenda_escolar_adventista/features/admin/domain/usecases/review_document.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:agenda_escolar_adventista/features/auth/domain/entities/user_role.dart';
import 'package:agenda_escolar_adventista/features/documents/domain/entities/document.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/providers/documents_providers.dart';
import 'package:agenda_escolar_adventista/features/events/domain/entities/event.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/providers/events_providers.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:agenda_escolar_adventista/shared/mock_data/mock_users.dart';

// ─────────────────────────────────────────────────────────────────────────
// USE CASE
// ─────────────────────────────────────────────────────────────────────────

final reviewDocumentUseCaseProvider = Provider<ReviewDocument>((ref) {
  return ReviewDocument(
    ref.watch(documentsRepositoryProvider),
    ref.watch(notificationsRepositoryProvider),
  );
});

final publishEventUseCaseProvider = Provider<PublishEvent>((ref) {
  return PublishEvent(
    ref.watch(eventsRepositoryProvider),
    ref.watch(notificationsRepositoryProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────
// EVENTOS GLOBALES (admin)
// ─────────────────────────────────────────────────────────────────────────

/// Stream con TODOS los eventos del sistema (incluye archivados e
/// inactivos). Usar sólo en pantallas administrativas.
final allEventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchAllEvents();
});

/// Filtros temporales del listado admin (incluye opción `archived`).
enum AdminEventFilter {
  upcoming('Próximos'),
  past('Pasados'),
  archived('Archivados');

  const AdminEventFilter(this.displayName);
  final String displayName;
}

final adminEventsFilterProvider =
    StateProvider<AdminEventFilter>((ref) => AdminEventFilter.upcoming);

final adminEventsSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAdminEventsProvider =
    Provider<AsyncValue<List<Event>>>((ref) {
  final asyncList = ref.watch(allEventsStreamProvider);
  final filter = ref.watch(adminEventsFilterProvider);
  final query = ref.watch(adminEventsSearchQueryProvider).trim().toLowerCase();

  return asyncList.whenData((events) {
    Iterable<Event> result = events;
    result = result.where((e) {
      switch (filter) {
        case AdminEventFilter.upcoming:
          return !e.isArchived && !e.isPast;
        case AdminEventFilter.past:
          return !e.isArchived && e.isPast;
        case AdminEventFilter.archived:
          return e.isArchived;
      }
    });
    if (query.isNotEmpty) {
      result = result.where(
        (e) =>
            e.title.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query) ||
            e.description.toLowerCase().contains(query),
      );
    }
    return result.toList(growable: false);
  });
});

/// Conteo por tipo (usado para mostrar dentro del segmento).
final adminEventsCountByFilterProvider =
    Provider<Map<AdminEventFilter, int>>((ref) {
  final asyncList = ref.watch(allEventsStreamProvider);
  final base = {for (final f in AdminEventFilter.values) f: 0};
  return asyncList.maybeWhen(
    data: (events) {
      final counts = Map<AdminEventFilter, int>.from(base);
      for (final e in events) {
        if (e.isArchived) {
          counts[AdminEventFilter.archived] =
              counts[AdminEventFilter.archived]! + 1;
        } else if (e.isPast) {
          counts[AdminEventFilter.past] = counts[AdminEventFilter.past]! + 1;
        } else {
          counts[AdminEventFilter.upcoming] =
              counts[AdminEventFilter.upcoming]! + 1;
        }
      }
      return counts;
    },
    orElse: () => base,
  );
});

// ─────────────────────────────────────────────────────────────────────────
// STREAMS GLOBALES (admin / secretaría)
// ─────────────────────────────────────────────────────────────────────────

/// Stream con TODOS los documentos del sistema. Usar sólo en pantallas
/// de admin/secretaría — los padres siguen consumiendo
/// [myDocumentsStreamProvider].
final allDocumentsStreamProvider = StreamProvider<List<AppDocument>>((ref) {
  return ref.watch(documentsRepositoryProvider).watchAllDocuments();
});

/// Filtro de la bandeja: `null` = todos, o estado específico.
/// Por defecto arranca en pendientes (lo que la secretaría revisa).
final adminDocumentsStatusFilterProvider =
    StateProvider<DocumentStatus?>((ref) => DocumentStatus.pending);

final filteredAllDocumentsProvider =
    Provider<AsyncValue<List<AppDocument>>>((ref) {
  final asyncList = ref.watch(allDocumentsStreamProvider);
  final filter = ref.watch(adminDocumentsStatusFilterProvider);
  return asyncList.whenData((items) {
    if (filter == null) return items;
    return items.where((d) => d.status == filter).toList(growable: false);
  });
});

/// Conteos por estado para la bandeja y los chips del filtro.
final adminDocumentCountsByStatusProvider =
    Provider<Map<DocumentStatus, int>>((ref) {
  final asyncList = ref.watch(allDocumentsStreamProvider);
  final base = {for (final s in DocumentStatus.values) s: 0};
  return asyncList.maybeWhen(
    data: (docs) {
      final counts = Map<DocumentStatus, int>.from(base);
      for (final d in docs) {
        counts[d.status] = (counts[d.status] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => base,
  );
});

// ─────────────────────────────────────────────────────────────────────────
// KPIs DEL DASHBOARD
// ─────────────────────────────────────────────────────────────────────────

/// Cantidad total de usuarios activos (no preregistrados, no suspendidos
/// ni egresados). En mock es estático; cuando llegue Firebase se hace
/// query a Firestore con un agregado.
final totalActiveUsersProvider = Provider<int>((ref) {
  return MockUsers.all.where((u) => u.role.isMobileUser).length;
});

/// Total de docentes activos (informativo en el dashboard).
final totalTeachersProvider = Provider<int>((ref) {
  return MockUsers.all.where((u) => u.role == UserRole.teacher).length;
});

/// Conteo de asistencias registradas hoy entre todos los docentes
/// activos. Lo usa el dashboard del admin.
final attendancesTodayCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  final teachers = MockUsers.all.where((u) => u.role == UserRole.teacher);
  var count = 0;
  for (final teacher in teachers) {
    if (await repo.hasCheckedInToday(teacher.uid)) {
      count++;
    }
  }
  return count;
});

/// Eventos activos no archivados del catálogo.
final activeEventsCountProvider = Provider<int>((ref) {
  final asyncList = ref.watch(eventsStreamProvider);
  return asyncList.maybeWhen(
    data: (events) =>
        events.where((e) => e.isActive && !e.isArchived && !e.isPast).length,
    orElse: () => 0,
  );
});

/// Re-exportamos para que la pantalla del dashboard tenga un único
/// import.
final unreadAdminNotificationsProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationsCountProvider);
});
