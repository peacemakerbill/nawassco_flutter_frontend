class CountingTeamMember {
  final String memberId;
  final String role;
  final List<String> assignedZones;
  final int itemsCounted;
  final DateTime startTime;
  final DateTime? endTime;

  CountingTeamMember({
    required this.memberId,
    required this.role,
    required this.assignedZones,
    required this.itemsCounted,
    required this.startTime,
    this.endTime,
  });

  factory CountingTeamMember.fromJson(Map<String, dynamic> json) {
    return CountingTeamMember(
      memberId: json['member'] is String ? json['member'] : json['member']?['_id'] ?? '',
      role: json['role'] ?? 'counter',
      assignedZones: json['assignedZones'] != null
          ? List<String>.from(json['assignedZones'])
          : [],
      itemsCounted: json['itemsCounted'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member': memberId,
      'role': role,
      'assignedZones': assignedZones,
      'itemsCounted': itemsCounted,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}
