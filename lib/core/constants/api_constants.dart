class ApiConstants {
  /// Backend base URL. Override at build/run time with:
  /// `flutter run --dart-define=API_BASE_URL=https://your-backend`
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ai-performance-intelligence-backend.onrender.com',
  );
  static const summary = '/metrics/summary';
  static const analyze = '/metrics/analyze';

  /// How often the dashboard polls the backend for fresh data.
  static const refreshInterval = Duration(seconds: 15);
}
