import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_app_usecase.dart';
import '../../data/datasoources/app_local_datasource.dart';
import '../../domain/usecases/get_apps_usecase.dart';
import '../../domain/usecases/rotate_api_key_usecase.dart';
import 'apps_event.dart';
import 'apps_state.dart';

@injectable
class AppsBloc extends Bloc<AppsEvent, AppsState> {
  final CreateAppUseCase createApp;
  final GetAppsUseCase getApps;
  final RotateApiKeyUseCase rotateApiKey;
  final AppsLocalDataSource localDataSource;

  AppsBloc(
    this.createApp,
    this.getApps,
    this.rotateApiKey,
    this.localDataSource,
  ) : super(AppsInitial()) {
    on<CreateAppRequested>(_onCreateApp);
    on<RotateApiKeyRequested>(_onRotateApiKey);
    on<LoadApps>(_onLoadApps);
  }

  Future<void> _onLoadApps(LoadApps event, Emitter<AppsState> emit) async {
    emit(AppsLoading());
    try {
      emit(AppsLoaded(await getApps()));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }

  Future<void> _onCreateApp(
    CreateAppRequested event,
    Emitter<AppsState> emit,
  ) async {
    emit(AppsLoading());
    try {
      final app = await createApp(event.name);
      await localDataSource.saveApp(app);

      // Surface the new key first, then refresh the list. Emitting the list
      // last leaves the UI in a consistent loaded state.
      emit(AppCreated(app));
      emit(AppsLoaded(await getApps()));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }

  Future<void> _onRotateApiKey(
    RotateApiKeyRequested event,
    Emitter<AppsState> emit,
  ) async {
    emit(AppsLoading());
    try {
      final app = await rotateApiKey(event.appId);

      emit(ApiKeyRotated(app));
      emit(AppsLoaded(await getApps()));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }
}
