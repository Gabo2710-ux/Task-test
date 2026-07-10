import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'No date';
    try {
      final date = DateTime.parse(isoString);
      // Format to something like: Jul 15, 2026 - 16:00
      return DateFormat('MMM dd, yyyy - HH:mm').format(date.toLocal());
    } catch (e) {
      return 'Invalid date';
    }
  }

  static String formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }
}
