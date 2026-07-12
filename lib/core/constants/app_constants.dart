class AppConstants {
  static const String appName = 'SULTHAN';
  static const String currency = '₹';
  static const double monthlyAmount = 100.0;
  static const double finePerDay = 10.0;
  static const int fineDueDay = 5; // fine applies after this day of month

  static const List<String> expenseCategories = [
    'Registration',
    'Renovation',
    'Other',
  ];

  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  static const String typeMonthly = 'MONTHLY';
  static const String typeEvent = 'EVENT';

  static const String statusPaid = 'Paid';
  static const String statusPending = 'Pending';
  static const String statusPartial = 'Partial';

  static const String keyTheme = 'theme_mode';
}
