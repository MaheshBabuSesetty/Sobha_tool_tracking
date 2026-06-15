import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/receive_tool_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/tools_to_receive_page.dart';
import 'package:power_tool_tracking/presentation/routes/route_names.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserEntity? _user;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _user = authState.user;
    }
    if (_user?.isProjectStore ?? false) {
      final bloc = context.read<ReceiveToolBloc>();
      if (bloc.state is ReceiveToolInitial) {
        bloc.add(const ReceiveToolListLoadRequested());
      }
    } else {
      final bloc = context.read<PmBloc>();
      if (bloc.state is PmInitial) {
        bloc.add(const PmRequestsLoadRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBackground,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Tool Tracker',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_user?.isProjectStore ?? false) ...[
                // ── Project Store Incharge cards ──────────────────────────
                BlocBuilder<ReceiveToolBloc, ReceiveToolState>(
                  builder: (context, state) {
                    final count = state is ReceiveToolListLoaded
                        ? state.items.length
                        : null;
                    return _ActionCard(
                      title: 'Receive Tool',
                      subtitle: 'Accept returned tools from site',
                      icon: Icons.move_to_inbox_rounded,
                      backgroundColor: AppColors.primary,
                      iconBackgroundColor: Colors.white.withValues(alpha: 0.25),
                      iconColor: Colors.white,
                      titleColor: Colors.white,
                      subtitleColor: Colors.white.withValues(alpha: 0.85),
                      badge: (count != null && count > 0) ? count : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ReceiveToolBloc>(),
                            child: const ToolsToReceivePage(),
                          ),
                        ),
                      ).then((_) {
                        if (!context.mounted) {
                          return;
                        }
                        context
                            .read<ReceiveToolBloc>()
                            .add(const ReceiveToolListLoadRequested());
                      }),
                    );
                  },
                ),
              ] else ...[
                // ── PM Store Incharge cards ───────────────────────────────
                BlocBuilder<PmBloc, PmState>(
                  buildWhen: (_, curr) =>
                      curr is PmRequestsLoaded || curr is PmLoading,
                  builder: (context, state) {
                    final pendingCount = state is PmRequestsLoaded
                        ? state.requests.where((r) => r.isActionable).length
                        : null;
                    return _ActionCard(
                      title: 'Issue Tool',
                      subtitle: 'Issue tools requested by sites',
                      icon: Icons.view_in_ar_rounded,
                      backgroundColor: AppColors.primary,
                      iconBackgroundColor:
                          Colors.white.withValues(alpha: 0.25),
                      iconColor: Colors.white,
                      titleColor: Colors.white,
                      subtitleColor: Colors.white.withValues(alpha: 0.85),
                      badge: (pendingCount != null && pendingCount > 0)
                          ? pendingCount
                          : null,
                      onTap: () => context.push(RouteNames.issueTool),
                    );
                  },
                ),
              ],
              const SizedBox(height: 14),
              _ActionCard(
                title: 'Tool History',
                subtitle: 'View tool transaction history',
                icon: Icons.history_rounded,
                backgroundColor: Colors.white,
                iconBackgroundColor: AppColors.primary.withValues(alpha: 0.12),
                iconColor: AppColors.primary,
                titleColor: AppColors.textPrimary,
                subtitleColor: AppColors.textSecondary,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) => Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
