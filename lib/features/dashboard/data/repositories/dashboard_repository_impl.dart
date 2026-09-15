import 'package:injectable/injectable.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../datasources/metrics_stream_datasource.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;
  final MetricsStreamDataSource stream;

  DashboardRepositoryImpl(this.remote, this.stream);

  @override
  Future<List<dynamic>> getSummary(String appId) => remote.fetchSummary(appId);

  @override
  Future<Map<String, dynamic>> analyze(String appId) => remote.analyze(appId);

  @override
  Stream<Map<String, dynamic>> watchMetrics(String appId) =>
      stream.watch(appId);
}
