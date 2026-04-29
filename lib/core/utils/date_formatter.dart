import 'package:intl/intl.dart';

/// Utilidades para formateo de fechas.
class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_PE').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_PE').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_PE').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'hace unos segundos';
    if (difference.inMinutes < 60) return 'hace \${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace \${difference.inHours} h';
    if (difference.inDays < 7) return 'hace \${difference.inDays} días';
    if (difference.inDays < 30) return 'hace \${(difference.inDays / 7).floor()} sem';
    return formatDate(date);
  }

  static String formatFirestoreId(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
