import 'package:ai_performance_intelligence_platform/core/constants/api_constants.dart';
import 'package:ai_performance_intelligence_platform/core/network/auth_inteceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DioClient {
  final Dio dio;

  DioClient(AuthInteceptor authInteceptor)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(authInteceptor);
  }
}
