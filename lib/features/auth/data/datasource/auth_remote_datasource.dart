import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return response.data['token'];
  }

  Future<String> signup({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );

    return response.data['token'];
  }
}
