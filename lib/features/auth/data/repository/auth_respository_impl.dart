import 'package:ai_performance_intelligence_platform/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:ai_performance_intelligence_platform/features/auth/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<String> login(String email, String password) {
    return remote.login(email: email, password: password);
  }

  @override
  Future<String> signup(String email, String password) {
    return remote.signup(email: email, password: password);
  }
}
