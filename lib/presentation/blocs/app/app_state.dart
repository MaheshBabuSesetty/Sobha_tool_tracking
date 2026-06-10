part of 'app_bloc.dart';

final class AppState extends Equatable {
  const AppState({this.isInitialized = false});

  final bool isInitialized;

  AppState copyWith({bool? isInitialized}) =>
      AppState(isInitialized: isInitialized ?? this.isInitialized);

  @override
  List<Object> get props => [isInitialized];
}
