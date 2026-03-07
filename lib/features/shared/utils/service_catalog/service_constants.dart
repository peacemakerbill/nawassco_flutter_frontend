import 'package:flutter/material.dart';

class ServiceConstants {
  // Price ranges for filtering
  static const List<double> priceRanges = [0, 1000, 5000, 10000, 25000, 50000, 100000];

  // Service types by category
  static final Map<String, List<String>> serviceTypesByCategory = {
    'water_services': [
      'New Water Connection',
      'Water Meter Installation',
      'Water Meter Reading',
      'Water Leak Repair',
      'Water Quality Testing',
      'Water Pressure Adjustment',
      'Water Disconnection',
      'Water Reconnection',
    ],
    'sewer_services': [
      'New Sewer Connection',
      'Sewer Line Maintenance',
      'Sewer Blockage Clearance',
      'Wastewater Treatment',
      'Septic Tank Services',
    ],
    'laboratory_services': [
      'Water Microbiological Analysis',
      'Water Chemical Analysis',
      'Environmental Testing',
      'Soil Testing',
      'Wastewater Analysis',
    ],
    'connection_services': [
      'New Connection',
      'Temporary Connection',
      'Bulk Connection',
    ],
    'maintenance_services': [
      'Preventive Maintenance',
      'Corrective Maintenance',
      'Pump Maintenance',
      'Valve Maintenance',
    ],
    'billing_services': [
      'Bill Query',
      'Payment Plan',
      'Bill Adjustment',
      'Account Transfer',
    ],
  };

  // Popular service areas
  static const List<String> popularAreas = [
    'Nakuru Town',
    'Bahati',
    'Molo',
    'Naivasha',
    'Gilgil',
    'Rongai',
    'Njoro',
  ];

  // Service status options
  static const List<String> serviceStatusOptions = [
    'Active',
    'Inactive',
    'Under Review',
    'Suspended',
    'Deprecated',
  ];

  // Customer types
  static const List<String> customerTypeOptions = [
    'Residential',
    'Commercial',
    'Industrial',
    'Institutional',
    'Government',
    'Agricultural',
    'All',
  ];

  // Pricing models
  static const List<String> pricingModels = [
    'Fixed',
    'Variable',
    'Tiered',
    'Metered',
    'Time Based',
    'Project Based',
    'Subscription',
  ];

  // Requirement types
  static const List<String> requirementTypes = [
    'Document',
    'Payment',
    'Technical',
    'Administrative',
    'Legal',
    'Environmental',
    'Safety',
    'Permit',
  ];

  // Days of week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Time slots
  static const List<String> timeSlots = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00',
  ];

  // Service window types
  static const List<String> windowTypes = [
    'Business Hours',
    'After Hours',
    'Emergency',
    'Weekend',
  ];

  // Sample data for demo purposes
  static List<Map<String, dynamic>> get sampleServices => [
    {
      'id': '1',
      'serviceCode': 'WCON-0001',
      'name': 'New Water Connection',
      'description': 'Complete installation of new water supply connection for residential or commercial properties.',
      'category': 'water_services',
      'type': 'New Water Connection',
      'status': 'active',
      'pricing': {
        'pricingModel': 'fixed',
        'basePrice': 5000,
        'currency': 'KES',
        'variableComponents': [],
        'taxes': [
          {'name': 'VAT', 'rate': 16, 'description': 'Value Added Tax'}
        ],
        'discounts': [],
      },
      'eligibility': {
        'customerTypes': ['residential', 'commercial'],
        'propertyTypes': ['single_family', 'commercial_building'],
        'prerequisites': ['Land ownership document', 'Approved building plan'],
        'documentationRequired': ['ID copy', 'Title deed', 'Building plan approval'],
      },
      'popularityScore': 95,
    },
    {
      'id': '2',
      'serviceCode': 'WLEK-0002',
      'name': 'Water Leak Repair',
      'description': 'Emergency and scheduled repair of water leaks in pipelines and connections.',
      'category': 'water_services',
      'type': 'Water Leak Repair',
      'status': 'active',
      'pricing': {
        'pricingModel': 'variable',
        'basePrice': 500,
        'currency': 'KES',
        'variableComponents': [
          {'component': 'Labor', 'unit': 'hour', 'rate': 2000},
          {'component': 'Materials', 'unit': 'unit', 'rate': 1500},
        ],
        'taxes': [
          {'name': 'VAT', 'rate': 16, 'description': 'Value Added Tax'}
        ],
        'discounts': [
          {'type': 'percentage', 'value': 10, 'condition': 'Senior citizens'}
        ],
      },
      'eligibility': {
        'customerTypes': ['residential', 'commercial', 'industrial'],
        'propertyTypes': ['all'],
        'prerequisites': [],
        'documentationRequired': ['Account number'],
      },
      'popularityScore': 88,
    },
  ];

  // Color schemes
  static const Map<String, Color> categoryColors = {
    'water_services': Colors.blue,
    'sewer_services': Colors.brown,
    'laboratory_services': Colors.purple,
    'connection_services': Colors.green,
    'maintenance_services': Colors.orange,
    'billing_services': Colors.teal,
    'emergency_services': Colors.red,
    'consultancy_services': Colors.indigo,
    'infrastructure_services': Colors.deepOrange,
    'environmental_services': Colors.green,
    'customer_services': Colors.pink,
    'meter_services': Colors.cyan,
    'quality_services': Colors.lime,
    'planning_services': Colors.amber,
    'education_services': Colors.deepPurple,
  };

  // Icons for categories
  static const Map<String, IconData> categoryIcons = {
    'water_services': Icons.water_drop,
    'sewer_services': Icons.gite,
    'laboratory_services': Icons.science,
    'connection_services': Icons.link,
    'maintenance_services': Icons.build,
    'billing_services': Icons.receipt,
    'emergency_services': Icons.emergency,
    'consultancy_services': Icons.business,
    'infrastructure_services': Icons.apartment,
    'environmental_services': Icons.nature,
    'customer_services': Icons.support_agent,
    'meter_services': Icons.speed,
    'quality_services': Icons.verified,
    'planning_services': Icons.architecture,
    'education_services': Icons.school,
  };

  // Format currency
  static String formatCurrency(double amount, {String currency = 'KES'}) {
    return '$currency ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'under review':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'deprecated':
        return Colors.grey.shade700;
      default:
        return Colors.grey;
    }
  }

  // Get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.pause_circle;
      case 'under review':
        return Icons.hourglass_empty;
      case 'suspended':
        return Icons.block;
      case 'deprecated':
        return Icons.archive;
      default:
        return Icons.help;
    }
  }
}