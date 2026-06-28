import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateHelper {
  static Future<void> initialize() async {
    await initializeDateFormatting('id_ID', null);
  }

  static String formatDate(dynamic date) {
    if (date == null) return '-';
    
    DateTime? dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date);
    } else if (date is DateTime) {
      dateTime = date;
    }
    
    if (dateTime == null) return '-';

    try {
      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      // Fallback to default English formatting if locale is not loaded/fails
      final formatter = DateFormat('dd MMMM yyyy');
      return formatter.format(dateTime.toLocal());
    }
  }
}
