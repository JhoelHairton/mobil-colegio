import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/screens/create_event_screen.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/screens/events_management_screen.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/screens/pending_documents_screen.dart';
import 'package:agenda_escolar_adventista/features/admin/presentation/screens/reports_screen.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/screens/bulk_import_screen.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/screens/create_user_screen.dart';
import 'package:agenda_escolar_adventista/features/users_management/presentation/screens/users_management_screen.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/screens/attendance_success_screen.dart';
import 'package:agenda_escolar_adventista/features/attendance/presentation/screens/qr_scan_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/activation_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/login_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/splash_screen.dart';
import 'package:agenda_escolar_adventista/features/auth/presentation/screens/welcome_screen.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/screens/my_documents_screen.dart';
import 'package:agenda_escolar_adventista/features/documents/presentation/screens/upload_document_screen.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/screens/event_detail_screen.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/screens/events_list_screen.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/screens/parent_home_screen.dart';
import 'package:agenda_escolar_adventista/features/events/presentation/screens/teacher_home_screen.dart';
import 'package:agenda_escolar_adventista/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:agenda_escolar_adventista/features/student/presentation/screens/student_home_screen.dart';
import 'package:agenda_escolar_adventista/features/style_guide/presentation/screens/style_guide_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.activate,
        name: 'activate',
        builder: (_, __) => const ActivationScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentHome,
        name: 'parentHome',
        builder: (_, __) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherHome,
        name: 'teacherHome',
        builder: (_, __) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        name: 'studentHome',
        builder: (_, __) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        name: 'adminHome',
        builder: (_, __) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPendingDocuments,
        name: 'adminPendingDocuments',
        builder: (_, __) => const PendingDocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: 'adminUsers',
        builder: (_, __) => const UsersManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateUser,
        name: 'adminCreateUser',
        builder: (_, __) => const CreateUserScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEvents,
        name: 'adminEvents',
        builder: (_, __) => const EventsManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateEvent,
        name: 'adminCreateEvent',
        builder: (_, __) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.adminEditEvent}/:eventId',
        name: 'adminEditEvent',
        builder: (ctx, state) => CreateEventScreen(
          eventId: state.pathParameters['eventId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        name: 'adminReports',
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminBulkImport,
        name: 'adminBulkImport',
        builder: (_, __) => const BulkImportScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventsList,
        name: 'eventsList',
        builder: (_, __) => const EventsListScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.eventDetail}/:eventId',
        name: 'eventDetail',
        builder: (ctx, state) => EventDetailScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.qrScan,
        name: 'qrScan',
        builder: (_, __) => const QrScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceHistory,
        name: 'attendanceHistory',
        builder: (_, __) => const AttendanceHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceSuccess,
        name: 'attendanceSuccess',
        builder: (_, __) => const AttendanceSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.myDocuments,
        name: 'myDocuments',
        builder: (_, __) => const MyDocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.uploadDocument,
        name: 'uploadDocument',
        builder: (_, __) => const UploadDocumentScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.styleGuide,
        name: 'styleGuide',
        builder: (_, __) => const StyleGuideScreen(),
      ),
    ],
  );
});
