class AppConstants {
  AppConstants._();

  // Database
  static const String databaseName = 'stockist.db';
  static const int databaseVersion = 3;

  // Preferences
  static const String lastBackupKey = 'last_backup_timestamp';
  static const int backupReminderHours = 4;

  // Format
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String currencyFormat = 'Rp #,##0';
}
