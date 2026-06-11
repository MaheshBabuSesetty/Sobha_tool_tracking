part of 'tool_bloc.dart';

sealed class ToolEvent extends Equatable {
  const ToolEvent();

  @override
  List<Object?> get props => [];
}

final class ToolLoadRequested extends ToolEvent {
  const ToolLoadRequested({this.filter});
  final ToolFilter? filter;

  @override
  List<Object?> get props => [filter];
}

final class ToolRefreshRequested extends ToolEvent {
  const ToolRefreshRequested();
}

final class ToolSearchChanged extends ToolEvent {
  const ToolSearchChanged({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}

final class ToolFilterChanged extends ToolEvent {
  const ToolFilterChanged({this.filter});
  final ToolFilter? filter;

  @override
  List<Object?> get props => [filter];
}

final class ToolCreateRequested extends ToolEvent {
  const ToolCreateRequested({required this.tool});
  final ToolEntity tool;

  @override
  List<Object> get props => [tool];
}

final class ToolUpdateRequested extends ToolEvent {
  const ToolUpdateRequested({required this.tool});
  final ToolEntity tool;

  @override
  List<Object> get props => [tool];
}

final class ToolDeleteRequested extends ToolEvent {
  const ToolDeleteRequested({required this.toolId});
  final String toolId;

  @override
  List<Object> get props => [toolId];
}

final class ToolCheckoutRequested extends ToolEvent {
  const ToolCheckoutRequested({required this.params});
  final CheckoutParams params;

  @override
  List<Object> get props => [params];
}

final class ToolCheckinRequested extends ToolEvent {
  const ToolCheckinRequested({required this.params});
  final CheckinParams params;

  @override
  List<Object> get props => [params];
}

final class ToolSyncRequested extends ToolEvent {
  const ToolSyncRequested();
}
