import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String formatBDT(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '৳',
      decimalDigits: 2,
      locale: 'bn_BD',
    );
    return formatter.format(amount);
  }
}
