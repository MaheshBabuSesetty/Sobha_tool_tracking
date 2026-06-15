library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_bloc.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_event.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_already_scanned_banner.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_bottom_action_bar.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_empty_state.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_power_slider.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_status_bar_section.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_tag_list.dart';

class RfidScanResult {
  const RfidScanResult({required this.tags});
  final List<RfidTag> tags;
}

class RfidScannerPage extends StatefulWidget {
  const RfidScannerPage({
    super.key,
    this.title = 'RFID Scanner',
    this.showDoneButton = true,
    this.minTags = 0,
    this.alreadyScannedEpcs = const {},
  });

  final String title;
  final bool showDoneButton;
  final int minTags;
  final Set<String> alreadyScannedEpcs;

  @override
  State<RfidScannerPage> createState() => _RfidScannerPageState();
}

class _RfidScannerPageState extends State<RfidScannerPage> {
  late final RfidBloc _rfidBloc;
  bool _showPowerSlider = false;

  final List<RfidTag> _newTags = [];
  final Set<String> _newTagEpcs = {};

  @override
  void initState() {
    super.initState();
    _rfidBloc = sl<RfidBloc>();
    _rfidBloc.add(const RfidInitializeEvent());
  }

  @override
  void dispose() {
    if (_rfidBloc.state.isScanning) {
      _rfidBloc.add(const RfidStopScanEvent());
    }
    _rfidBloc.add(const RfidDisposeEvent());
    _rfidBloc.close();
    super.dispose();
  }

  void _onTagReceived(RfidTag tag) {
    final epc = tag.epc.toUpperCase();
    if (widget.alreadyScannedEpcs.contains(epc)) return;
    if (_newTagEpcs.contains(epc)) return;
    setState(() {
      _newTagEpcs.add(epc);
      _newTags.add(tag);
    });
  }

  void _clearTags() {
    setState(() {
      _newTags.clear();
      _newTagEpcs.clear();
    });
    _rfidBloc.add(const RfidClearTagsEvent());
  }

  void _removeTag(String epc) {
    final upper = epc.toUpperCase();
    setState(() {
      _newTags.removeWhere((t) => t.epc.toUpperCase() == upper);
      _newTagEpcs.remove(upper);
    });
  }

  void _onDone() => Navigator.pop(context, RfidScanResult(tags: _newTags));

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _rfidBloc,
        child: Scaffold(
          backgroundColor: AppColors.grey100,
          appBar: AppBar(
            backgroundColor: AppColors.sidebarBackground,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              BlocBuilder<RfidBloc, RfidState>(
                builder: (context, state) => IconButton(
                  icon: Icon(
                    _showPowerSlider ? Icons.bolt : Icons.bolt_outlined,
                    color: _showPowerSlider ? AppColors.primary : Colors.white70,
                  ),
                  tooltip: 'Power',
                  onPressed: state.isReady
                      ? () => setState(() => _showPowerSlider = !_showPowerSlider)
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                tooltip: 'Clear',
                onPressed: _newTags.isNotEmpty ? _clearTags : null,
              ),
            ],
          ),
          body: BlocConsumer<RfidBloc, RfidState>(
            listenWhen: (prev, curr) => curr.tags.length > prev.tags.length,
            listener: (_, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                for (final tag in state.tags) {
                  _onTagReceived(tag);
                }
              });
            },
            builder: (context, state) => Column(
              children: [
                RfidStatusBarSection(state: state, newTagCount: _newTags.length),
                if (widget.alreadyScannedEpcs.isNotEmpty)
                  RfidAlreadyScannedBanner(count: widget.alreadyScannedEpcs.length),
                if (_showPowerSlider)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: RfidPowerSlider(
                      currentPower: state.currentPower,
                      enabled: state.isReady && !state.isScanning,
                      onPowerChanged: (power) => _rfidBloc.add(RfidSetPowerEvent(power)),
                    ),
                  ),
                Expanded(
                  child: _newTags.isEmpty
                      ? RfidEmptyState(
                          state: state,
                          onRetry: () => _rfidBloc.add(const RfidInitializeEvent()),
                        )
                      : RfidTagList(
                          tags: _newTags,
                          isScanning: state.isScanning,
                          onRemove: _removeTag,
                        ),
                ),
                RfidBottomActionBar(
                  state: state,
                  newTagCount: _newTags.length,
                  minTags: widget.minTags,
                  showDoneButton: widget.showDoneButton,
                  onScanToggle: () {
                    if (state.isScanning) {
                      _rfidBloc.add(const RfidStopScanEvent());
                    } else {
                      _rfidBloc.add(const RfidStartScanEvent());
                    }
                  },
                  onDone: _onDone,
                ),
              ],
            ),
          ),
        ),
      );
}
