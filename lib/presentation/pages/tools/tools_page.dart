import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/core/constants/app_constants.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/extensions/context_extensions.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/presentation/blocs/tool/tool_bloc.dart';
import 'package:power_tool_tracking/presentation/routes/route_names.dart';
import 'package:power_tool_tracking/presentation/widgets/common/empty_state_view.dart';
import 'package:power_tool_tracking/presentation/widgets/tool_card.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ToolBloc>(
        create: (_) => sl<ToolBloc>()..add(const ToolLoadRequested()),
        child: const _ToolsView(),
      );
}

class _ToolsView extends StatelessWidget {
  const _ToolsView();

  @override
  Widget build(BuildContext context) => BlocListener<ToolBloc, ToolState>(
        listener: (context, state) {
          if (state.actionStatus == 'error' && state.actionErrorMessage != null) {
            context.showErrorSnackBar(state.actionErrorMessage!);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Power Tools'),
            actions: [
              BlocBuilder<ToolBloc, ToolState>(
                builder: (context, state) => state.isSyncing
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () =>
                            context.read<ToolBloc>().add(const ToolSyncRequested()),
                        tooltip: 'Sync',
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(context),
                tooltip: 'Filter',
              ),
            ],
          ),
          body: Column(
            children: [
              _SearchBar(),
              _StatsRow(),
              const Expanded(child: _ToolList()),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(RouteNames.addTool),
            icon: const Icon(Icons.add),
            label: const Text('Add Tool'),
          ),
        ),
      );

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ToolBloc>(),
        child: const _FilterSheet(),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search tools, serial no., asset tag...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: BlocBuilder<ToolBloc, ToolState>(
              buildWhen: (p, c) => p.searchQuery != c.searchQuery,
              builder: (context, state) => state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          context.read<ToolBloc>().add(const ToolSearchChanged(query: '')),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          onChanged: (query) =>
              context.read<ToolBloc>().add(ToolSearchChanged(query: query)),
        ),
      );
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ToolBloc, ToolState>(
        buildWhen: (p, c) => p.tools != c.tools,
        builder: (context, state) => SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _StatChip(
                label: 'Total',
                count: state.tools.length,
                color: AppColors.primary,
                icon: Icons.construction,
              ),
              _StatChip(
                label: 'Available',
                count: state.availableCount,
                color: AppColors.statusAvailable,
                icon: Icons.check_circle,
              ),
              _StatChip(
                label: 'Checked Out',
                count: state.checkedOutCount,
                color: AppColors.statusCheckedOut,
                icon: Icons.output,
              ),
              _StatChip(
                label: 'Maintenance',
                count: state.maintenanceCount,
                color: AppColors.statusMaintenance,
                icon: Icons.build,
              ),
              if (state.maintenanceDueCount > 0)
                _StatChip(
                  label: 'Due Soon',
                  count: state.maintenanceDueCount,
                  color: AppColors.warning,
                  icon: Icons.warning_amber,
                ),
            ],
          ),
        ),
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _ToolList extends StatelessWidget {
  const _ToolList();

  @override
  Widget build(BuildContext context) => BlocBuilder<ToolBloc, ToolState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load tools'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ToolBloc>().add(const ToolLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.isEmpty) {
            return const EmptyStateView(
              icon: Icons.construction_outlined,
              title: 'No Tools Found',
              message: 'Add your first power tool to get started',
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ToolBloc>().add(const ToolRefreshRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredTools.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tool = state.filteredTools[index];
                return ToolCard(
                  tool: tool,
                  onTap: () => context.push('/home/tools/${tool.id}'),
                  onCheckout: tool.isAvailable
                      ? () => _showCheckoutDialog(context, tool)
                      : null,
                  onCheckin: tool.isCheckedOut
                      ? () => _showCheckinDialog(context, tool)
                      : null,
                );
              },
            ),
          );
        },
      );

  void _showCheckoutDialog(BuildContext context, ToolEntity tool) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Checkout: ${tool.name}'),
        content: const Text('Checkout functionality — implement worker/project picker here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ToolBloc>().add(
                    ToolCheckoutRequested(
                      params: CheckoutParams(
                        toolId: tool.id,
                        workerId: 'worker-id',
                        workerName: 'Worker Name',
                      ),
                    ),
                  );
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }

  void _showCheckinDialog(BuildContext context, ToolEntity tool) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Check-in: ${tool.name}'),
        content: const Text('Return tool to inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ToolBloc>().add(
                    ToolCheckinRequested(
                      params: CheckinParams(
                        toolId: tool.id,
                        condition: ToolCondition.good,
                      ),
                    ),
                  );
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Tools',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      context.read<ToolBloc>().add(const ToolFilterChanged());
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ToolStatus.values
                  .map((status) => BlocBuilder<ToolBloc, ToolState>(
                        builder: (context, state) => FilterChip(
                          label: Text(status.displayName),
                          selected: state.filter?.status == status,
                          onSelected: (selected) {
                            context.read<ToolBloc>().add(
                                  ToolFilterChanged(
                                    filter: selected
                                        ? ToolFilter(status: status)
                                        : null,
                                  ),
                                );
                          },
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.toolCategories.length,
                itemBuilder: (context, index) {
                  final category = AppConstants.toolCategories[index];
                  return BlocBuilder<ToolBloc, ToolState>(
                    builder: (context, state) => CheckboxListTile(
                      title: Text(category),
                      value: state.filter?.category == category,
                      onChanged: (selected) {
                        context.read<ToolBloc>().add(
                              ToolFilterChanged(
                                filter: selected == true
                                    ? ToolFilter(category: category)
                                    : null,
                              ),
                            );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      );
}
