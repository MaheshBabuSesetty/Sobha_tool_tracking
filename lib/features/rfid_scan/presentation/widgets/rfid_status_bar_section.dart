import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';

class RfidStatusBarSection extends StatelessWidget {
  const RfidStatusBarSection({
    super.key,
    required this.state,
    required this.newTagCount,
  });

  final RfidState state;
  final int newTagCount;

  Color _stateColor() => switch (state.connectionState) {
        RfidConnectionState.connected => AppColors.success,
        RfidConnectionState.connecting => AppColors.warning,
        RfidConnectionState.failed || RfidConnectionState.disconnected => AppColors.error,
        RfidConnectionState.idle => AppColors.grey400,
      };

  String _stateLabel() => switch (state.connectionState) {
        RfidConnectionState.connected => state.isScanning ? 'Scanning' : 'Ready',
        RfidConnectionState.connecting => 'Connecting…',
        RfidConnectionState.failed => 'Failed',
        RfidConnectionState.disconnected => 'Disconnected',
        RfidConnectionState.idle => 'Idle',
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: _stateColor(), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              _stateLabel(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _stateColor(),
              ),
            ),
            const Spacer(),
            if (newTagCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$newTagCount tag${newTagCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              '${(state.currentPower / 100).toStringAsFixed(1)} dBm',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}
