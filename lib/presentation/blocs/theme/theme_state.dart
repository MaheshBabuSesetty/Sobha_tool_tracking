part of 'theme_bloc.dart';

final class ThemeState extends Equatable {
  const ThemeState({required this.themeMode});
  final ThemeMode themeMode;

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  List<Object> get props => [themeMode];
}
