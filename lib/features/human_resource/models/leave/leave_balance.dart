class LeaveBalance {
  final Map<String, int> balances;

  LeaveBalance({
    required this.balances,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      balances: {
        'annual_leave': json['annualLeave'] ?? 0,
        'sick_leave': json['sickLeave'] ?? 0,
        'compassionate_leave': json['compassionateLeave'] ?? 0,
        'maternity_leave': json['maternityLeave'] ?? 0,
        'paternity_leave': json['paternityLeave'] ?? 0,
        'study_leave': json['studyLeave'] ?? 0,
        'other_leave': json['otherLeave'] ?? 0,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'annualLeave': balances['annual_leave'] ?? 0,
      'sickLeave': balances['sick_leave'] ?? 0,
      'compassionateLeave': balances['compassionate_leave'] ?? 0,
      'maternityLeave': balances['maternity_leave'] ?? 0,
      'paternityLeave': balances['paternity_leave'] ?? 0,
      'studyLeave': balances['study_leave'] ?? 0,
      'otherLeave': balances['other_leave'] ?? 0,
    };
  }

  int get annualLeave => balances['annual_leave'] ?? 0;
  int get sickLeave => balances['sick_leave'] ?? 0;
  int get compassionateLeave => balances['compassionate_leave'] ?? 0;
  int get maternityLeave => balances['maternity_leave'] ?? 0;
  int get paternityLeave => balances['paternity_leave'] ?? 0;
  int get studyLeave => balances['study_leave'] ?? 0;
  int get otherLeave => balances['other_leave'] ?? 0;

  int get totalBalance =>
      annualLeave +
          sickLeave +
          compassionateLeave +
          maternityLeave +
          paternityLeave +
          studyLeave +
          otherLeave;

  int getBalanceForType(String leaveType) {
    return balances[leaveType] ?? 0;
  }

  LeaveBalance copyWith({
    Map<String, int>? balances,
  }) {
    return LeaveBalance(
      balances: balances ?? this.balances,
    );
  }
}