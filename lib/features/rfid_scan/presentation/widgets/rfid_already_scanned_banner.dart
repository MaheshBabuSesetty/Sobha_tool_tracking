import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';

class RfidAlreadyScannedBanner extends StatelessWidget {
  const RfidAlreadyScannedBanner({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.primaryContainer,
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(
              '$count tag${count == 1 ? '' : 's'} already scanned — will be skipped',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
