import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';

abstract class DashboardRemoteDataSource {
  Future<List<dynamic>> fetchSummary(String appId);
  Future<Map<String, dynamic>> analyze(String appId);
}

@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient client;

  DashboardRemoteDataSourceImpl(this.client);

  @override
  Future<List<dynamic>> fetchSummary(String appId) async {
    final response = await client.dio.get(
      '/metrics/summary',
      queryParameters: {'appId': appId},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> analyze(String appId) async {
    final response = await client.dio.get(
      '/metrics/analyze',
      queryParameters: {'appId': appId},
    );
    return response.data;
  }
}
