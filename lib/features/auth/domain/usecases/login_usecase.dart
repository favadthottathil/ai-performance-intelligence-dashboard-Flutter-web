import 'package:ai_performance_intelligence_platform/features/auth/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<String> call(String email, String password) {
    return repository.login(email, password);
  }
}
