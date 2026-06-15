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
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(authInteceptor);
  }
}
