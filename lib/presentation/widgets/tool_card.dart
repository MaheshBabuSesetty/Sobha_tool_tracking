import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/extensions/date_time_extensions.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/presentation/widgets/status_badge.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
    this.onTap,
    this.onCheckout,
    this.onCheckin,
  });

  final ToolEntity tool;
  final VoidCallback? onTap;
  final VoidCallback? onCheckout;
  final VoidCallback? onCheckin;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ToolIcon(category: tool.category),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tool.brand} ${tool.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tool.model,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: tool.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.tag,
                      label: tool.serialNumber,
                    ),
                    const SizedBox(width: 8),
                    if (tool.category.isNotEmpty)
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: tool.category,
                      ),
                  ],
                ),
                if (tool.isCheckedOut && tool.assignedWorkerName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusCheckedOut.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.statusCheckedOut,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tool.assignedWorkerName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.statusCheckedOut,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (tool.checkedOutAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${tool.checkedOutAt!.relativeTime}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.statusCheckedOut.withValues(alpha:0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (tool.isMaintenanceDue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (tool.isMaintenanceOverdue ? AppColors.error : AppColors.warning)
                          .withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 14,
                          color: tool.isMaintenanceOverdue
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tool.isMaintenanceOverdue
                              ? 'Maintenance overdue'
                              : 'Maintenance due ${tool.nextMaintenanceDue!.relativeTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: tool.isMaintenanceOverdue
                                ? AppColors.error
                                : AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (onCheckout != null || onCheckin != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onCheckout != null)
                        TextButton.icon(
                          onPressed: onCheckout,
                          icon: const Icon(Icons.output, size: 16),
                          label: const Text('Check Out'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.statusCheckedOut,
                          ),
                        ),
                      if (onCheckin != null)
                        TextButton.icon(
                          onPressed: onCheckin,
                          icon: const Icon(Icons.input, size: 16),
                          label: const Text('Check In'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.statusAvailable,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.category});

  final String category;

  IconData get _icon {
    return switch (category.toLowerCase()) {
      'drill' => Icons.hardware,
      'circular saw' || 'jigsaw' => Icons.handyman,
      'grinder' => Icons.settings,
      'welding equipment' => Icons.electric_bolt,
      'generator' || 'compressor' => Icons.power,
      'laser level' || 'measuring tool' => Icons.straighten,
      _ => Icons.construction,
    };
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon, size: 24, color: AppColors.primary),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.grey500),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
        ],
      );
}
