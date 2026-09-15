class ApiConstants {
  /// Backend base URL. Override at build/run time with:
  /// `flutter run --dart-define=API_BASE_URL=https://your-backend`
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ai-performance-intelligence-backend.onrender.com',
  );
  static const summary = '/metrics/summary';
  static const analyze = '/metrics/analyze';
  static const stream = '/metrics/stream';

  /// Safety-net poll interval, used only when the live SSE stream is
  /// unavailable (for example behind a proxy that buffers event streams).
  /// Updates normally arrive over the stream, so this is deliberately slow:
  /// each poll also re-runs the backend's AI analysis endpoint.
  static const fallbackRefreshInterval = Duration(minutes: 2);

  /// Ingested metrics can arrive many times per second. Arrivals within this
  /// window are collapsed into a single refresh so a busy app cannot
  /// stampede the summary endpoint.
  static const liveCoalesceWindow = Duration(seconds: 3);
}
