import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';

class RfidBottomActionBar extends StatelessWidget {
  const RfidBottomActionBar({
    super.key,
    required this.state,
    required this.newTagCount,
    required this.minTags,
    required this.showDoneButton,
    required this.onScanToggle,
    required this.onDone,
  });

  final RfidState state;
  final int newTagCount;
  final int minTags;
  final bool showDoneButton;
  final VoidCallback onScanToggle;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final canToggle = state.isReady;
    final canDone = showDoneButton && newTagCount >= minTags && !state.isScanning;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: canToggle ? onScanToggle : null,
              style: FilledButton.styleFrom(
                backgroundColor: state.isScanning ? AppColors.error : AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                state.isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
              label: Text(
                state.isScanning ? 'Stop Scan' : 'Start Scan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (showDoneButton) ...[
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: canDone ? onDone : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: canDone ? AppColors.primary : AppColors.grey300,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  'Done ($newTagCount)',
                  style: TextStyle(
                    color: canDone ? AppColors.primary : AppColors.grey400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
