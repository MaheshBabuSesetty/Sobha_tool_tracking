import 'package:flutter/material.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/widgets/rfid_tag_tile_simple.dart';

class RfidTagList extends StatelessWidget {
  const RfidTagList({
    super.key,
    required this.tags,
    required this.isScanning,
    required this.onRemove,
  });

  final List<RfidTag> tags;
  final bool isScanning;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: tags.length,
        itemBuilder: (_, i) {
          final tag = tags[tags.length - 1 - i]; // newest first
          return RfidTagTileSimple(
            tag: tag,
            onRemove: isScanning ? null : () => onRemove(tag.epc),
          );
        },
      );
}
