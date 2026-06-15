import 'package:ai_performance_intelligence_platform/features/apps/domain/repostiories/app_repository.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/app_model.dart';

@lazySingleton
@lazySingleton
class GetAppsUseCase {
  final AppsRepository repository;

  GetAppsUseCase(this.repository);

  Future<List<AppModel>> call() async {
    return await repository.getApps();
  }
}
