library;

import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';

class RfidStatusBar extends StatelessWidget {
  const RfidStatusBar({super.key, required this.state});

  final RfidState state;

  Color _stateColor() => switch (state.connectionState) {
        RfidConnectionState.connected => AppColors.success,
        RfidConnectionState.connecting => AppColors.warning,
        RfidConnectionState.failed || RfidConnectionState.disconnected => AppColors.error,
        RfidConnectionState.idle => AppColors.grey400,
      };

  String _stateLabel() => switch (state.connectionState) {
        RfidConnectionState.connected => state.isScanning ? 'Scanning' : 'Connected',
        RfidConnectionState.connecting => 'Connecting…',
        RfidConnectionState.failed => 'Failed',
        RfidConnectionState.disconnected => 'Disconnected',
        RfidConnectionState.idle => 'Idle',
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.sidebarBackground,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: _stateColor(), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              _stateLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _stateColor(),
              ),
            ),
            const Spacer(),
            Text(
              '${(state.currentPower / 100).toStringAsFixed(1)} dBm',
              style: const TextStyle(fontSize: 12, color: AppColors.sidebarInactiveText),
            ),
          ],
        ),
      );
}
