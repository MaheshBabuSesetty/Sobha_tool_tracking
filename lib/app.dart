import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/theme/app_theme.dart';
import 'package:power_tool_tracking/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/receive_tool_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/app/app_bloc.dart';
import 'package:power_tool_tracking/presentation/blocs/theme/theme_bloc.dart';
import 'package:power_tool_tracking/presentation/routes/app_router.dart';

class PowerToolTrackingApp extends StatefulWidget {
  const PowerToolTrackingApp({super.key});

  @override
  State<PowerToolTrackingApp> createState() => _PowerToolTrackingAppState();
}

class _PowerToolTrackingAppState extends State<PowerToolTrackingApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authBloc: sl<AuthBloc>());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AppBloc>(create: (_) => sl<AppBloc>()),
          BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
          BlocProvider<PmBloc>(create: (_) => sl<PmBloc>()),
          BlocProvider<ReceiveToolBloc>(create: (_) => sl<ReceiveToolBloc>()),
          BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) => MaterialApp.router(
            title: 'Power Tool Tracking',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            routerConfig: _appRouter.router,
          ),
        ),
      );
}
