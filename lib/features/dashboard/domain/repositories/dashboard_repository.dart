abstract class DashboardRepository {
  Future<List<dynamic>> getSummary(String appId);
  Future<Map<String, dynamic>> analyze(String appId);

  /// Live feed of metrics as they are ingested for [appId].
  Stream<Map<String, dynamic>> watchMetrics(String appId);
}
