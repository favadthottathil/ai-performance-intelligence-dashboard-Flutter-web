import '../../data/models/app_model.dart';

abstract class AppsRepository {
  Future<AppModel> createApp(String name);
  Future<List<AppModel>> getApps();
}
