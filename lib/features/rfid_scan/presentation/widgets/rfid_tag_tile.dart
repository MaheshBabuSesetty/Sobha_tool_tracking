import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';

class RfidTagTile extends StatelessWidget {
  const RfidTagTile({super.key, required this.tag, this.onTap});

  final RfidTag tag;
  final VoidCallback? onTap;

  Color _signalColor(SignalStrength s) => switch (s) {
        SignalStrength.excellent => AppColors.success,
        SignalStrength.good => AppColors.successLight,
        SignalStrength.fair => AppColors.warning,
        SignalStrength.weak => AppColors.error,
      };

  String _signalLabel(SignalStrength s) => switch (s) {
        SignalStrength.excellent => 'Excellent',
        SignalStrength.good => 'Good',
        SignalStrength.fair => 'Fair',
        SignalStrength.weak => 'Weak',
      };

  @override
  Widget build(BuildContext context) {
    final signal = tag.signalStrength;
    final color = _signalColor(signal);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.nfc, color: color, size: 20),
        ),
        title: Text(
          tag.epc,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          '${_signalLabel(signal)} · ${tag.rssi} dBm · reads: ${tag.readCount}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
