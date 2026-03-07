import 'package:flutter/material.dart';

import '../../models/consultancy_model.dart';

class ConsultancyUtils {
  static Color getCategoryColor(ConsultancyCategory category) {
    switch (category) {
      case ConsultancyCategory.WATER_TREATMENT:
        return Colors.blue;
      case ConsultancyCategory.INFRASTRUCTURE:
        return Colors.green;
      case ConsultancyCategory.ENVIRONMENTAL:
        return Colors.brown;
      case ConsultancyCategory.MANAGEMENT:
        return Colors.purple;
      case ConsultancyCategory.TECHNICAL:
        return Colors.orange;
      case ConsultancyCategory.RESEARCH:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(ConsultancyCategory category) {
    switch (category) {
      case ConsultancyCategory.WATER_TREATMENT:
        return Icons.water_drop;
      case ConsultancyCategory.INFRASTRUCTURE:
        return Icons.construction;
      case ConsultancyCategory.ENVIRONMENTAL:
        return Icons.nature;
      case ConsultancyCategory.MANAGEMENT:
        return Icons.business;
      case ConsultancyCategory.TECHNICAL:
        return Icons.engineering;
      case ConsultancyCategory.RESEARCH:
        return Icons.science;
      default:
        return Icons.category;
    }
  }

  static String formatCurrency(double amount) {
    return 'KES ${_formatNumber(amount)}';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  static String calculateProgressText(Consultancy consultancy) {
    final progress = consultancy.progressPercentage;
    if (progress < 0.25) return 'Getting Started';
    if (progress < 0.5) return 'In Progress';
    if (progress < 0.75) return 'Halfway There';
    if (progress < 1) return 'Nearly Complete';
    return 'Completed';
  }

  static String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}