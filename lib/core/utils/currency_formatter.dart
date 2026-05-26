import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _clpFormatter = NumberFormat.currency(
    locale: 'es_CL',
    symbol: r'$',
    decimalDigits: 0,
    customPattern: '\u00A4#,##0',
  );

  static String clp(num value) {
    return _clpFormatter.format(value);
  }

  static String number(num value) {
    return NumberFormat.decimalPattern('es_CL').format(value);
  }
}
