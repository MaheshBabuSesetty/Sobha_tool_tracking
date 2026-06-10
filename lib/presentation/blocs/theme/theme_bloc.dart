import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/storage/preference_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(themeMode: PreferenceService.themeMode)) {
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    await PreferenceService.setThemeMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }
}
