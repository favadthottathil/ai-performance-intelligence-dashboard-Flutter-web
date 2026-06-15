import 'package:ai_performance_intelligence_platform/features/apps/data/datasoources/app_remote_datasource.dart';
import 'package:ai_performance_intelligence_platform/features/apps/domain/repostiories/app_repository.dart';
import 'package:injectable/injectable.dart';
import '../models/app_model.dart';

@LazySingleton(as: AppsRepository)
class AppsRepositoryImpl implements AppsRepository {
  final AppsRemoteDataSource remote;
  AppsRepositoryImpl(this.remote);

  @override
  Future<AppModel> createApp(String name) {
    return remote.createApp(name);
  }

  @override
  Future<List<AppModel>> getApps() {
    return remote.getApps();
  }
}
