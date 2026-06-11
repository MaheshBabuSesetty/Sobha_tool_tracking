library;

import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';

class RfidScanFab extends StatelessWidget {
  const RfidScanFab({
    super.key,
    required this.state,
    this.onStartScan,
    this.onStopScan,
  });

  final RfidState state;
  final VoidCallback? onStartScan;
  final VoidCallback? onStopScan;

  @override
  Widget build(BuildContext context) {
    final isConnecting = state.connectionState.isConnecting;

    if (isConnecting) {
      return const FloatingActionButton(
        onPressed: null,
        backgroundColor: AppColors.grey300,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.grey600),
        ),
      );
    }

    if (state.isScanning) {
      return FloatingActionButton.extended(
        onPressed: onStopScan,
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.stop_rounded, color: Colors.white),
        label: const Text('Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
    }

    return FloatingActionButton.extended(
      onPressed: state.isReady ? onStartScan : null,
      backgroundColor: state.isReady ? AppColors.primary : AppColors.grey300,
      icon: Icon(Icons.play_arrow_rounded, color: state.isReady ? Colors.white : AppColors.grey500),
      label: Text(
        'Start',
        style: TextStyle(
          color: state.isReady ? Colors.white : AppColors.grey500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
