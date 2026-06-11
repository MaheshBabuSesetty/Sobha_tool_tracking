import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ToolStatus status;

  Color get _backgroundColor => switch (status) {
        ToolStatus.available => AppColors.statusAvailable.withValues(alpha:0.1),
        ToolStatus.checkedOut => AppColors.statusCheckedOut.withValues(alpha:0.1),
        ToolStatus.inMaintenance => AppColors.statusMaintenance.withValues(alpha:0.1),
        ToolStatus.retired => AppColors.statusRetired.withValues(alpha:0.1),
        ToolStatus.lost => AppColors.statusLost.withValues(alpha:0.1),
      };

  Color get _textColor => switch (status) {
        ToolStatus.available => AppColors.statusAvailable,
        ToolStatus.checkedOut => AppColors.statusCheckedOut,
        ToolStatus.inMaintenance => AppColors.statusMaintenance,
        ToolStatus.retired => AppColors.statusRetired,
        ToolStatus.lost => AppColors.statusLost,
      };

  IconData get _icon => switch (status) {
        ToolStatus.available => Icons.check_circle_outline,
        ToolStatus.checkedOut => Icons.output,
        ToolStatus.inMaintenance => Icons.build_circle_outlined,
        ToolStatus.retired => Icons.archive_outlined,
        ToolStatus.lost => Icons.search_off,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 13, color: _textColor),
            const SizedBox(width: 5),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
          ],
        ),
      );
}
