import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';

class RfidTagTileSimple extends StatelessWidget {
  const RfidTagTileSimple({
    super.key,
    required this.tag,
    this.onRemove,
  });

  final RfidTag tag;
  final VoidCallback? onRemove;

  Color _signalColor(SignalStrength s) => switch (s) {
        SignalStrength.excellent => AppColors.success,
        SignalStrength.good => AppColors.successLight,
        SignalStrength.fair => AppColors.warning,
        SignalStrength.weak => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final signal = tag.signalStrength;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _signalColor(signal),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tag.epc,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              '${tag.rssi} dBm',
              style: TextStyle(
                fontSize: 11,
                color: _signalColor(signal),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 18, color: AppColors.grey500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
