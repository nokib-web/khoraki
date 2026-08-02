import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }
}
