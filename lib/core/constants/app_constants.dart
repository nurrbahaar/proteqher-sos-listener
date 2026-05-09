class AppConstants {
  const AppConstants._();

  static const String contactsBoxName = 'contacts_box';
  static const String emergencyLogsBoxName = 'emergency_logs_box';

  static const String serviceMethodChannel = 'com.sos_help_listener/service';
  static const String serviceEventChannel =
      'com.sos_help_listener/service/events';

  static const int detectionLogLimit = 100;
  static const int emergencyLogLimit = 50;
}
