class MovementLocation {
  final String type;
  final String? warehouse;
  final String? zone;
  final String? binLocation;
  final String? department;
  final String? project;
  final String? customer;
  final String? supplier;

  MovementLocation({
    required this.type,
    this.warehouse,
    this.zone,
    this.binLocation,
    this.department,
    this.project,
    this.customer,
    this.supplier,
  });

  factory MovementLocation.fromJson(Map<String, dynamic> json) {
    return MovementLocation(
      type: json['type'] ?? 'warehouse',
      warehouse: json['warehouse'],
      zone: json['zone'],
      binLocation: json['binLocation'],
      department: json['department'],
      project: json['project'],
      customer: json['customer'] is String ? json['customer'] : json['customer']?['_id'],
      supplier: json['supplier'] is String ? json['supplier'] : json['supplier']?['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'warehouse': warehouse,
      'zone': zone,
      'binLocation': binLocation,
      'department': department,
      'project': project,
      'customer': customer,
      'supplier': supplier,
    };
  }
}
