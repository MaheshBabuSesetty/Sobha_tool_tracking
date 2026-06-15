import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:power_tool_tracking/features/auth/presentation/pages/login_page.dart';
import 'package:power_tool_tracking/features/auth/presentation/pages/splash_page.dart';
import 'package:power_tool_tracking/features/home/presentation/pages/dashboard_page.dart';
import 'package:power_tool_tracking/features/home/presentation/pages/home_page.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/issue_tool_page.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/request_detail_page.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/store_dashboard_page.dart';
import 'package:power_tool_tracking/features/profile/presentation/pages/profile_page.dart';
import 'package:power_tool_tracking/features/tools/presentation/pages/add_edit_tool_page.dart';
import 'package:power_tool_tracking/features/tools/presentation/pages/tool_detail_page.dart';
import 'package:power_tool_tracking/features/tools/presentation/pages/tools_page.dart';
import 'package:power_tool_tracking/presentation/routes/route_names.dart';

class AppRouter {
  AppRouter({required this.authBloc}) {
    _router = _buildRouter();
  }

  final AuthBloc authBloc;
  late final GoRouter _router;

  GoRouter get router => _router;

  GoRouter _buildRouter() => GoRouter(
        initialLocation: RouteNames.splash,
        debugLogDiagnostics: true,
        redirect: _redirect,
        routes: [
          GoRoute(
            path: RouteNames.splash,
            name: 'splash',
            builder: (_, __) => const SplashPage(),
          ),
          GoRoute(
            path: RouteNames.login,
            name: 'login',
            builder: (_, __) => const LoginPage(),
          ),
          ShellRoute(
            builder: (_, state, child) => HomePage(child: child),
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: 'dashboard',
                builder: (_, __) => const DashboardPage(),
              ),
              GoRoute(
                path: RouteNames.issueTool,
                name: 'issue-tool',
                builder: (_, __) => const IssueToolPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'issue-tool-detail',
                    pageBuilder: (_, state) => NoTransitionPage(
                      child: RequestDetailPage(
                        requestId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.tools,
                name: 'tools',
                builder: (_, __) => const ToolsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-tool',
                    builder: (_, __) => const AddEditToolPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'tool-detail',
                    builder: (context, state) => ToolDetailPage(
                      toolId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'edit-tool',
                        builder: (context, state) => AddEditToolPage(
                          toolId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.scan,
                name: 'scan',
                builder: (_, __) => const _PlaceholderPage(title: 'Scan'),
              ),
              GoRoute(
                path: RouteNames.storeDashboard,
                name: 'store-dashboard',
                builder: (_, __) => const StoreDashboardPage(),
              ),
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (_, __) => const ProfilePage(),
              ),
              GoRoute(
                path: RouteNames.assignments,
                name: 'assignments',
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Assignments'),
              ),
              GoRoute(
                path: RouteNames.maintenance,
                name: 'maintenance',
                builder: (_, __) =>
                    const _PlaceholderPage(title: 'Maintenance'),
              ),
              GoRoute(
                path: RouteNames.reports,
                name: 'reports',
                builder: (_, __) => const _PlaceholderPage(title: 'Reports'),
              ),
              GoRoute(
                path: RouteNames.settings,
                name: 'settings',
                builder: (_, __) => const _PlaceholderPage(title: 'Settings'),
              ),
            ],
          ),
        ],
        errorBuilder: (_, state) => _ErrorPage(error: state.error.toString()),
      );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isSplash = state.matchedLocation == RouteNames.splash;
    final isLogin = state.matchedLocation == RouteNames.login;

    if (isSplash) {
      return null;
    }
    if (!isAuthenticated && !isLogin) {
      return RouteNames.login;
    }
    if (isAuthenticated && isLogin) {
      return RouteNames.dashboard;
    }
    return null;
  }

  void dispose() {
    _router.dispose();
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — Coming Soon')),
      );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page not found', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.dashboard),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}
