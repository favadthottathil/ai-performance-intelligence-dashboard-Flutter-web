import 'package:ai_performance_intelligence_platform/features/apps/domain/repostiories/app_repository.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/app_model.dart';

/// Issues a replacement API key for an app, invalidating the previous one.
@LazySingleton()
class RotateApiKeyUseCase {
  final AppsRepository repository;
  RotateApiKeyUseCase(this.repository);

  Future<AppModel> call(String appId) {
    return repository.rotateApiKey(appId);
  }
}
