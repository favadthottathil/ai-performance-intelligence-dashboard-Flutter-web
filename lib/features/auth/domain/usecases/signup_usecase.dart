import 'package:injectable/injectable.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  Future<String> call(String email, String password) {
    return _repository.signup(email, password);
  }
}
