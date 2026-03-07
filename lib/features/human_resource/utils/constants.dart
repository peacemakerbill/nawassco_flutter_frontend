import 'package:flutter/material.dart';

class PerformanceConstants {
  // Color Palette
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFF5C6BC0);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A237E),
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Color(0xFF4B5563),
  );

  // Spacing
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Mock Data for Templates
  static const List<Map<String, dynamic>> mockEmployees = [
    {
      'id': '1',
      'name': 'John Kamau',
      'department': 'Technical',
      'avatar': null,
    },
    {
      'id': '2',
      'name': 'Sarah Wanjiku',
      'department': 'Finance',
      'avatar': null,
    },
    {
      'id': '3',
      'name': 'Michael Otieno',
      'department': 'Customer Service',
      'avatar': null,
    },
  ];

  static const List<Map<String, dynamic>> mockReviewers = [
    {
      'id': '101',
      'name': 'Dr. James Maina',
      'department': 'Management',
      'avatar': null,
    },
    {
      'id': '102',
      'name': 'Grace Nyong\'o',
      'department': 'HR',
      'avatar': null,
    },
    {
      'id': '103',
      'name': 'Lucy Wambui',
      'department': 'Operations',
      'avatar': null,
    },
  ];

  // Template KPAs
  static const Map<String, List<Map<String, dynamic>>> kpaTemplates = {
    'managerial': [
      {
        'area': 'Leadership & Team Management',
        'weight': 25.0,
        'target': 'Lead team to achieve 95% of quarterly goals',
      },
      {
        'area': 'Strategic Planning & Execution',
        'weight': 20.0,
        'target': 'Develop and implement department strategy',
      },
      {
        'area': 'Financial Management',
        'weight': 20.0,
        'target': 'Manage department budget within 5% variance',
      },
      {
        'area': 'Stakeholder Management',
        'weight': 20.0,
        'target': 'Maintain 90% stakeholder satisfaction',
      },
      {
        'area': 'Innovation & Change Management',
        'weight': 15.0,
        'target': 'Implement at least 2 process improvements',
      },
    ],
    'technical': [
      {
        'area': 'Technical Expertise',
        'weight': 30.0,
        'target': 'Complete advanced certification',
      },
      {
        'area': 'Quality of Work',
        'weight': 25.0,
        'target': 'Maintain 98% quality score',
      },
      {
        'area': 'Productivity',
        'weight': 20.0,
        'target': 'Exceed productivity targets by 10%',
      },
      {
        'area': 'Innovation & Improvement',
        'weight': 15.0,
        'target': 'Propose at least 3 technical improvements',
      },
      {
        'area': 'Documentation & Reporting',
        'weight': 10.0,
        'target': 'Complete all documentation on time',
      },
    ],
    'operational': [
      {
        'area': 'Operational Efficiency',
        'weight': 30.0,
        'target': 'Improve efficiency by 15%',
      },
      {
        'area': 'Quality Standards',
        'weight': 25.0,
        'target': 'Maintain 99% quality compliance',
      },
      {
        'area': 'Safety Compliance',
        'weight': 20.0,
        'target': 'Zero safety violations',
      },
      {
        'area': 'Team Collaboration',
        'weight': 15.0,
        'target': 'Participate in all team activities',
      },
      {
        'area': 'Process Improvement',
        'weight': 10.0,
        'target': 'Suggest 2 process improvements',
      },
    ],
  };

  // Template Competencies
  static const Map<String, List<Map<String, dynamic>>> competencyTemplates = {
    'managerial': [
      {
        'competency': 'Strategic Thinking',
        'description': 'Ability to think long-term and plan strategically',
      },
      {
        'competency': 'Decision Making',
        'description': 'Making timely, well-informed decisions',
      },
      {
        'competency': 'Communication',
        'description': 'Clear and effective communication',
      },
      {
        'competency': 'People Development',
        'description': 'Developing team members\' skills',
      },
      {
        'competency': 'Problem Solving',
        'description': 'Effective problem-solving skills',
      },
    ],
    'technical': [
      {
        'competency': 'Technical Skills',
        'description': 'Proficiency in required technical areas',
      },
      {
        'competency': 'Analytical Thinking',
        'description': 'Ability to analyze complex problems',
      },
      {
        'competency': 'Attention to Detail',
        'description': 'Thoroughness and accuracy',
      },
      {
        'competency': 'Continuous Learning',
        'description': 'Willingness to learn new skills',
      },
      {
        'competency': 'Collaboration',
        'description': 'Working effectively with others',
      },
    ],
    'operational': [
      {
        'competency': 'Reliability',
        'description': 'Consistent and dependable performance',
      },
      {
        'competency': 'Teamwork',
        'description': 'Working well with team members',
      },
      {
        'competency': 'Adaptability',
        'description': 'Adapting to changing requirements',
      },
      {
        'competency': 'Safety Awareness',
        'description': 'Maintaining safety standards',
      },
      {
        'competency': 'Problem Solving',
        'description': 'Solving operational issues',
      },
    ],
  };
}