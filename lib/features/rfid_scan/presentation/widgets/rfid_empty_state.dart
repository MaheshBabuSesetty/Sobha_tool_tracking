import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';

class RfidEmptyState extends StatelessWidget {
  const RfidEmptyState({super.key, required this.state, required this.onRetry});

  final RfidState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isConnecting = state.connectionState.isConnecting;
    final hasFailed = state.connectionState.hasError;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFailed
                  ? Icons.wifi_off_rounded
                  : isConnecting
                      ? Icons.settings_input_antenna
                      : Icons.nfc_rounded,
              size: 56,
              color: hasFailed ? AppColors.error : AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              hasFailed
                  ? (state.errorMessage ?? 'Connection failed')
                  : isConnecting
                      ? 'Initializing scanner…'
                      : state.isScanning
                          ? 'Scanning — bring tags near the reader'
                          : 'Press Start to begin scanning',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: hasFailed ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            if (hasFailed) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
