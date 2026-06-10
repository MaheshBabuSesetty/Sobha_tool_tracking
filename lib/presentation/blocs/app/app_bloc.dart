import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppInitialized>(_onInitialized);
  }

  Future<void> _onInitialized(AppInitialized event, Emitter<AppState> emit) async {
    emit(state.copyWith(isInitialized: true));
  }
}
