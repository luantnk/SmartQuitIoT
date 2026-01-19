class SlotAvailable {
  final int slotId;
  final String startTime;
  final String endTime;

  SlotAvailable({
    required this.slotId,
    required this.startTime,
    required this.endTime,
  });

  factory SlotAvailable.fromJson(Map<String, dynamic> json) {
    return SlotAvailable(
      slotId: json['slotId'] is int
          ? json['slotId'] as int
          : int.tryParse(json['slotId'].toString()) ?? 0,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }
}
