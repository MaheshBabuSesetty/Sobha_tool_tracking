class RfidTagModel {
  const RfidTagModel({
    required this.epc,
    this.rssi,
    this.antenna,
    this.timestamp,
  });

  final String epc;
  final int? rssi;
  final int? antenna;
  final DateTime? timestamp;

  factory RfidTagModel.fromMap(Map<dynamic, dynamic> map) => RfidTagModel(
        epc: map['epc'] as String? ?? '',
        rssi: map['rssi'] as int?,
        antenna: map['antenna'] as int?,
        timestamp: map['timestamp'] is int
            ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
            : DateTime.now(),
      );

  @override
  String toString() => 'RfidTagModel(epc: $epc, rssi: $rssi, antenna: $antenna)';
}
