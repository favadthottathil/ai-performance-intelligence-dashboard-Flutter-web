import 'package:ai_performance_intelligence_platfrom/features/apps/domain/repostiories/app_repository.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/app_model.dart';

@LazySingleton()
class CreateAppUseCase {
  final AppsRepository repository;
  CreateAppUseCase(this.repository);

  Future<AppModel> call(String name) {
    return repository.createApp(name);
  }
}
