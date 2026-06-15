import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/receive_tool_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/tools_to_receive_page.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});

  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ReceiveToolBloc>();
    if (bloc.state is ReceiveToolInitial) {
      bloc.add(const ReceiveToolListLoadRequested());
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
            'Project Store Incharge',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<ReceiveToolBloc, ReceiveToolState>(
          builder: (context, state) {
            final count =
                state is ReceiveToolListLoaded ? state.items.length : null;
            return Padding(
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
                  _ActionCard(
                    icon: Icons.move_to_inbox_rounded,
                    title: 'Receive Tool',
                    subtitle: 'Accept returned tools from site',
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
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.history_rounded,
                    title: 'Tool History',
                    subtitle: 'View past movements and transactions',
                    backgroundColor: Colors.white,
                    iconBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    iconColor: AppColors.primary,
                    titleColor: AppColors.textPrimary,
                    subtitleColor: AppColors.textSecondary,
                    onTap: () {},
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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