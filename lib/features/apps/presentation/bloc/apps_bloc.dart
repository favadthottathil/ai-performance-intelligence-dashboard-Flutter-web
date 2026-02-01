import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_app_usecase.dart';
import '../../data/datasoources/app_local_datasource.dart';
import '../../domain/usecases/get_apps_usecase.dart';
import 'apps_event.dart';
import 'apps_state.dart';

@injectable
class AppsBloc extends Bloc<AppsEvent, AppsState> {
  final CreateAppUseCase createApp;
  final GetAppsUseCase getApps;
  final AppsLocalDataSource localDataSource;

  AppsBloc(this.createApp, this.getApps, this.localDataSource)
    : super(AppsInitial()) {
    on<CreateAppRequested>(_onCreateApp);
    on<LoadApps>(_onLoadApps);
  }

  Future<void> _onLoadApps(LoadApps event, Emitter<AppsState> emit) async {
    emit(AppsLoading());
    try {
      final apps = await getApps();
      emit(AppsLoaded(apps));
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
      // Save the app locally
      await localDataSource.saveApp(app);

      // Reload apps to refresh the list with the new one content
      add(LoadApps());

      emit(AppCreated(app));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }
}
