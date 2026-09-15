import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/app_model.dart';

@LazySingleton()
class AppsRemoteDataSource {
  final Dio dio;
  AppsRemoteDataSource(this.dio);

  Future<AppModel> createApp(String name) async {
    final res = await dio.post('/apps', data: {'name': name});
    return AppModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// Issues a replacement API key for [appId].
  Future<AppModel> rotateApiKey(String appId) async {
    final res = await dio.post('/apps/$appId/rotate-key');
    return AppModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<AppModel>> getApps() async {
    final res = await dio.get('/apps');
    final data = res.data;

    // The backend returns 200 [] for an account with no apps.
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AppModel.fromJson)
        .toList();
  }
}
