import 'package:flutter/material.dart';

class ProcurementConstants {
  static const String appName = 'NAWASSCO Procurement';
  static const String companyName = 'Nakuru Water and Sanitation Services Company';
  static const String companyAddress = 'NAWASSCO Plaza, Moi Road, Nakuru';
  static const String companyPhone = '+254-720-123456';
  static const String companyEmail = 'procurement@nawassco.co.ke';

  // Tender Categories
  static const List<String> tenderCategories = [
    'Goods',
    'Works',
    'Services',
    'Consultancy',
  ];

  // Supplier Categories
  static const List<String> supplierCategories = [
    'Water Meters',
    'Pipes & Fittings',
    'Construction',
    'Chemicals',
    'Services',
    'Consultancy',
  ];

  // Departments
  static const List<String> departments = [
    'Technical',
    'Engineering',
    'Finance',
    'HR',
    'Commercial',
    'Operations',
  ];

  // Status Colors
  static const Map<String, int> statusColors = {
    'Published': 0xFF2196F3,
    'Evaluation': 0xFFFF9800,
    'Awarded': 0xFF4CAF50,
    'Draft': 0xFF9E9E9E,
    'Active': 0xFF4CAF50,
    'Expired': 0xFFF44336,
    'Terminated': 0xFFFF9800,
    'Pending Approval': 0xFFFF9800,
    'Approved': 0xFF4CAF50,
    'Delivered': 0xFF2196F3,
    'Submitted': 0xFF2196F3,
    'Under Review': 0xFFFF9800,
    'Accepted': 0xFF4CAF50,
    'Rejected': 0xFFF44336,
  };

  // Quick Actions
  static const List<Map<String, dynamic>> quickActions = [
    {'title': 'Create Tender', 'icon': Icons.add, 'color': 0xFF2196F3},
    {'title': 'Raise PO', 'icon': Icons.shopping_cart, 'color': 0xFF4CAF50},
    {'title': 'Add Supplier', 'icon': Icons.business, 'color': 0xFFFF9800},
    {'title': 'Generate Report', 'icon': Icons.analytics, 'color': 0xFF9C27B0},
  ];
}