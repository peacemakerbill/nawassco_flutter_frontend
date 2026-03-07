import 'package:flutter/material.dart';

class DepartmentConstants {
  static const List<String> departmentLocations = [
    'Nairobi Head Office',
    'Mombasa Branch',
    'Kisumu Branch',
    'Eldoret Branch',
    'Nakuru Branch',
    'Thika Branch',
    'Remote',
  ];

  static const List<Map<String, dynamic>> departmentTemplates = [
    {
      'name': 'Human Resources',
      'code': 'HR',
      'description': 'Manages recruitment, employee relations, and HR policies',
      'budget': 5000000.0,
    },
    {
      'name': 'Finance',
      'code': 'FIN',
      'description': 'Handles financial planning, accounting, and budgeting',
      'budget': 10000000.0,
    },
    {
      'name': 'Information Technology',
      'code': 'IT',
      'description': 'Manages technology infrastructure and software development',
      'budget': 8000000.0,
    },
    {
      'name': 'Operations',
      'code': 'OPS',
      'description': 'Oversees daily business operations and logistics',
      'budget': 7000000.0,
    },
    {
      'name': 'Marketing',
      'code': 'MKT',
      'description': 'Handles branding, advertising, and customer acquisition',
      'budget': 4000000.0,
    },
    {
      'name': 'Sales',
      'code': 'SALES',
      'description': 'Manages sales teams and revenue generation',
      'budget': 6000000.0,
    },
    {
      'name': 'Customer Service',
      'code': 'CS',
      'description': 'Provides customer support and manages client relationships',
      'budget': 3000000.0,
    },
  ];

  static const List<String> budgetCategories = [
    'Salaries',
    'Equipment',
    'Software',
    'Training',
    'Travel',
    'Office Supplies',
    'Marketing',
    'Maintenance',
    'Utilities',
    'Other',
  ];

  static const Map<String, String> departmentColors = {
    'HR': '#4CAF50',
    'FIN': '#2196F3',
    'IT': '#9C27B0',
    'OPS': '#FF9800',
    'MKT': '#E91E63',
    'SALES': '#F44336',
    'CS': '#00BCD4',
    'ADMIN': '#795548',
    'TECH': '#607D8B',
    'LEGAL': '#3F51B5',
  };

  static String getDepartmentColor(String departmentCode) {
    final key = departmentCode.substring(0, 3).toUpperCase();
    return departmentColors[key] ?? '#607D8B';
  }

  static const Map<String, IconData> departmentIcons = {
    'HR': Icons.people,
    'FIN': Icons.attach_money,
    'IT': Icons.computer,
    'OPS': Icons.settings,
    'MKT': Icons.campaign,
    'SALES': Icons.shopping_cart,
    'CS': Icons.headset_mic,
    'ADMIN': Icons.admin_panel_settings,
    'TECH': Icons.engineering,
    'LEGAL': Icons.gavel,
  };

  static IconData getDepartmentIcon(String departmentCode) {
    final key = departmentCode.substring(0, 3).toUpperCase();
    return departmentIcons[key] ?? Icons.business;
  }
}