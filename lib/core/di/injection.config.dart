// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ai_performance_intelligence_platform/core/network/auth_inteceptor.dart'
    as _i392;
import 'package:ai_performance_intelligence_platform/core/network/dio_client.dart'
    as _i544;
import 'package:ai_performance_intelligence_platform/core/network/dio_module.dart'
    as _i885;
import 'package:ai_performance_intelligence_platform/core/storage/token_storage.dart'
    as _i93;
import 'package:ai_performance_intelligence_platform/features/apps/data/datasoources/app_local_datasource.dart'
    as _i140;
import 'package:ai_performance_intelligence_platform/features/apps/data/datasoources/app_remote_datasource.dart'
    as _i683;
import 'package:ai_performance_intelligence_platform/features/apps/data/repositories/app_repository_impl.dart'
    as _i139;
import 'package:ai_performance_intelligence_platform/features/apps/domain/repostiories/app_repository.dart'
    as _i524;
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/create_app_usecase.dart'
    as _i807;
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/get_apps_usecase.dart'
    as _i143;
import 'package:ai_performance_intelligence_platform/features/apps/presentation/bloc/apps_bloc.dart'
    as _i760;
import 'package:ai_performance_intelligence_platform/features/auth/data/datasource/auth_remote_datasource.dart'
    as _i214;
import 'package:ai_performance_intelligence_platform/features/auth/data/repository/auth_respository_impl.dart'
    as _i107;
import 'package:ai_performance_intelligence_platform/features/auth/domain/repository/auth_repository.dart'
    as _i54;
import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/login_usecase.dart'
    as _i811;
import 'package:ai_performance_intelligence_platform/features/auth/domain/usecases/signup_usecase.dart'
    as _i345;
import 'package:ai_performance_intelligence_platform/features/auth/presentation/bloc/auth_bloc.dart'
    as _i146;
import 'package:ai_performance_intelligence_platform/features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i861;
import 'package:ai_performance_intelligence_platform/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i1052;
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i766;
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/usecases/dashboard_usecases.dart'
    as _i243;
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i613;
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
    gh.lazySingleton<_i93.TokenStorage>(() => _i93.TokenStorage());
    gh.lazySingleton<_i140.AppsLocalDataSource>(
      () => _i140.AppsLocalDataSource(),
    );
    gh.lazySingleton<_i392.AuthInteceptor>(
      () => _i392.AuthInteceptor(gh<_i93.TokenStorage>()),
    );
    gh.lazySingleton<_i544.DioClient>(
      () => _i544.DioClient(gh<_i392.AuthInteceptor>()),
    );
    gh.lazySingleton<_i861.DashboardRemoteDataSource>(
      () => _i861.DashboardRemoteDataSourceImpl(gh<_i544.DioClient>()),
    );
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio(gh<_i544.DioClient>()));
    gh.lazySingleton<_i683.AppsRemoteDataSource>(
      () => _i683.AppsRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i214.AuthRemoteDataSource>(
      () => _i214.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i766.DashboardRepository>(
      () =>
          _i1052.DashboardRepositoryImpl(gh<_i861.DashboardRemoteDataSource>()),
    );
    gh.lazySingleton<_i524.AppsRepository>(
      () => _i139.AppsRepositoryImpl(gh<_i683.AppsRemoteDataSource>()),
    );
    gh.lazySingleton<_i54.AuthRepository>(
      () => _i107.AuthRepositoryImpl(gh<_i214.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i811.LoginUseCase>(
      () => _i811.LoginUseCase(gh<_i54.AuthRepository>()),
    );
    gh.lazySingleton<_i807.CreateAppUseCase>(
      () => _i807.CreateAppUseCase(gh<_i524.AppsRepository>()),
    );
    gh.lazySingleton<_i143.GetAppsUseCase>(
      () => _i143.GetAppsUseCase(gh<_i524.AppsRepository>()),
    );
    gh.lazySingleton<_i345.SignupUseCase>(
      () => _i345.SignupUseCase(gh<_i54.AuthRepository>()),
    );
    gh.factory<_i760.AppsBloc>(
      () => _i760.AppsBloc(
        gh<_i807.CreateAppUseCase>(),
        gh<_i143.GetAppsUseCase>(),
        gh<_i140.AppsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i243.GetDashboardInsights>(
      () => _i243.GetDashboardInsights(gh<_i766.DashboardRepository>()),
    );
    gh.factory<_i146.AuthBloc>(
      () => _i146.AuthBloc(
        gh<_i811.LoginUseCase>(),
        gh<_i345.SignupUseCase>(),
        gh<_i93.TokenStorage>(),
      ),
    );
    gh.factory<_i613.DashboardBloc>(
      () => _i613.DashboardBloc(
        gh<_i243.GetDashboardInsights>(),
        gh<_i143.GetAppsUseCase>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i885.DioModule {}
