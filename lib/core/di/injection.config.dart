// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ai_performance_intelligence_platform/core/network/auth_inteceptor.dart'
    as _i179;
import 'package:ai_performance_intelligence_platform/core/network/dio_client.dart'
    as _i783;
import 'package:ai_performance_intelligence_platform/core/network/dio_module.dart'
    as _i704;
import 'package:ai_performance_intelligence_platform/core/storage/token_storage.dart'
    as _i17;
import 'package:ai_performance_intelligence_platform/features/apps/data/datasoources/app_local_datasource.dart'
    as _i302;
import 'package:ai_performance_intelligence_platform/features/apps/data/datasoources/app_remote_datasource.dart'
    as _i688;
import 'package:ai_performance_intelligence_platform/features/apps/data/repositories/app_repository_impl.dart'
    as _i937;
import 'package:ai_performance_intelligence_platform/features/apps/domain/repostiories/app_repository.dart'
    as _i417;
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/create_app_usecase.dart'
    as _i803;
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/get_apps_usecase.dart'
    as _i906;
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/rotate_api_key_usecase.dart'
    as _i16;
import 'package:ai_performance_intelligence_platform/features/apps/presentation/bloc/apps_bloc.dart'
    as _i92;
import 'package:ai_performance_intelligence_platform/features/auth/data/datasource/auth_remote_datasource.dart'
    as _i153;
import 'package:ai_performance_intelligence_platform/features/auth/data/repository/auth_respository_impl.dart'
    as _i184;
import 'package:ai_performance_intelligence_platform/features/auth/domain/repository/auth_repository.dart'
    as _i226;
import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/login_usecase.dart'
    as _i310;
import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/signup_usecase.dart'
    as _i257;
import 'package:ai_performance_intelligence_platform/features/auth/presentation/bloc/auth_bloc.dart'
    as _i697;
import 'package:ai_performance_intelligence_platform/features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i246;
import 'package:ai_performance_intelligence_platform/features/dashboard/data/datasources/metrics_stream_datasource.dart'
    as _i102;
import 'package:ai_performance_intelligence_platform/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i861;
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i792;
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/usecases/dashboard_usecases.dart'
    as _i25;
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i677;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.lazySingleton<_i17.TokenStorage>(() => _i17.TokenStorage());
    gh.lazySingleton<_i302.AppsLocalDataSource>(
      () => _i302.AppsLocalDataSource(),
    );
    gh.lazySingleton<_i179.AuthInteceptor>(
      () => _i179.AuthInteceptor(gh<_i17.TokenStorage>()),
    );
    gh.lazySingleton<_i783.DioClient>(
      () => _i783.DioClient(gh<_i179.AuthInteceptor>()),
    );
    gh.lazySingleton<_i246.DashboardRemoteDataSource>(
      () => _i246.DashboardRemoteDataSourceImpl(gh<_i783.DioClient>()),
    );
    gh.lazySingleton<_i102.MetricsStreamDataSource>(
      () => _i102.MetricsStreamDataSourceImpl(gh<_i783.DioClient>()),
    );
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio(gh<_i783.DioClient>()));
    gh.lazySingleton<_i792.DashboardRepository>(
      () => _i861.DashboardRepositoryImpl(
        gh<_i246.DashboardRemoteDataSource>(),
        gh<_i102.MetricsStreamDataSource>(),
      ),
    );
    gh.lazySingleton<_i25.GetDashboardInsights>(
      () => _i25.GetDashboardInsights(gh<_i792.DashboardRepository>()),
    );
    gh.lazySingleton<_i25.WatchMetrics>(
      () => _i25.WatchMetrics(gh<_i792.DashboardRepository>()),
    );
    gh.lazySingleton<_i688.AppsRemoteDataSource>(
      () => _i688.AppsRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i153.AuthRemoteDataSource>(
      () => _i153.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i417.AppsRepository>(
      () => _i937.AppsRepositoryImpl(gh<_i688.AppsRemoteDataSource>()),
    );
    gh.lazySingleton<_i226.AuthRepository>(
      () => _i184.AuthRepositoryImpl(gh<_i153.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i803.CreateAppUseCase>(
      () => _i803.CreateAppUseCase(gh<_i417.AppsRepository>()),
    );
    gh.lazySingleton<_i906.GetAppsUseCase>(
      () => _i906.GetAppsUseCase(gh<_i417.AppsRepository>()),
    );
    gh.lazySingleton<_i16.RotateApiKeyUseCase>(
      () => _i16.RotateApiKeyUseCase(gh<_i417.AppsRepository>()),
    );
    gh.factory<_i92.AppsBloc>(
      () => _i92.AppsBloc(
        gh<_i803.CreateAppUseCase>(),
        gh<_i906.GetAppsUseCase>(),
        gh<_i16.RotateApiKeyUseCase>(),
        gh<_i302.AppsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i257.SignupUseCase>(
      () => _i257.SignupUseCase(gh<_i226.AuthRepository>()),
    );
    gh.lazySingleton<_i310.LoginUseCase>(
      () => _i310.LoginUseCase(gh<_i226.AuthRepository>()),
    );
    gh.factory<_i697.AuthBloc>(
      () => _i697.AuthBloc(
        gh<_i310.LoginUseCase>(),
        gh<_i257.SignupUseCase>(),
        gh<_i17.TokenStorage>(),
      ),
    );
    gh.factory<_i677.DashboardBloc>(
      () => _i677.DashboardBloc(
        gh<_i25.GetDashboardInsights>(),
        gh<_i906.GetAppsUseCase>(),
        gh<_i25.WatchMetrics>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i704.DioModule {}
