import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/app_model.dart';

@LazySingleton()
class AppsRemoteDataSource {
  final Dio dio;
  AppsRemoteDataSource(this.dio);

  Future<AppModel> createApp(String name) async {
    final res = await dio.post('/apps', data: {'name': name});
    return AppModel.fromJson(res.data);
  }

  Future<List<AppModel>> getApps() async {
    try {
      final res = await dio.get('/apps');
      return (res.data as List).map((e) => AppModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}
