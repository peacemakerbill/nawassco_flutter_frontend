class ServiceRequestModel {
  final String id;
  final String type;
  final String customerId;
  final String description;
  final String status;
  final String priority;
  final String location;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ServiceRequestModel({
    required this.id,
    required this.type,
    required this.customerId,
    required this.description,
    required this.status,
    required this.priority,
    required this.location,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['_id'] ?? json['id'],
      type: json['type'],
      customerId: json['customerId'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }
}