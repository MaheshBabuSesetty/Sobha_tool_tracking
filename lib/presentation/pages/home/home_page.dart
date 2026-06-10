import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/presentation/routes/route_names.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.construction_outlined),
            selectedIcon: Icon(Icons.construction),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(RouteNames.assignments)) return 1;
    if (location.startsWith(RouteNames.maintenance)) return 2;
    if (location.startsWith(RouteNames.reports)) return 3;
    if (location.startsWith(RouteNames.settings)) return 4;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final destinations = [
      RouteNames.tools,
      RouteNames.assignments,
      RouteNames.maintenance,
      RouteNames.reports,
      RouteNames.settings,
    ];
    context.go(destinations[index]);
  }
}
