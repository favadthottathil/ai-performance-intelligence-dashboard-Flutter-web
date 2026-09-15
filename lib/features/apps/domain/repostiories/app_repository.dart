import '../../data/models/app_model.dart';

abstract class AppsRepository {
  Future<AppModel> createApp(String name);
  Future<AppModel> rotateApiKey(String appId);
  Future<List<AppModel>> getApps();
}
