import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'dio_client.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(DioClient client) => client.dio;
}
