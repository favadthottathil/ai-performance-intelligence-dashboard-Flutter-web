import 'package:injectable/injectable.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl(this.remote);

  @override
  Future<List<dynamic>> getSummary(String appId) => remote.fetchSummary(appId);

  @override
  Future<Map<String, dynamic>> analyze(String appId) => remote.analyze(appId);
}
