import 'package:injectable/injectable.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetDashboardInsights {
  final DashboardRepository repository;

  GetDashboardInsights(this.repository);

  Future<Map<String, dynamic>> call(String appId) async {
    final summary = await repository.getSummary(appId);
    final analysis = await repository.analyze(appId);

    return {'summary': summary, 'analysis': analysis};
  }
}
