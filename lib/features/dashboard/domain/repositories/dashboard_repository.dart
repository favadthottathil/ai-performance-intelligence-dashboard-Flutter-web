abstract class DashboardRepository {
  Future<List<dynamic>> getSummary(String appId);
  Future<Map<String, dynamic>> analyze(String appId);
}
