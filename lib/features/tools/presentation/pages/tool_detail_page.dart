import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/extensions/context_extensions.dart';
import 'package:power_tool_tracking/core/extensions/date_time_extensions.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/usecases/get_tool_by_id_usecase.dart';
import 'package:power_tool_tracking/features/tools/presentation/blocs/tool_bloc.dart';
import 'package:power_tool_tracking/presentation/widgets/status_badge.dart';

class ToolDetailPage extends StatefulWidget {
  const ToolDetailPage({super.key, required this.toolId});

  final String toolId;

  @override
  State<ToolDetailPage> createState() => _ToolDetailPageState();
}

class _ToolDetailPageState extends State<ToolDetailPage> {
  ToolEntity? _tool;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTool();
  }

  Future<void> _loadTool() async {
    final useCase = sl<GetToolByIdUseCase>();
    final result = await useCase(widget.toolId);
    if (mounted) {
      result.fold(
        onSuccess: (tool) => setState(() {
          _tool = tool;
          _isLoading = false;
        }),
        onFailure: (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _tool == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Tool not found')),
      );
    }

    final tool = _tool!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tool.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/home/tools/${tool.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, tool),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context, tool),
            const SizedBox(height: 16),
            _buildDetailsCard(context, tool),
            const SizedBox(height: 16),
            if (tool.isCheckedOut) _buildAssignmentCard(context, tool),
            const SizedBox(height: 16),
            _buildMaintenanceCard(context, tool),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBar(context, tool),
    );
  }

  Widget _buildHeroCard(BuildContext context, ToolEntity tool) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tool.brand} ${tool.name}',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.model,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(status: tool.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildDetailsCard(BuildContext context, ToolEntity tool) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tool Details', style: context.textTheme.titleMedium),
              const Divider(height: 24),
              _DetailRow(label: 'Serial Number', value: tool.serialNumber),
              _DetailRow(label: 'Asset Tag', value: tool.assetTag ?? '—'),
              _DetailRow(label: 'Category', value: tool.category),
              _DetailRow(label: 'Condition', value: tool.condition.displayName),
              _DetailRow(label: 'Location', value: tool.location ?? '—'),
              if (tool.purchaseDate != null)
                _DetailRow(
                  label: 'Purchase Date',
                  value: tool.purchaseDate!.toDisplayDate,
                ),
              if (tool.purchaseCost != null)
                _DetailRow(
                  label: 'Purchase Cost',
                  value: '\$${tool.purchaseCost!.toStringAsFixed(2)}',
                ),
              if (tool.warrantyExpiry != null)
                _DetailRow(
                  label: 'Warranty Expires',
                  value: tool.warrantyExpiry!.toDisplayDate,
                  valueColor: tool.isWarrantyExpired ? AppColors.error : null,
                ),
              if (tool.notes != null && tool.notes!.isNotEmpty)
                _DetailRow(label: 'Notes', value: tool.notes!),
              if (!tool.isSynced)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 16, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text('Pending sync', style: TextStyle(color: AppColors.warning)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildAssignmentCard(BuildContext context, ToolEntity tool) => Card(
        color: AppColors.statusCheckedOut.withValues(alpha:0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.statusCheckedOut),
                  const SizedBox(width: 8),
                  Text(
                    'Currently Assigned',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.statusCheckedOut,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _DetailRow(label: 'Assigned To', value: tool.assignedWorkerName ?? '—'),
              if (tool.assignedProjectName != null)
                _DetailRow(label: 'Project', value: tool.assignedProjectName!),
              if (tool.checkedOutAt != null)
                _DetailRow(
                  label: 'Checked Out',
                  value: tool.checkedOutAt!.relativeTime,
                ),
            ],
          ),
        ),
      );

  Widget _buildMaintenanceCard(BuildContext context, ToolEntity tool) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    color: tool.isMaintenanceOverdue
                        ? AppColors.error
                        : tool.isMaintenanceDue
                            ? AppColors.warning
                            : AppColors.grey600,
                  ),
                  const SizedBox(width: 8),
                  Text('Maintenance', style: context.textTheme.titleMedium),
                ],
              ),
              const Divider(height: 24),
              if (tool.lastMaintenanceDate != null)
                _DetailRow(
                  label: 'Last Maintenance',
                  value: tool.lastMaintenanceDate!.toDisplayDate,
                ),
              if (tool.nextMaintenanceDue != null)
                _DetailRow(
                  label: 'Next Due',
                  value: tool.nextMaintenanceDue!.toDisplayDate,
                  valueColor: tool.isMaintenanceOverdue
                      ? AppColors.error
                      : tool.isMaintenanceDue
                          ? AppColors.warning
                          : null,
                ),
              if (tool.isMaintenanceOverdue)
                const _AlertBanner(
                  message: 'Maintenance overdue! Please schedule immediately.',
                  color: AppColors.error,
                  icon: Icons.error_outline,
                ),
              if (tool.isMaintenanceDue && !tool.isMaintenanceOverdue)
                const _AlertBanner(
                  message: 'Maintenance due within 7 days.',
                  color: AppColors.warning,
                  icon: Icons.warning_amber_outlined,
                ),
            ],
          ),
        ),
      );

  Widget _buildActionBar(BuildContext context, ToolEntity tool) =>
      BlocProvider<ToolBloc>(
        create: (_) => sl<ToolBloc>(),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (tool.isAvailable)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.output),
                    label: const Text('Check Out'),
                  ),
                ),
              if (tool.isCheckedOut)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.input),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              if (tool.isAvailable || tool.isCheckedOut) const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.build_outlined),
                label: const Text('Maintenance'),
              ),
            ],
          ),
        ),
      );

  Future<void> _confirmDelete(BuildContext context, ToolEntity tool) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Tool',
      message: 'Are you sure you want to delete "${tool.name}"? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      // Handled via ToolBloc
      context.pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: context.textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      );
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13))),
          ],
        ),
      );
}
