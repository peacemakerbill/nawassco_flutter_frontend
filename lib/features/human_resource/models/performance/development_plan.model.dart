class DevelopmentPlan {
  final String? id;
  final String developmentArea;
  final String actionPlan;
  final String resources;
  final DateTime timeline;
  final String responsibleId;

  DevelopmentPlan({
    this.id,
    required this.developmentArea,
    required this.actionPlan,
    required this.resources,
    required this.timeline,
    required this.responsibleId,
  });

  factory DevelopmentPlan.fromJson(Map<String, dynamic> json) {
    return DevelopmentPlan(
      id: json['_id'],
      developmentArea: json['developmentArea'],
      actionPlan: json['actionPlan'],
      resources: json['resources'],
      timeline: DateTime.parse(json['timeline']),
      responsibleId: json['responsible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'developmentArea': developmentArea,
      'actionPlan': actionPlan,
      'resources': resources,
      'timeline': timeline.toIso8601String(),
      'responsible': responsibleId,
    };
  }

  DevelopmentPlan copyWith({
    String? id,
    String? developmentArea,
    String? actionPlan,
    String? resources,
    DateTime? timeline,
    String? responsibleId,
  }) {
    return DevelopmentPlan(
      id: id ?? this.id,
      developmentArea: developmentArea ?? this.developmentArea,
      actionPlan: actionPlan ?? this.actionPlan,
      resources: resources ?? this.resources,
      timeline: timeline ?? this.timeline,
      responsibleId: responsibleId ?? this.responsibleId,
    );
  }
}