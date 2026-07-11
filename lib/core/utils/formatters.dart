import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Fmt {
  static final _money =
      NumberFormat.currency(locale: 'en_IN', symbol: AppConstants.currency, decimalDigits: 0);
  static final _date = DateFormat('dd MMM yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _short = DateFormat('dd MMM');

  static String money(double v) => _money.format(v);
  static String moneyRaw(double v) => NumberFormat('#,##,##0', 'en_IN').format(v);
  static String date(DateTime d) => _date.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String short(DateTime d) => _short.format(d);
  static String monthYearOf(int month, int year) =>
      _monthYear.format(DateTime(year, month));

  static int age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }
}
