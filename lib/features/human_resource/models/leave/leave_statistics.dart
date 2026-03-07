class LeaveStatistics {
  final int totalApplications;
  final int pendingApplications;
  final int approvedThisMonth;
  final List<LeaveTypeStat> leaveTypeStats;
  final List<DepartmentStat> departmentStats;

  LeaveStatistics({
    required this.totalApplications,
    required this.pendingApplications,
    required this.approvedThisMonth,
    required this.leaveTypeStats,
    required this.departmentStats,
  });

  factory LeaveStatistics.fromJson(Map<String, dynamic> json) {
    return LeaveStatistics(
      totalApplications: json['totalApplications'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? 0,
      approvedThisMonth: json['approvedThisMonth'] ?? 0,
      leaveTypeStats: (json['leaveTypeStats'] as List? ?? [])
          .map((e) => LeaveTypeStat.fromJson(e))
          .toList(),
      departmentStats: (json['departmentStats'] as List? ?? [])
          .map((e) => DepartmentStat.fromJson(e))
          .toList(),
    );
  }

  double get approvalRate => totalApplications > 0
      ? ((totalApplications - pendingApplications) / totalApplications) * 100
      : 0;

  String get formattedApprovalRate => '${approvalRate.toStringAsFixed(1)}%';
}

class LeaveTypeStat {
  final String leaveType;
  final int count;

  LeaveTypeStat({
    required this.leaveType,
    required this.count,
  });

  factory LeaveTypeStat.fromJson(Map<String, dynamic> json) {
    return LeaveTypeStat(
      leaveType: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DepartmentStat {
  final String department;
  final int count;

  DepartmentStat({
    required this.department,
    required this.count,
  });

  factory DepartmentStat.fromJson(Map<String, dynamic> json) {
    return DepartmentStat(
      department: json['_id'] ?? 'Unknown',
      count: json['count'] ?? 0,
    );
  }
}