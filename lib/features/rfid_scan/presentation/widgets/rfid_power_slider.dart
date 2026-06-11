library;

import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';

class RfidPowerSlider extends StatefulWidget {
  const RfidPowerSlider({
    super.key,
    required this.currentPower,
    required this.onPowerChanged,
    this.enabled = true,
  });

  final int currentPower;
  final ValueChanged<int> onPowerChanged;
  final bool enabled;

  @override
  State<RfidPowerSlider> createState() => _RfidPowerSliderState();
}

class _RfidPowerSliderState extends State<RfidPowerSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentPower.toDouble();
  }

  @override
  void didUpdateWidget(RfidPowerSlider old) {
    super.didUpdateWidget(old);
    if (old.currentPower != widget.currentPower) {
      _value = widget.currentPower.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reader Power',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(_value / 100).toStringAsFixed(2)} dBm',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _value,
            min: 700,
            max: 3300,
            divisions: 26,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.grey300,
            onChanged: widget.enabled
                ? (v) => setState(() => _value = v)
                : null,
            onChangeEnd: widget.enabled
                ? (v) => widget.onPowerChanged(v.round())
                : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('7 dBm', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
              Text('33 dBm', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
            ],
          ),
        ],
      );
}
